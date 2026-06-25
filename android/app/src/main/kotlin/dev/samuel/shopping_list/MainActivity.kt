package dev.samuel.shopping_list

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    companion object {
        const val EXTRA_LAUNCH_ACTION = "launch_action"
    }

    private var pendingLaunchAction: String? = null

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        intent.getStringExtra(EXTRA_LAUNCH_ACTION)?.let { pendingLaunchAction = it }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        pendingLaunchAction =
            intent?.getStringExtra(EXTRA_LAUNCH_ACTION) ?: pendingLaunchAction

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "shopping_list/store"
        ).setMethodCallHandler { call, result ->
            val prefs = Prefs.get(this)
            when (call.method) {
                "loadList" -> result.success(prefs.getString(Prefs.KEY_LIST, null))

                "saveList" -> {
                    prefs.edit()
                        .putString(Prefs.KEY_LIST, call.argument<String>("json"))
                        .apply()
                    ListWidgetProvider.refreshAll(this)
                    result.success(null)
                }

                "loadTheme" -> result.success(
                    mapOf(
                        "mode" to Prefs.themeMode(this),
                        "palette" to prefs.getInt(Prefs.KEY_THEME_PALETTE, 0),
                    )
                )

                "saveTheme" -> {
                    prefs.edit()
                        .putString(Prefs.KEY_THEME_MODE, call.argument<String>("mode"))
                        .putInt(Prefs.KEY_THEME_PALETTE, call.argument<Int>("palette") ?: 0)
                        .putInt(
                            Prefs.KEY_THEME_ACCENT,
                            (call.argument<Number>("accent") ?: Prefs.DEFAULT_ACCENT).toInt()
                        )
                        .apply()
                    ListWidgetProvider.refreshAll(this)
                    result.success(null)
                }

                "takeLaunchAction" -> {
                    result.success(pendingLaunchAction)
                    pendingLaunchAction = null
                }

                else -> result.notImplemented()
            }
        }
    }
}
