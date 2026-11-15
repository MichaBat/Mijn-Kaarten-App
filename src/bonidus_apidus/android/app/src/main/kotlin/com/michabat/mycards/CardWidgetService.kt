package com.michabat.mycards

import android.content.Intent
import android.widget.RemoteViewsService

class CardWidgetService : RemoteViewsService() {
    override fun onGetViewFactory(intent: Intent): RemoteViewsFactory {
        return CardWidgetFactory(applicationContext)
    }
}
