package com.langgeng.langgeng_clip

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Intent
import android.os.Build
import android.os.IBinder

class ExportForegroundService : Service() {
    override fun onCreate() {
        super.onCreate()
        ensureChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        startForeground(EXPORT_NOTIFICATION_ID, buildNotification())
        return START_NOT_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun ensureChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            return
        }

        val notificationManager = getSystemService(NotificationManager::class.java)
        val channel = NotificationChannel(
            EXPORT_CHANNEL_ID,
            "Export progress",
            NotificationManager.IMPORTANCE_LOW,
        ).apply {
            description = "Shows Langgeng Clip export progress."
        }
        notificationManager.createNotificationChannel(channel)
    }

    private fun buildNotification(): Notification {
        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(this, EXPORT_CHANNEL_ID)
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(this)
        }

        return builder
            .setSmallIcon(android.R.drawable.stat_sys_upload)
            .setContentTitle("Langgeng Clip export")
            .setContentText("Export running...")
            .setOngoing(true)
            .setProgress(100, 0, false)
            .build()
    }

    companion object {
        const val EXPORT_NOTIFICATION_ID = 3101
        const val EXPORT_CHANNEL_ID = "langgeng_clip_exports"
    }
}
