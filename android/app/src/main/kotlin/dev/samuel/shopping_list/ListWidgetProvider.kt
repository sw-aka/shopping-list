package dev.samuel.shopping_list

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.res.Configuration
import android.net.Uri
import android.widget.RemoteViews
import org.json.JSONArray

/** Widget taps update the shared store, which Flutter reloads on resume. */
class ListWidgetProvider : AppWidgetProvider() {

    companion object {
        const val ACTION_ITEM = "dev.samuel.shopping_list.WIDGET_ITEM"
        const val ACTION_UNDO = "dev.samuel.shopping_list.WIDGET_UNDO"
        const val EXTRA_ITEM_ID = "item_id"
        const val EXTRA_OP = "op"
        const val OP_TOGGLE = "toggle"

        fun refreshAll(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            val ids = manager.getAppWidgetIds(
                ComponentName(context, ListWidgetProvider::class.java)
            )
            if (ids.isEmpty()) return
            manager.notifyAppWidgetViewDataChanged(ids, R.id.widget_list)
            for (id in ids) render(context, manager, id)
        }

        fun darkMode(context: Context): Boolean = when (Prefs.themeMode(context)) {
            "dark" -> true
            "light" -> false
            else -> (context.resources.configuration.uiMode and
                Configuration.UI_MODE_NIGHT_MASK) == Configuration.UI_MODE_NIGHT_YES
        }

        fun render(context: Context, manager: AppWidgetManager, widgetId: Int) {
            val dark = darkMode(context)
            val accent = Prefs.accent(context)
            val views = RemoteViews(context.packageName, R.layout.widget_root)

            views.setInt(
                R.id.widget_root, "setBackgroundResource",
                if (dark) R.drawable.widget_bg_dark else R.drawable.widget_bg_light
            )
            val textColor = if (dark) 0xFFECECEC.toInt() else 0xFF1B1B1B.toInt()
            val subColor = if (dark) 0xFF9E9E9E.toInt() else 0xFF757575.toInt()
            views.setTextColor(R.id.widget_title, textColor)
            views.setTextColor(R.id.widget_count, subColor)
            views.setTextColor(R.id.widget_empty, subColor)
            views.setInt(R.id.widget_add, "setColorFilter", accent)

            val items = Prefs.loadItems(context)
            var done = 0
            for (i in 0 until items.length()) {
                if (items.optJSONObject(i)?.optBoolean("done") == true) done++
            }
            views.setTextViewText(
                R.id.widget_count,
                if (items.length() == 0) "" else "$done/${items.length()}"
            )
            views.setTextViewText(
                R.id.widget_empty,
                context.getString(
                    if (items.length() > 0 && done == items.length())
                        R.string.widget_all_done
                    else
                        R.string.widget_empty
                )
            )

            // Ignore undo entries for deleted or already unticked items.
            val undoable = Prefs.loadUndoIds(context).any { id ->
                (0 until items.length()).any {
                    items.optJSONObject(it)?.optString("id") == id &&
                        items.optJSONObject(it)?.optBoolean("done") == true
                }
            }
            views.setViewVisibility(
                R.id.widget_undo,
                if (undoable) android.view.View.VISIBLE else android.view.View.GONE
            )
            views.setInt(R.id.widget_undo, "setColorFilter", subColor)
            val undoIntent = Intent(context, ListWidgetProvider::class.java).apply {
                action = ACTION_UNDO
            }
            views.setOnClickPendingIntent(
                R.id.widget_undo,
                PendingIntent.getBroadcast(
                    context, 3, undoIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
            )

            val adapterIntent = Intent(context, ListWidgetService::class.java).apply {
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, widgetId)
                // RemoteViews caches adapters by intent, so each widget needs its own URI.
                data = Uri.parse("shoppinglist://widget/$widgetId")
            }
            views.setRemoteAdapter(R.id.widget_list, adapterIntent)
            views.setEmptyView(R.id.widget_list, R.id.widget_empty)

            val itemIntent = Intent(context, ListWidgetProvider::class.java).apply {
                action = ACTION_ITEM
            }
            views.setPendingIntentTemplate(
                R.id.widget_list,
                PendingIntent.getBroadcast(
                    context, 0, itemIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE
                )
            )

            // Use a separate activity so quick-add does not open the Flutter screen.
            val addIntent = Intent(context, QuickAddActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            }
            views.setOnClickPendingIntent(
                R.id.widget_add,
                PendingIntent.getActivity(
                    context, 1, addIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
            )

            val openIntent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            }
            views.setOnClickPendingIntent(
                R.id.widget_header,
                PendingIntent.getActivity(
                    context, 2, openIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
            )

            manager.updateAppWidget(widgetId, views)
        }
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (id in appWidgetIds) render(context, appWidgetManager, id)
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        when (intent.action) {
            ACTION_ITEM -> handleItem(context, intent)
            ACTION_UNDO -> handleUndo(context)
        }
    }

    private fun handleItem(context: Context, intent: Intent) {
        val itemId = intent.getStringExtra(EXTRA_ITEM_ID) ?: return
        val op = intent.getStringExtra(EXTRA_OP) ?: return

        val list = toList(Prefs.loadItems(context))
        val index = list.indexOfFirst { it.optString("id") == itemId }
        if (index < 0) return

        when (op) {
            // Ticked items leave the widget and enter the undo history.
            OP_TOGGLE -> {
                val item = list.removeAt(index)
                item.put("done", true)
                list.add(item)
                Prefs.pushUndoId(context, itemId)
            }
            else -> return
        }
        Prefs.saveItems(context, toJson(list))
        refreshAll(context)
    }

    /** Skips stale undo ids and restores the most recent valid tick. */
    private fun handleUndo(context: Context) {
        val list = toList(Prefs.loadItems(context))
        val undo = Prefs.loadUndoIds(context)
        while (undo.isNotEmpty()) {
            val id = undo.removeAt(0)
            val index = list.indexOfFirst {
                it.optString("id") == id && it.optBoolean("done")
            }
            if (index < 0) continue
            val item = list.removeAt(index)
            item.put("done", false)
            val firstDone = list.indexOfFirst { it.optBoolean("done") }
            list.add(if (firstDone < 0) list.size else firstDone, item)
            Prefs.saveItems(context, toJson(list))
            break
        }
        Prefs.saveUndoIds(context, undo)
        refreshAll(context)
    }

    private fun toList(items: JSONArray): MutableList<org.json.JSONObject> =
        (0 until items.length()).mapNotNull { items.optJSONObject(it) }
            .toMutableList()

    private fun toJson(list: List<org.json.JSONObject>): JSONArray =
        JSONArray().also { array -> list.forEach { array.put(it) } }
}
