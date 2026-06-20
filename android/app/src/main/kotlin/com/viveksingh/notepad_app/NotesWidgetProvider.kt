package com.viveksingh.notepad_app

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class NotesWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: android.content.SharedPreferences,
    ) {
        for (appWidgetId in appWidgetIds) {
            try {
                val titles = widgetData.getString(
                    "note_titles",
                    "Open the app to load your notes.",
                ) ?: "Open the app to load your notes."
                val count = widgetData.getInt("note_count", 0)

                val views = RemoteViews(context.packageName, R.layout.notes_widget).apply {
                    setTextViewText(R.id.widget_title, "Secure Notepad")
                    setTextViewText(R.id.widget_count, "$count notes")
                    setTextViewText(R.id.widget_notes, titles)

                    val intent = Intent(context, MainActivity::class.java).apply {
                        flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                    }
                    val pendingIntent = PendingIntent.getActivity(
                        context,
                        appWidgetId,
                        intent,
                        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
                    )
                    setOnClickPendingIntent(R.id.widget_root, pendingIntent)
                }

                appWidgetManager.updateAppWidget(appWidgetId, views)
            } catch (_: Exception) {
                val fallback = RemoteViews(context.packageName, R.layout.notes_widget_preview)
                appWidgetManager.updateAppWidget(appWidgetId, fallback)
            }
        }
    }
}
