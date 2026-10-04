package com.alldeploy.shoppinglist

import android.content.Context
import android.content.Intent
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
        // The widget shows active items only. Undo is in the header.
        items = (0 until array.length())
            .mapNotNull { array.optJSONObject(it) }
            .filterNot { it.optBoolean("done") }
    }

    override fun onDestroy() = Unit

    override fun getCount() = items.size

    override fun getViewAt(position: Int): RemoteViews {
        val views = RemoteViews(context.packageName, R.layout.widget_item)
        val item = items.getOrNull(position) ?: return views
        val id = item.optString("id")
        val name = item.optString("name")

        val dark = ListWidgetProvider.darkMode(context)
        val textColor = if (dark) 0xFFECECEC.toInt() else 0xFF1B1B1B.toInt()
        val chevronColor = if (dark) 0xFF6E6E6E.toInt() else 0xFFB0B0B0.toInt()

        // Only active items reach this factory, so the tick is always unticked.
        views.setImageViewResource(R.id.item_check, R.drawable.ic_check_off)
        views.setInt(R.id.item_check, "setColorFilter", chevronColor)

        views.setTextViewText(R.id.item_name, name)
        views.setTextColor(R.id.item_name, textColor)

        views.setOnClickFillInIntent(
            R.id.item_body,
            Intent().apply {
                putExtra(ListWidgetProvider.EXTRA_ITEM_ID, id)
                putExtra(ListWidgetProvider.EXTRA_OP, ListWidgetProvider.OP_TOGGLE)
            }
        )
        return views
    }

    override fun getLoadingView(): RemoteViews? = null

    override fun getViewTypeCount() = 1

    override fun getItemId(position: Int) =
        items.getOrNull(position)?.optString("id")?.hashCode()?.toLong()
            ?: position.toLong()

    override fun hasStableIds() = true
}
