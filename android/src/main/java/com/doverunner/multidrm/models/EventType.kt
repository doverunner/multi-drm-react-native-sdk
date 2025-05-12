package com.doverunner.multidrm.models

enum class EventType(private var type: String) {
    Completed("complete"),
    Paused("pause"),
    Removed("remove"),
    Stop("stop"),
    ContentDataError("contentDataError"),
    DrmError("drmError"),
    LicenseServerError("licenseServerError"),
    DownloadError("downloadError"),
    NetworkConnectedError("networkConnectedError"),
    DetectedDeviceTimeModifiedError("detectedDeviceTimeModifiedError"),
    MigrationError("migrationError"),
    UnknownError("unknownError"),
    Progress("progress"),
    LicenseCipherError("licenseCipherError");

    override fun toString(): String {
        return type
    }
}
