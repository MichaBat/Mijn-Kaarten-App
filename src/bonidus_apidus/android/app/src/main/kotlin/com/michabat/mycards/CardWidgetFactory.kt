package com.michabat.mycards

import android.content.Context
import android.content.Intent
import android.graphics.BitmapFactory
import android.graphics.Color
import android.net.Uri
import android.view.View
import android.widget.RemoteViews
import android.widget.RemoteViewsService
import es.antonborri.home_widget.HomeWidgetPlugin
import org.json.JSONArray

private data class PinnedCard(
    val id: Int,
    val logoPath: String?,
    val dominantColor: String?,
)

private const val DEFAULT_CARD_COLOR = 0xFFD4956A.toInt()

private fun parseCardColor(hex: String?): Int {
    if (hex == null) return DEFAULT_CARD_COLOR
    return try {
        Color.parseColor(if (hex.startsWith("#")) hex else "#$hex")
    } catch (e: IllegalArgumentException) {
        DEFAULT_CARD_COLOR
    }
}

class CardWidgetFactory(private val context: Context) : RemoteViewsService.RemoteViewsFactory {
    private var cards: List<PinnedCard> = emptyList()

    override fun onCreate() {}

    override fun onDataSetChanged() {
        val prefs = HomeWidgetPlugin.getData(context)
        val json = prefs.getString("pinned_cards", null)
        cards = if (json == null) {
            emptyList()
        } else {
            try {
                val array = JSONArray(json)
                (0 until array.length()).map { i ->
                    val obj = array.getJSONObject(i)
                    PinnedCard(
                        id = obj.getInt("id"),
                        logoPath = if (obj.isNull("logoPath")) null else obj.optString("logoPath", null),
                        dominantColor = if (obj.isNull("dominantColor")) null else obj.optString("dominantColor", null),
                    )
                }
            } catch (e: Exception) {
                emptyList()
            }
        }
    }

    override fun onDestroy() {
        cards = emptyList()
    }

    override fun getCount(): Int = cards.size

    override fun getViewAt(position: Int): RemoteViews {
        val card = cards[position]
        val views = RemoteViews(context.packageName, R.layout.card_widget_item)

        views.setInt(R.id.widget_item_root, "setBackgroundColor", parseCardColor(card.dominantColor))

        val bitmap = card.logoPath?.let { BitmapFactory.decodeFile(it) }
        if (bitmap != null) {
            views.setImageViewBitmap(R.id.widget_item_logo, bitmap)
            views.setViewVisibility(R.id.widget_item_logo, View.VISIBLE)
        } else {
            views.setViewVisibility(R.id.widget_item_logo, View.GONE)
        }

        val fillInIntent = Intent()
        fillInIntent.data = Uri.parse("bonidusapidus://card/${card.id}")
        views.setOnClickFillInIntent(R.id.widget_item_root, fillInIntent)

        return views
    }

    override fun getLoadingView(): RemoteViews? = null

    override fun getViewTypeCount(): Int = 1

    override fun getItemId(position: Int): Long = cards[position].id.toLong()

    override fun hasStableIds(): Boolean = true
}
