package com.doverunner.multidrm.models

import com.google.gson.Gson
import java.util.HashMap
import com.facebook.react.bridge.WritableMap
import com.facebook.react.bridge.Arguments

data class EventMessage(
    val eventType: EventType,
    val contentId: String,
    val url: String,
    val message: String = "",
    val errorCode: String = ""
) {
    fun toJson(): String {
        return Gson().toJson(this)
    }

    fun toMap(): MutableMap<String, Any> {
        val event: MutableMap<String, Any> = HashMap()
        event["eventType"] = eventType.toString()
        event["contentId"] = contentId
        event["url"] = url

        if (errorCode.isNotEmpty()) {
            event["errorCode"] = errorCode
        }

        if (message.isNotEmpty()) {
            event["message"] = message
        }

        return event
    }

    fun toReactMap(): WritableMap {
        val map = Arguments.createMap()
        map.putString("contentId", contentId)
        map.putString("url", url)
        map.putString("message", message)
        map.putString("errorCode", errorCode)
        return map
    }
}
