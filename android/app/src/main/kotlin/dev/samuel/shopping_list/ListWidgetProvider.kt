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

/**
 * Resizable home-screen widget. Rows are served by [ListWidgetService];
 * taps come back here as broadcasts (toggle, move up, move down) and are
 * applied straight to the shared store, so the Flutter app picks them up
 * on next resume.
 */
class ListWidgetProvider : AppWidgetProvider() {

    companion object {
        const val ACTION_ITEM = "dev.samuel.shopping_list.WIDGET_ITEM"
        const val EXTRA_ITEM_ID = "item_id"
        const val EXTRA_OP = "op"
        const val OP_TOGGLE = "toggle"
        const val OP_UP = "up"
        const val OP_DOWN = "down"

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

            // + button opens the app straight into the add sheet.
            val addIntent = Intent(context, MainActivity::class.java).apply {
                putExtra(MainActivity.EXTRA_LAUNCH_ACTION, "add")
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP
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
        if (intent.action != ACTION_ITEM) return
        val itemId = intent.getStringExtra(EXTRA_ITEM_ID) ?: return
        val op = intent.getStringExtra(EXTRA_OP) ?: return

        val items = Prefs.loadItems(context)
        val index = (0 until items.length())
            .firstOrNull { items.optJSONObject(it)?.optString("id") == itemId }
            ?: return

        when (op) {
            OP_TOGGLE -> {
                val item = items.getJSONObject(index)
                item.put("done", !item.optBoolean("done"))
            }
            OP_UP -> if (index > 0) swap(items, index, index - 1)
            OP_DOWN -> if (index < items.length() - 1) swap(items, index, index + 1)
            else -> return
        }
        Prefs.saveItems(context, items)
        refreshAll(context)
    }

    private fun swap(items: JSONArray, a: Int, b: Int) {
        val tmp = items.get(a)
        items.put(a, items.get(b))
        items.put(b, tmp)
    }
}
