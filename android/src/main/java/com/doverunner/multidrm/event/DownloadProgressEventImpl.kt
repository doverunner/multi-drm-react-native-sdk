package com.doverunner.multidrm.event

import android.os.Looper
import com.doverunner.multidrm.models.ProgressMessage
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import com.facebook.react.bridge.ReactContext
import com.facebook.react.modules.core.DeviceEventManagerModule.RCTDeviceEventEmitter
import com.doverunner.multidrm.models.EventType
import com.doverunner.widevine.model.ContentData

class DownloadProgressEventImpl(private val reactContext: ReactContext
): DownloadProgressEvent {

    override fun sendProgressEvent(contentData: ContentData, percent: Float, downloadedBytes: Long) {
        if (Looper.getMainLooper().thread == Thread.currentThread()) {
            reactContext.getJSModule(RCTDeviceEventEmitter::class.java).emit(
                EventType.Progress.toString(),
                ProgressMessage(
                    contentData.contentId ?: "",
                    contentData.url ?: "",
                    percent,
                    downloadedBytes
                ).toReactMap()
            )
        } else {
            GlobalScope.launch(Dispatchers.Main) {
                reactContext.getJSModule(RCTDeviceEventEmitter::class.java).emit(
                    EventType.Progress.toString(),
                    ProgressMessage(
                        contentData.contentId ?: "",
                        contentData.url ?: "",
                        percent,
                        downloadedBytes
                    ).toReactMap()
                )
            }
        }
    }
}
