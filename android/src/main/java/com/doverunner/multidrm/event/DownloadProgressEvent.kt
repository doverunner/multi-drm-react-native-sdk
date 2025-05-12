package com.doverunner.multidrm.event

import com.doverunner.widevine.model.ContentData

interface DownloadProgressEvent {
    fun sendProgressEvent(contentData: ContentData, percent: Float, downloadedBytes: Long)
}