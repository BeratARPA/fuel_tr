package com.iscgames.fueltr

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.app.PendingIntent
import android.content.SharedPreferences
import android.widget.RemoteViews
import android.net.Uri
import es.antonborri.home_widget.HomeWidgetProvider
import es.antonborri.home_widget.HomeWidgetBackgroundIntent

class YakitWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.yakit_widget_layout)

            // Make the entire widget clickable to launch the app
            val intent = Intent(context, MainActivity::class.java)
            val pendingIntent = PendingIntent.getActivity(
                context,
                0,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)

            // Setup refresh button
            val refreshIntent = HomeWidgetBackgroundIntent.getBroadcast(
                context,
                Uri.parse("widget://refresh")
            )
            views.setOnClickPendingIntent(R.id.widget_btn_refresh, refreshIntent)

            val guncelleme = widgetData.getString("guncelleme", "Güncelleniyor...") ?: "Güncelleniyor..."
            views.setTextViewText(R.id.widget_title, "YakıtCep")
            views.setTextViewText(R.id.widget_guncelleme, guncelleme)

            // Clear container before adding
            views.removeAllViews(R.id.widget_table_container)
            
            val jsonStr = widgetData.getString("table_data", "[]") ?: "[]"
            try {
                val array = org.json.JSONArray(jsonStr)
                for (i in 0 until array.length()) {
                    val obj = array.getJSONObject(i)
                    val isHeader = obj.optBoolean("is_header", false)
                    
                    val rowView = RemoteViews(
                        context.packageName, 
                        if (isHeader) R.layout.widget_row_header else R.layout.widget_row_item
                    )
                    
                    rowView.setTextViewText(R.id.row_name, obj.getString("name"))
                    
                    if (!isHeader) {
                        rowView.setTextViewText(R.id.row_benzin, obj.getString("benzin"))
                        rowView.setTextViewText(R.id.row_motorin, obj.getString("motorin"))
                        rowView.setTextViewText(R.id.row_lpg, obj.getString("lpg"))
                    }
                    
                    views.addView(R.id.widget_table_container, rowView)
                }
            } catch (e: Exception) {
                e.printStackTrace()
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
