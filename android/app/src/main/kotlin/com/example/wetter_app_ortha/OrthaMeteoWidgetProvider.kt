package com.example.wetter_app_ortha

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class OrthaMeteoWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: android.content.SharedPreferences,
    ) {
        appWidgetIds.forEach { appWidgetId ->
            val views = RemoteViews(
                context.packageName,
                R.layout.ortha_meteo_widget,
            )

            val place = widgetData.getString(
                "place",
                "Ort auswählen",
            ) ?: "Ort auswählen"

            val widgetDataVersion = widgetData.getInt(
                "widget_data_version",
                0,
            )

            val storedWarningLevel = widgetData.getString(
                "warning_level",
                "green",
            )?.trim()?.lowercase() ?: "green"

            /*
             * Alte Widget-Datensätze können noch veraltete Warnwerte enthalten.
             * Sie werden grundsätzlich nicht mehr als aktive Warnung übernommen.
             *
             * Erst ein vollständig von Flutter geschriebener Datensatz der
             * aktuellen Version darf Grün, Gelb, Orange oder Rot anzeigen.
             */
            val warningLevel =
                if (widgetDataVersion >= 2) {
                    when (storedWarningLevel) {
                        "green",
                        "yellow",
                        "orange",
                        "red",
                        -> storedWarningLevel

                        else -> "green"
                    }
                } else {
                    "green"
                }

            views.setTextViewText(
                R.id.ortha_widget_place,
                "$place  ›",
            )

            views.setTextViewText(
                R.id.ortha_widget_temperature,
                widgetData.getString(
                    "temperature",
                    "-- °C",
                ) ?: "-- °C",
            )

            views.setTextViewText(
                R.id.ortha_widget_apparent_temperature,
                widgetData.getString(
                    "apparent_temperature",
                    "Gefühlt -- °C",
                ) ?: "Gefühlt -- °C",
            )

            views.setTextViewText(
                R.id.ortha_widget_symbol,
                widgetData.getString(
                    "weather_symbol",
                    "–",
                ) ?: "–",
            )

            views.setTextViewText(
                R.id.ortha_widget_warning,
                warningLabelForLevel(warningLevel),
            )

            views.setTextViewText(
                R.id.ortha_widget_updated,
                "Aktualisiert: ${
                    widgetData.getString(
                        "observation_time",
                        "--:--",
                    ) ?: "--:--"
                }",
            )

            for (index in 1..3) {
                setDayData(
                    views = views,
                    widgetData = widgetData,
                    index = index,
                )
            }

            applyWarningState(
                views = views,
                warningLevel = warningLevel,
            )

            val launchIntent =
                context.packageManager.getLaunchIntentForPackage(
                    context.packageName,
                ) ?: Intent(context, MainActivity::class.java)

            launchIntent.flags =
                Intent.FLAG_ACTIVITY_NEW_TASK or
                    Intent.FLAG_ACTIVITY_CLEAR_TOP or
                    Intent.FLAG_ACTIVITY_SINGLE_TOP

            val openAppIntent = PendingIntent.getActivity(
                context,
                appWidgetId,
                launchIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or
                    PendingIntent.FLAG_IMMUTABLE,
            )

            views.setOnClickPendingIntent(
                R.id.ortha_widget_root,
                openAppIntent,
            )

            views.setOnClickPendingIntent(
                R.id.ortha_widget_place,
                openAppIntent,
            )

            views.setOnClickPendingIntent(
                R.id.ortha_widget_refresh,
                openAppIntent,
            )

            appWidgetManager.updateAppWidget(
                appWidgetId,
                views,
            )
        }
    }

    private fun setDayData(
        views: RemoteViews,
        widgetData: android.content.SharedPreferences,
        index: Int,
    ) {
        val labelId = when (index) {
            1 -> R.id.ortha_widget_day_1_label
            2 -> R.id.ortha_widget_day_2_label
            else -> R.id.ortha_widget_day_3_label
        }

        val symbolId = when (index) {
            1 -> R.id.ortha_widget_day_1_symbol
            2 -> R.id.ortha_widget_day_2_symbol
            else -> R.id.ortha_widget_day_3_symbol
        }

        val temperatureId = when (index) {
            1 -> R.id.ortha_widget_day_1_temperature
            2 -> R.id.ortha_widget_day_2_temperature
            else -> R.id.ortha_widget_day_3_temperature
        }

        views.setTextViewText(
            labelId,
            widgetData.getString(
                "day_${index}_label",
                "–",
            ) ?: "–",
        )

        views.setTextViewText(
            symbolId,
            widgetData.getString(
                "day_${index}_symbol",
                "–",
            ) ?: "–",
        )

        views.setTextViewText(
            temperatureId,
            widgetData.getString(
                "day_${index}_temperature",
                "– / –",
            ) ?: "– / –",
        )
    }

    private fun warningLabelForLevel(
        warningLevel: String,
    ): String {
        return when (warningLevel) {
            "red" -> "● Amtliche Warnung – Rot"
            "orange" -> "● Amtliche Warnung – Orange"
            "yellow" -> "● Amtliche Warnung – Gelb"
            else -> "● Keine amtliche Warnung"
        }
    }

    private fun applyWarningState(
        views: RemoteViews,
        warningLevel: String,
    ) {
        val inactive = Color.parseColor("#39464E")
        val green = Color.parseColor("#77D6A6")
        val yellow = Color.parseColor("#FFD54F")
        val orange = Color.parseColor("#FF9800")
        val red = Color.parseColor("#EF5350")

        val normalizedLevel = when (warningLevel) {
            "red",
            "orange",
            "yellow",
            "green",
            -> warningLevel

            else -> "green"
        }

        val redLightColor =
            if (normalizedLevel == "red") {
                red
            } else {
                inactive
            }

        val yellowLightColor =
            when (normalizedLevel) {
                "yellow" -> yellow
                "orange" -> orange
                else -> inactive
            }

        val greenLightColor =
            if (normalizedLevel == "green") {
                green
            } else {
                inactive
            }

        val warningTextColor =
            when (normalizedLevel) {
                "red" -> red
                "orange" -> orange
                "yellow" -> yellow
                else -> green
            }

        views.setTextColor(
            R.id.ortha_widget_light_red,
            redLightColor,
        )

        views.setTextColor(
            R.id.ortha_widget_light_yellow,
            yellowLightColor,
        )

        views.setTextColor(
            R.id.ortha_widget_light_green,
            greenLightColor,
        )

        views.setTextColor(
            R.id.ortha_widget_warning,
            warningTextColor,
        )
    }
}

