package com.afterglowjournal.afterglow

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.view.View
import android.widget.RemoteViews

/**
 * 2×1 home-screen widget: today's recovery status and a "Log event" button
 * that opens the app straight into the log sheet (PRD §7.2).
 *
 * The status is recomputed here from the episode start time, so "Day N"
 * stays right without the app running. It's hidden entirely when app lock
 * is on. Nothing sensitive is ever shown: only "Day 2 of ~4" style text.
 */
class LogWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray) {
        for (id in ids) manager.updateAppWidget(id, views(context))
    }

    companion object {
        private const val PREFS = "afterglow_widget"
        private const val DAY_MS = 24L * 60 * 60 * 1000

        fun save(context: Context, episodeStart: Long, expectedDays: Int, hideStatus: Boolean) {
            context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit()
                .putLong("episodeStart", episodeStart)
                .putInt("expectedDays", expectedDays)
                .putBoolean("hideStatus", hideStatus)
                .apply()
            val manager = AppWidgetManager.getInstance(context)
            val ids = manager.getAppWidgetIds(ComponentName(context, LogWidgetProvider::class.java))
            for (id in ids) manager.updateAppWidget(id, views(context))
        }

        private fun status(context: Context): String? {
            val p = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            if (p.getBoolean("hideStatus", false)) return null
            val start = p.getLong("episodeStart", -1L)
            if (start < 0) return "Feeling normal"
            val day = ((System.currentTimeMillis() - start) / DAY_MS + 1).coerceAtLeast(1)
            val expected = p.getInt("expectedDays", 0)
            return if (expected > 0) "Day $day of ~$expected" else "Day $day"
        }

        private fun views(context: Context): RemoteViews {
            val rv = RemoteViews(context.packageName, R.layout.log_widget)
            val status = status(context)
            if (status == null) {
                rv.setViewVisibility(R.id.widget_status, View.GONE)
            } else {
                rv.setViewVisibility(R.id.widget_status, View.VISIBLE)
                rv.setTextViewText(R.id.widget_status, status)
            }
            rv.setOnClickPendingIntent(R.id.widget_log, launch(context, "afterglow://log", 1))
            rv.setOnClickPendingIntent(R.id.widget_root, launch(context, null, 0))
            return rv
        }

        private fun launch(context: Context, uri: String?, requestCode: Int): PendingIntent {
            val intent = Intent(context, MainActivity::class.java).apply {
                action = Intent.ACTION_VIEW
                if (uri != null) data = Uri.parse(uri)
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            return PendingIntent.getActivity(
                context, requestCode, intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
        }
    }
}
