package com.mossapps.flick

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.net.wifi.WifiManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.IBinder
import android.os.PowerManager
import androidx.core.app.NotificationCompat
import androidx.core.app.ServiceCompat
import androidx.core.content.ContextCompat
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

/** Foreground lifetime for a user-started copy, independent of media playback. */
class FileCopyService : Service() {
    private val handler = Handler(Looper.getMainLooper())
    private val stale = Runnable { stopForeground(STOP_FOREGROUND_REMOVE); stopSelf() }
    private var wake: PowerManager.WakeLock? = null
    private var wifi: WifiManager.WifiLock? = null
    override fun onBind(intent: Intent?): IBinder? = null
    override fun onCreate() {
        super.onCreate()
        running = true
        getSystemService(NotificationManager::class.java).createNotificationChannel(
            NotificationChannel(CHANNEL, "Music file copies", NotificationManager.IMPORTANCE_LOW).apply {
                setShowBadge(false); setSound(null, null); enableVibration(false)
            })
    }
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent == null) { stopSelf(); return START_NOT_STICKY }
        val stopping = intent.action == "stop"
        val notification = notification(intent, !stopping)
        if (stopping) {
            stopForeground(STOP_FOREGROUND_REMOVE)
            getSystemService(NotificationManager::class.java).notify(ID, notification)
            stopSelf()
            return START_NOT_STICKY
        }
        ServiceCompat.startForeground(this, ID, notification,
            if (Build.VERSION.SDK_INT >= 29) ServiceInfo.FOREGROUND_SERVICE_TYPE_DATA_SYNC else 0)
        handler.removeCallbacks(stale)
        handler.postDelayed(stale, 10 * 60 * 1000L)
        // Timed, non-reference-counted CPU lock is renewed by progress updates;
        // no permanent lock remains after completion, failure or service teardown.
        if (wake == null) wake = (getSystemService(POWER_SERVICE) as PowerManager)
            .newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "Hadoo:FileCopy").apply { setReferenceCounted(false) }
        wake?.acquire(10 * 60 * 1000L)
        if (wifi == null) {
            @Suppress("DEPRECATION")
            val lock = (applicationContext.getSystemService(WIFI_SERVICE) as WifiManager)
                .createWifiLock(WifiManager.WIFI_MODE_FULL_HIGH_PERF, "Hadoo:FileCopy").apply { setReferenceCounted(false) }
            wifi = lock
            lock.acquire()
        }
        return START_NOT_STICKY
    }
    private fun notification(intent: Intent, busy: Boolean): Notification {
        val open = PendingIntent.getActivity(this, ID, Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
        }, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
        val message = intent.getStringExtra("message").orEmpty()
        return NotificationCompat.Builder(this, CHANNEL)
            .setSmallIcon(R.drawable.ic_notification)
            .setContentTitle(intent.getStringExtra("title") ?: "Copying music")
            .setContentText(message).setStyle(NotificationCompat.BigTextStyle().bigText(message))
            .setSubText(intent.getStringExtra("device")).setContentIntent(open)
            .setOngoing(busy).setAutoCancel(!busy).setOnlyAlertOnce(true).setSilent(true)
            .setCategory(NotificationCompat.CATEGORY_PROGRESS)
            .setForegroundServiceBehavior(NotificationCompat.FOREGROUND_SERVICE_IMMEDIATE)
            .apply {
                if (busy) {
                    val total = intent.getIntExtra("total", 0)
                    setProgress(total, intent.getIntExtra("processed", 0).coerceAtMost(total), total <= 0)
                } else setTimeoutAfter(20_000L)
            }.build()
    }
    override fun onTimeout(startId: Int, fgsType: Int) { stopForeground(STOP_FOREGROUND_REMOVE); stopSelf() }
    override fun onTaskRemoved(rootIntent: Intent?) { stopSelf() }
    override fun onDestroy() {
        handler.removeCallbacks(stale)
        running = false
        if (wake?.isHeld == true) wake?.release()
        if (wifi?.isHeld == true) wifi?.release()
        wake = null; wifi = null
        super.onDestroy()
    }
    companion object {
        @Volatile var running = false
            private set
        private const val CHANNEL = "lokal_file_copy"
        private const val ID = 1043
        fun register(messenger: BinaryMessenger, context: Context) {
            MethodChannel(messenger, "lokal/file_copy").setMethodCallHandler { call, result ->
                if (call.method !in setOf("start", "update", "stop")) { result.notImplemented(); return@setMethodCallHandler }
                val intent = Intent(context, FileCopyService::class.java).setAction(call.method)
                for (key in listOf("title", "message", "device")) intent.putExtra(key, call.argument<String>(key))
                for (key in listOf("total", "processed")) intent.putExtra(key, call.argument<Number>(key)?.toInt() ?: 0)
                try {
                    if (call.method == "start") ContextCompat.startForegroundService(context, intent)
                    else context.startService(intent)
                    result.success(null)
                } catch (_: Exception) {
                    result.error("COPY_BACKGROUND_UNAVAILABLE", "Could not keep the copy running in the background. Keep Hadoo open and retry.", null)
                }
            }
        }
    }
}
