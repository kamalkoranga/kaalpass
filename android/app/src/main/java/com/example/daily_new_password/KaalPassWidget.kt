package com.example.daily_new_password

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

/**
 * Implementation of App Widget functionality.
 */
class KaalPassWidget : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        // There may be multiple widgets active, so update all of them
        for (appWidgetId in appWidgetIds) {
            // get data from flutter app
            val widgetData = HomeWidgetPlugin.getData(context)
            val password = widgetData.getString("today's_password", null) ?: "No text..."
            val views = RemoteViews(context.packageName, R.layout.kaal_pass_widget).apply {
                setTextViewText(
                    R.id.text_id,
                    password
                )
                val intent = Intent(context, KaalPassWidget::class.java).apply {
                    action = "me.klka.kaalpass.REFRESH_AND_COPY"
                }
                val pendingIntent = PendingIntent.getBroadcast(
                    context,
                    0,
                    intent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                setOnClickPendingIntent(R.id.widget_root, pendingIntent)
            }

            // update widget
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }

    override fun onReceive(context: Context?, intent: Intent?) {
        super.onReceive(context, intent)

        if (intent?.action == "me.klka.kaalpass.REFRESH_AND_COPY") {
            context?.let { ctx ->
                val widgetData = HomeWidgetPlugin.getData(ctx)
                val password = widgetData.getString("today's_password", null) ?: "No text..."

                val clipboard = ctx.getSystemService(Context.CLIPBOARD_SERVICE) as android.content.ClipboardManager
                val clip = android.content.ClipData.newPlainText("Password", password)
                clipboard.setPrimaryClip(clip)

                val manager = AppWidgetManager.getInstance(ctx)
                val thisWidget = ComponentName(ctx.packageName, KaalPassWidget::class.java.name)
                val ids = manager.getAppWidgetIds(thisWidget)

                for (appWidgetId in ids) {
                    val views = RemoteViews(ctx.packageName, R.layout.kaal_pass_widget)
                    views.setTextViewText(R.id.text_id, "    Copied!   ")
                    manager.updateAppWidget(appWidgetId, views)
                }

                android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
                    for (appWidgetId in ids) {
                        val views = RemoteViews(ctx.packageName, R.layout.kaal_pass_widget)
                        views.setTextViewText(R.id.text_id, password)
                        manager.updateAppWidget(appWidgetId, views)
                    }
                }, 1200)

            }

        }
    }

    override fun onEnabled(context: Context) {
        // Enter relevant functionality for when the first widget is created
    }

    override fun onDisabled(context: Context) {
        // Enter relevant functionality for when the last widget is disabled
    }
}

internal fun updateAppWidget(
    context: Context,
    appWidgetManager: AppWidgetManager,
    appWidgetId: Int
) {
    val widgetText = context.getString(R.string.appwidget_text)
    // Construct the RemoteViews object
    val views = RemoteViews(context.packageName, R.layout.kaal_pass_widget)
    views.setTextViewText(R.id.text_id, widgetText)

    // Instruct the widget manager to update the widget
    appWidgetManager.updateAppWidget(appWidgetId, views)
}