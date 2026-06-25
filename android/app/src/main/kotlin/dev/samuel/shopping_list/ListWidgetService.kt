package dev.samuel.shopping_list

import android.content.Context
import android.content.Intent
import android.text.SpannableString
import android.text.Spanned
import android.text.style.StrikethroughSpan
import android.widget.RemoteViews
import android.widget.RemoteViewsService
import org.json.JSONObject

class ListWidgetService : RemoteViewsService() {
    override fun onGetViewFactory(intent: Intent): RemoteViewsFactory =
        ListRemoteViewsFactory(applicationContext)
}

private class ListRemoteViewsFactory(
    private val context: Context,
) : RemoteViewsService.RemoteViewsFactory {

    private var items = listOf<JSONObject>()

    override fun onCreate() = Unit

    override fun onDataSetChanged() {
        val array = Prefs.loadItems(context)
        items = (0 until array.length()).mapNotNull { array.optJSONObject(it) }
    }

    override fun onDestroy() = Unit

    override fun getCount() = items.size

    override fun getViewAt(position: Int): RemoteViews {
        val views = RemoteViews(context.packageName, R.layout.widget_item)
        val item = items.getOrNull(position) ?: return views
        val id = item.optString("id")
        val name = item.optString("name")
        val done = item.optBoolean("done")

        val dark = ListWidgetProvider.darkMode(context)
        val accent = Prefs.accent(context)
        val textColor = if (dark) 0xFFECECEC.toInt() else 0xFF1B1B1B.toInt()
        val doneColor = if (dark) 0xFF808080.toInt() else 0xFF9E9E9E.toInt()
        val chevronColor = if (dark) 0xFF6E6E6E.toInt() else 0xFFB0B0B0.toInt()

        views.setImageViewResource(
            R.id.item_check,
            if (done) R.drawable.ic_check_on else R.drawable.ic_check_off
        )
        views.setInt(R.id.item_check, "setColorFilter", if (done) accent else chevronColor)

        val text = if (done) {
            SpannableString(name).apply {
                setSpan(StrikethroughSpan(), 0, length, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE)
            }
        } else {
            SpannableString(name)
        }
        views.setTextViewText(R.id.item_name, text)
        views.setTextColor(R.id.item_name, if (done) doneColor else textColor)

        views.setInt(R.id.item_up, "setColorFilter", chevronColor)
        views.setInt(R.id.item_down, "setColorFilter", chevronColor)

        fun fillIn(op: String) = Intent().apply {
            putExtra(ListWidgetProvider.EXTRA_ITEM_ID, id)
            putExtra(ListWidgetProvider.EXTRA_OP, op)
        }
        views.setOnClickFillInIntent(R.id.item_body, fillIn(ListWidgetProvider.OP_TOGGLE))
        views.setOnClickFillInIntent(R.id.item_up, fillIn(ListWidgetProvider.OP_UP))
        views.setOnClickFillInIntent(R.id.item_down, fillIn(ListWidgetProvider.OP_DOWN))
        return views
    }

    override fun getLoadingView(): RemoteViews? = null

    override fun getViewTypeCount() = 1

    override fun getItemId(position: Int) =
        items.getOrNull(position)?.optString("id")?.hashCode()?.toLong()
            ?: position.toLong()

    override fun hasStableIds() = true
}
