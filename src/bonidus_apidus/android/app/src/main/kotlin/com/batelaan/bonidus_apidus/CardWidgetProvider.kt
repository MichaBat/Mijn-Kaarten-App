package com.batelaan.bonidus_apidus

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.net.Uri
import android.os.Build
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class CardWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        for (widgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.card_widget)

            val serviceIntent = Intent(context, CardWidgetService::class.java)
            serviceIntent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, widgetId)
            // Each widget instance needs a distinct Intent, otherwise Android reuses the
            // same RemoteViewsFactory for every instance of this widget.
            serviceIntent.data = Uri.parse("content://com.batelaan.bonidus_apidus/widget/$widgetId")
            views.setRemoteAdapter(R.id.widget_list_view, serviceIntent)
            views.setEmptyView(R.id.widget_list_view, R.id.widget_empty_view)

            // Built manually (instead of via HomeWidgetLaunchIntent.getActivity, which
            // always sets FLAG_IMMUTABLE) because a collection-widget click template
            // must be mutable: Android fills in each item's data URI (from
            // setOnClickFillInIntent) into this template at click time, and that
            // fill-in is silently dropped for immutable PendingIntents.
            val launchIntent = Intent(context, MainActivity::class.java)
            launchIntent.action = HomeWidgetLaunchIntent.HOME_WIDGET_LAUNCH_ACTION

            var templateFlags = PendingIntent.FLAG_UPDATE_CURRENT
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                templateFlags = templateFlags or PendingIntent.FLAG_MUTABLE
            }
            val templatePendingIntent =
                PendingIntent.getActivity(context, 0, launchIntent, templateFlags)
            views.setPendingIntentTemplate(R.id.widget_list_view, templatePendingIntent)

            appWidgetManager.updateAppWidget(widgetId, views)
            appWidgetManager.notifyAppWidgetViewDataChanged(widgetId, R.id.widget_list_view)
        }
    }
}
