package com.mossapps.flick

import android.content.ComponentName
import android.content.Context
import android.media.AudioManager
import android.content.pm.PackageManager
import android.util.Log
import android.os.Build
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

/**
 * Switches the launcher icon to the alias whose sticker matches the accent.
 *
 * Desktop redraws its Dock/taskbar icon live; Android can only pick one of
 * the pre-built `.LauncherIcon<Accent>` aliases in the manifest. Swapping
 * aliases uses DONT_KILL_APP, which some launchers still treat as a restart.
 * Save changes now and apply only after the activity is backgrounded and idle.
 */
object LauncherIcon {
    private const val CHANNEL = "lokal/launcher_icon"
    private const val PREFS = "lokal_launcher_icon"
    private const val KEY_WANTED = "wanted"
    private const val TAG = "LauncherIcon"

    /** Must match the aliases in AndroidManifest.xml and LokalAccent.presets. */
    val accents = listOf(
        "lime", "purple", "pink", "orange", "blue", "red",
        "teal", "white", "yellow", "cyan", "magenta", "gray",
        "chartreuse", "midnight", "rosegold", "neon",
    )
    private const val DEFAULT = "lime"
    private var aliases: Map<String, String>? = null

    private var busy = false

    fun onStop(context: Context) {
        if (LokalAppUpdater.systemUiOpen) return
        val audio = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager
        if (!busy && !FileCopyService.running && !audio.isMusicActive) applyPending(context)
    }

    fun register(messenger: BinaryMessenger, context: Context) {
        MethodChannel(messenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "setAccent" -> {
                    val accent = call.argument<String>("accent")
                    if (accent == null || accent !in accents) {
                        result.error("bad_accent", "Unknown accent: $accent", null)
                    } else {
                        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
                            .edit().putString(KEY_WANTED, accent).apply()
                        // An accepted request is queued, not applied in the foreground.
                        result.success(null)
                    }
                }
                "setBusy" -> { busy = call.argument<Boolean>("busy") ?: false; result.success(null) }
                else -> result.notImplemented()
            }
        }
    }

    /** Enables the wanted alias and disables the others, if anything changed. */
    fun applyPending(context: Context): Boolean {
        val wanted = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            .getString(KEY_WANTED, DEFAULT) ?: DEFAULT
        val pm = context.packageManager
        try {
            val current = accents.filter { isEnabled(pm, context, it) }
            if (current == listOf(wanted)) return true
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                pm.setComponentEnabledSettings(accents.map { accent ->
                    PackageManager.ComponentEnabledSetting(
                        component(context, accent),
                        if (accent == wanted) PackageManager.COMPONENT_ENABLED_STATE_ENABLED
                        else PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
                        PackageManager.DONT_KILL_APP,
                    )
                })
                return accents.filter { isEnabled(pm, context, it) } == listOf(wanted)
            }
            // Enable first, so there is never a moment with no launcher entry.
            setEnabled(pm, context, wanted, true)
            for (accent in accents) {
                if (accent != wanted) setEnabled(pm, context, accent, false)
            }
        } catch (e: Exception) {
            Log.w(TAG, "Could not switch the launcher icon: ${e.message}")
            return false
        }
        return accents.filter { isEnabled(pm, context, it) } == listOf(wanted)
    }

    private fun component(context: Context, accent: String): ComponentName {
        val suffix = "LauncherIcon${accent.replaceFirstChar { it.uppercase() }}"
        val names = aliases ?: context.packageManager.getPackageInfo(
            context.packageName,
            PackageManager.GET_ACTIVITIES or PackageManager.MATCH_DISABLED_COMPONENTS,
        ).activities.orEmpty().associate { it.name.substringAfterLast('.') to it.name }
            .also { aliases = it }
        val name = names[suffix] ?: error("Missing launcher alias: $suffix")
        return ComponentName(context.packageName, name)
    }

    private fun isEnabled(pm: PackageManager, context: Context, accent: String): Boolean =
        when (pm.getComponentEnabledSetting(component(context, accent))) {
            PackageManager.COMPONENT_ENABLED_STATE_ENABLED -> true
            PackageManager.COMPONENT_ENABLED_STATE_DISABLED -> false
            // Default: whatever the manifest says, which is lime only.
            else -> accent == DEFAULT
        }

    private fun setEnabled(pm: PackageManager, context: Context, accent: String, on: Boolean) {
        pm.setComponentEnabledSetting(
            component(context, accent),
            if (on) PackageManager.COMPONENT_ENABLED_STATE_ENABLED
            else PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
            PackageManager.DONT_KILL_APP,
        )
    }
}
