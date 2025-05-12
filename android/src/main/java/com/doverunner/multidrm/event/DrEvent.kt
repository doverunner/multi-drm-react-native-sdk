package com.doverunner.multidrm.event

import com.doverunner.multidrm.models.EventType
import com.doverunner.widevine.model.ContentData

interface DrEvent {
    fun sendDrEvent(contentData: ContentData,
                    eventType: EventType,
                    message: String,
                    errorCode: String = "")

    fun sendDrEvent(
        contentId: String?,
        url: String?,
        eventType: EventType,
        message: String,
        errorCode: String = "",
    )
}
