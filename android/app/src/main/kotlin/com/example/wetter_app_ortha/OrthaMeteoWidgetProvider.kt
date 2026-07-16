package com.example.wetter_app_ortha

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews

class OrthaMeteoWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        val launchIntent = context.packageManager
            .getLaunchIntentForPackage(context.packageName)
            ?: Intent(context, MainActivity::class.java)

        launchIntent.flags =
            Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP

        val openAppIntent = PendingIntent.getActivity(
            context,
            0,
            launchIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(
                context.packageName,
                R.layout.ortha_meteo_widget,
            )

            views.setOnClickPendingIntent(
                R.id.ortha_widget_root,
                openAppIntent,
            )

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
