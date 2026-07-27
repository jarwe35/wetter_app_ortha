package com.example.wetter_app_ortha

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.graphics.Color
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class OrthaMeteoWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        appWidgetIds.forEach { appWidgetId ->
            val views = RemoteViews(
                context.packageName,
                R.layout.ortha_meteo_widget,
            )

            val place =
                widgetData.getString(
                    "place",
                    "Ort auswählen",
                ) ?: "Ort auswählen"

            val widgetDataVersion =
                widgetData.getInt(
                    "widget_data_version",
                    0,
                )

            val storedWarningLevel =
                widgetData.getString(
                    "warning_level",
                    "green",
                )?.trim()?.lowercase() ?: "green"

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

            val settings = readWidgetSettings(widgetData)

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

            applyContentVisibility(
                views = views,
                settings = settings,
            )

            applyWidgetAppearance(
                views = views,
                settings = settings,
                context = context,
            )

            applyWarningState(
                views = views,
                warningLevel = warningLevel,
                visible = settings.showWarningLight,
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

    private fun readWidgetSettings(
        widgetData: SharedPreferences,
    ): WidgetSettings {
        return WidgetSettings(
            backgroundStyle =
                widgetData.getString(
                    "widget_background_style",
                    "gradient",
                )?.trim()?.lowercase() ?: "gradient",
            themeStyle =
                widgetData.getString(
                    "widget_theme_style",
                    "dark",
                )?.trim()?.lowercase() ?: "dark",
            transparencyPercent =
                widgetData.getInt(
                    "widget_transparency",
                    12,
                ).coerceIn(0, 40),
            showPlace =
                readVisibilityFlag(
                    widgetData = widgetData,
                    key = "widget_show_place",
                    defaultValue = true,
                ),
            showTemperature =
                readVisibilityFlag(
                    widgetData = widgetData,
                    key = "widget_show_temperature",
                    defaultValue = true,
                ),
            showWeatherIcon =
                readVisibilityFlag(
                    widgetData = widgetData,
                    key = "widget_show_weather_icon",
                    defaultValue = true,
                ),
            showWarningLight =
                readVisibilityFlag(
                    widgetData = widgetData,
                    key = "widget_show_warning_light",
                    defaultValue = true,
                ),
        )
    }

    private fun readVisibilityFlag(
        widgetData: SharedPreferences,
        key: String,
        defaultValue: Boolean,
    ): Boolean {
        val storedValue = widgetData.all[key]

        return when (storedValue) {
            is Boolean -> storedValue
            is Int -> storedValue != 0
            is Long -> storedValue != 0L
            is String ->
                when (storedValue.trim().lowercase()) {
                    "1",
                    "true",
                    "yes",
                    "on",
                    -> true

                    "0",
                    "false",
                    "no",
                    "off",
                    -> false

                    else -> defaultValue
                }

            else -> defaultValue
        }
    }

    private fun applyContentVisibility(
        views: RemoteViews,
        settings: WidgetSettings,
    ) {
        views.setViewVisibility(
            R.id.ortha_widget_place,
            visibility(settings.showPlace),
        )

        views.setViewVisibility(
            R.id.ortha_widget_temperature,
            visibility(settings.showTemperature),
        )

        views.setViewVisibility(
            R.id.ortha_widget_apparent_temperature,
            visibility(settings.showTemperature),
        )

        views.setViewVisibility(
            R.id.ortha_widget_symbol,
            visibility(settings.showWeatherIcon),
        )

        views.setViewVisibility(
            R.id.ortha_widget_light_green,
            visibility(settings.showWarningLight),
        )

        views.setViewVisibility(
            R.id.ortha_widget_light_yellow,
            visibility(settings.showWarningLight),
        )

        views.setViewVisibility(
            R.id.ortha_widget_light_red,
            visibility(settings.showWarningLight),
        )

        views.setViewVisibility(
            R.id.ortha_widget_warning,
            visibility(settings.showWarningLight),
        )
    }

    private fun applyWidgetAppearance(
        views: RemoteViews,
        settings: WidgetSettings,
        context: Context,
    ) {
        val systemUsesDarkTheme =
            (
                context.resources.configuration.uiMode and
                    android.content.res.Configuration.UI_MODE_NIGHT_MASK
            ) == android.content.res.Configuration.UI_MODE_NIGHT_YES

        val useLightTheme =
            when (settings.themeStyle) {
                "light" -> true
                "automatic" -> !systemUsesDarkTheme
                else -> false
            }

        val baseBackground =
            when {
                useLightTheme &&
                    settings.backgroundStyle == "solid" ->
                    Color.rgb(226, 235, 241)

                useLightTheme ->
                    Color.rgb(198, 220, 234)

                settings.backgroundStyle == "solid" ->
                    Color.rgb(5, 16, 24)

                else ->
                    Color.rgb(8, 43, 65)
            }

        val alpha =
            ((100 - settings.transparencyPercent) * 255 / 100)
                .coerceIn(0, 255)

        val backgroundColor =
            Color.argb(
                alpha,
                Color.red(baseBackground),
                Color.green(baseBackground),
                Color.blue(baseBackground),
            )

        views.setInt(
            R.id.ortha_widget_root,
            "setBackgroundColor",
            backgroundColor,
        )

        val primaryText =
            if (useLightTheme) {
                Color.rgb(17, 37, 51)
            } else {
                Color.WHITE
            }

        val secondaryText =
            if (useLightTheme) {
                Color.rgb(67, 91, 106)
            } else {
                Color.rgb(129, 152, 168)
            }

        val accentText =
            if (useLightTheme) {
                Color.rgb(0, 102, 153)
            } else {
                Color.rgb(57, 185, 241)
            }

        val primaryTextIds =
            intArrayOf(
                R.id.ortha_widget_title,
                R.id.ortha_widget_place,
                R.id.ortha_widget_temperature,
                R.id.ortha_widget_day_1_label,
                R.id.ortha_widget_day_1_temperature,
                R.id.ortha_widget_day_2_label,
                R.id.ortha_widget_day_2_temperature,
                R.id.ortha_widget_day_3_label,
                R.id.ortha_widget_day_3_temperature,
            )

        primaryTextIds.forEach { id ->
            views.setTextColor(id, primaryText)
        }

        views.setTextColor(
            R.id.ortha_widget_apparent_temperature,
            accentText,
        )

        views.setTextColor(
            R.id.ortha_widget_updated,
            secondaryText,
        )
    }

    private fun visibility(visible: Boolean): Int {
        return if (visible) {
            View.VISIBLE
        } else {
            View.GONE
        }
    }

    private fun setDayData(
        views: RemoteViews,
        widgetData: SharedPreferences,
        index: Int,
    ) {
        val labelId =
            when (index) {
                1 -> R.id.ortha_widget_day_1_label
                2 -> R.id.ortha_widget_day_2_label
                else -> R.id.ortha_widget_day_3_label
            }

        val symbolId =
            when (index) {
                1 -> R.id.ortha_widget_day_1_symbol
                2 -> R.id.ortha_widget_day_2_symbol
                else -> R.id.ortha_widget_day_3_symbol
            }

        val temperatureId =
            when (index) {
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
        visible: Boolean,
    ) {
        if (!visible) {
            return
        }

        val inactive = Color.parseColor("#39464E")
        val green = Color.parseColor("#77D6A6")
        val yellow = Color.parseColor("#FFD54F")
        val orange = Color.parseColor("#FF9800")
        val red = Color.parseColor("#EF5350")

        val normalizedLevel =
            when (warningLevel) {
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

    private data class WidgetSettings(
        val backgroundStyle: String,
        val themeStyle: String,
        val transparencyPercent: Int,
        val showPlace: Boolean,
        val showTemperature: Boolean,
        val showWeatherIcon: Boolean,
        val showWarningLight: Boolean,
    )
}
