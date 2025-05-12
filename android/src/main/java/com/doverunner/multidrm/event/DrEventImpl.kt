package com.doverunner.multidrm.event

import android.os.Looper
import com.doverunner.multidrm.models.EventMessage
import com.doverunner.multidrm.models.EventType
import com.doverunner.widevine.model.ContentData
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import com.facebook.react.bridge.ReactContext
import com.facebook.react.modules.core.DeviceEventManagerModule.RCTDeviceEventEmitter

class DrEventImpl(private val reactContext: ReactContext
): DrEvent {
    override fun sendDrEvent(
        contentData: ContentData,
        eventType: EventType,
        message: String,
        errorCode: String
    ) {
        sendDrEvent(contentData.contentId ?: "",
            contentData.url ?: "",
            eventType,
            message,
            errorCode)
    }

    override fun sendDrEvent(
        contentId: String?,
        url: String?,
        eventType: EventType,
        message: String,
        errorCode: String
    ) {
        if (Looper.getMainLooper().thread == Thread.currentThread()) {
            reactContext.getJSModule(RCTDeviceEventEmitter::class.java).emit(
                eventType.toString(),
                EventMessage(
                    eventType,
                    contentId ?: "",
                    url ?: "",
                    message,
                    errorCode
                ).toReactMap()
            )
        } else {
            GlobalScope.launch(Dispatchers.Main) {
                reactContext.getJSModule(RCTDeviceEventEmitter::class.java).emit(
                    eventType.toString(),
                    EventMessage(
                        eventType,
                        contentId ?: "",
                        url ?: "",
                        message,
                        errorCode
                    ).toReactMap()
                )
            }
        }
    }
}
