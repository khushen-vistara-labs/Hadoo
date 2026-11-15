package com.mossapps.flick.youtube

import android.os.SystemClock
import android.util.Log

/** Small local log adapter for the vendored InnerTubeX/BotGuard integration. */
internal object TrackLog {
    fun d(tag: String, message: String) {
        if (com.mossapps.flick.BuildConfig.DEBUG) Log.d(tag, message)
    }

    fun w(tag: String, message: String, about: String? = null) {
        Log.w(tag, if (about.isNullOrBlank()) message else "$message [track=$about]")
    }

    fun e(tag: String, message: String, error: Throwable? = null) {
        if (error == null) Log.e(tag, message) else Log.e(tag, message, error)
    }
}

internal object MonotonicClock {
    fun nowMs(): Long = SystemClock.elapsedRealtime()
}
