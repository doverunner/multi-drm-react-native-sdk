package com.doverunner.multidrm.models

enum class SuccessType(type: String) {
    DownloadComplete("A001"),
    DownloadPaused("A002"),
    DownloadRemoved("A003"),
    DownloadProgress("A004"),
    DownloadStop("A005")
}
