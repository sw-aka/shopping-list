package dev.samuel.shopping_list

import android.content.Context
import android.content.SharedPreferences
import org.json.JSONArray
import org.json.JSONObject

/** SharedPreferences used by Flutter and the home-screen widget. */
object Prefs {
    private const val FILE = "shopping_list_store"

    const val KEY_LIST = "list_json"
    const val KEY_THEME_MODE = "theme_mode"
    const val KEY_THEME_PALETTE = "theme_palette"
    const val KEY_THEME_ACCENT = "theme_accent"
    const val KEY_UNDO = "undo_ids"

    const val UNDO_LIMIT = 3

    const val DEFAULT_ACCENT = 0xFF2E7D5B.toInt() // mint, matches Flutter default

    fun get(context: Context): SharedPreferences =
        context.getSharedPreferences(FILE, Context.MODE_PRIVATE)

    fun loadItems(context: Context): JSONArray {
        val raw = get(context).getString(KEY_LIST, null) ?: return JSONArray()
        return try {
            JSONObject(raw).optJSONArray("items") ?: JSONArray()
        } catch (_: Exception) {
            JSONArray()
        }
    }

    fun saveItems(context: Context, items: JSONArray) {
        val json = JSONObject().put("items", items).toString()
        get(context).edit().putString(KEY_LIST, json).apply()
    }

    /** Undo ids are stored most recent first. */
    fun loadUndoIds(context: Context): MutableList<String> {
        val raw = get(context).getString(KEY_UNDO, null) ?: return mutableListOf()
        return try {
            val array = JSONArray(raw)
            MutableList(array.length()) { array.getString(it) }
        } catch (_: Exception) {
            mutableListOf()
        }
    }

    fun saveUndoIds(context: Context, ids: List<String>) {
        get(context).edit()
            .putString(KEY_UNDO, JSONArray(ids.take(UNDO_LIMIT)).toString())
            .apply()
    }

    fun pushUndoId(context: Context, id: String) {
        val ids = loadUndoIds(context)
        ids.remove(id)
        ids.add(0, id)
        saveUndoIds(context, ids)
    }

    fun accent(context: Context): Int =
        get(context).getInt(KEY_THEME_ACCENT, DEFAULT_ACCENT)

    /** Stored theme mode: system, light, or dark. */
    fun themeMode(context: Context): String =
        get(context).getString(KEY_THEME_MODE, "system") ?: "system"
}
