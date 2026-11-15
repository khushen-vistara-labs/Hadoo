package com.mossapps.flick

import android.content.Context
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.provider.Settings
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

/** Single native waveform ensures repeated quick pulses have distinct spacing. */
object LokalHaptics {
    fun register(messenger: BinaryMessenger, context: Context) {
        MethodChannel(messenger, "lokal/haptics").setMethodCallHandler { call, result ->
            if (call.method != "pulsePattern") {
                result.notImplemented()
                return@setMethodCallHandler
            }
            val pulses = call.argument<Int>("pulses")
            if (pulses != 2 && pulses != 3) {
                result.error("INVALID_PATTERN", "Expected two or three pulses", null)
                return@setMethodCallHandler
            }
            try {
                if (Settings.System.getInt(
                        context.contentResolver,
                        Settings.System.HAPTIC_FEEDBACK_ENABLED,
                        1
                    ) == 0
                ) {
                    result.success(null)
                    return@setMethodCallHandler
                }
                val vibrator = context.getSystemService(Context.VIBRATOR_SERVICE) as? Vibrator
                if (vibrator?.hasVibrator() == true) {
                    // Two or three discrete 14 ms pulses, 34 ms apart.
                    val timing = LongArray(pulses * 2) { index ->
                        if (index % 2 == 1) 14L else if (index == 0) 0L else 34L
                    }
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        vibrator.vibrate(VibrationEffect.createWaveform(timing, -1))
                    } else {
                        @Suppress("DEPRECATION")
                        vibrator.vibrate(timing, -1)
                    }
                }
                result.success(null)
            } catch (_: Exception) {
                result.error("HAPTIC_UNAVAILABLE", "Haptic service unavailable", null)
            }
        }
    }
}
