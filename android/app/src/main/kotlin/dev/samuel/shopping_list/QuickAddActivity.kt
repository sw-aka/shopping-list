package dev.samuel.shopping_list

import android.app.Activity
import android.content.Context
import android.os.Bundle
import android.view.Gravity
import android.view.KeyEvent
import android.view.ViewGroup
import android.view.inputmethod.EditorInfo
import android.view.inputmethod.InputMethodManager
import android.widget.EditText
import android.widget.ImageButton
import android.widget.LinearLayout
import org.json.JSONObject

/** Native add field over the home screen. Writes to the shared store. */
class QuickAddActivity : Activity() {

    private lateinit var input: EditText

    /** Disambiguates ids created within the same millisecond. */
    private var counter = 0

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        window.setGravity(Gravity.BOTTOM)
        window.setLayout(
            ViewGroup.LayoutParams.MATCH_PARENT,
            ViewGroup.LayoutParams.WRAP_CONTENT
        )
        setFinishOnTouchOutside(true)

        setContentView(R.layout.quick_add)

        val dark = ListWidgetProvider.darkMode(this)
        val accent = Prefs.accent(this)
        val textColor = if (dark) 0xFFECECEC.toInt() else 0xFF1B1B1B.toInt()
        val hintColor = if (dark) 0xFF9E9E9E.toInt() else 0xFF757575.toInt()

        findViewById<LinearLayout>(R.id.quick_add_bar).setBackgroundResource(
            if (dark) R.drawable.widget_bg_dark else R.drawable.widget_bg_light
        )
        findViewById<ImageButton>(R.id.quick_add_submit).apply {
            setColorFilter(accent)
            setOnClickListener { submit() }
        }
        input = findViewById(R.id.quick_add_input)
        input.setTextColor(textColor)
        input.setHintTextColor(hintColor)
        input.setOnEditorActionListener { _, actionId, event ->
            when {
                actionId == EditorInfo.IME_ACTION_DONE -> {
                    submit()
                    true
                }
                // Some hardware keyboards send Enter instead of an IME action.
                // Consume both phases to avoid submitting twice.
                actionId == EditorInfo.IME_NULL &&
                    event?.keyCode == KeyEvent.KEYCODE_ENTER -> {
                    if (event.action == KeyEvent.ACTION_DOWN) submit()
                    true
                }
                else -> false
            }
        }
    }

    override fun onResume() {
        super.onResume()
        // Some launchers ignore stateAlwaysVisible for dialog windows.
        input.requestFocus()
        input.post {
            (getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager)
                .showSoftInput(input, InputMethodManager.SHOW_IMPLICIT)
        }
    }

    private fun submit() {
        val name = input.text.toString().trim()
        if (name.isEmpty()) return
        val items = Prefs.loadItems(this)
        items.put(
            JSONObject()
                .put("id", newId())
                .put("name", name)
                .put("done", false)
        )
        Prefs.saveItems(this, items)
        ListWidgetProvider.refreshAll(this)
        input.setText("")
    }

    // The w marker after the timestamp separates widget ids from Flutter ids.
    private fun newId() = "${System.currentTimeMillis() * 1000}-w${counter++}"
}
