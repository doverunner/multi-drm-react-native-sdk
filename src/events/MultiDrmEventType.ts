/// Event type of multi-drm SDK Event
export enum MultiDrmEventType {
    /// The download completed
    complete = 'complete',
    /// The download paused
    pause = 'pause',
    /// The download is removed
    remove = 'remove',
    /// The download is stop
    stop = 'stop',
    /// The download is start
    download = 'download',
    /// Error when the content information to be downloaded is incorrect
    /// It mainly occurs when the value of the function parameter [DrmContentConfiguration] is incorrect.
    contentDataError = 'contentDataError',
    /// License error
    drmError = 'drmError',
    /// Server error when issuing license
    licenseServerError = 'licenseServerError',
    /// Error during download
    downloadError = 'downloadError',
    /// Error when there is no network connection
    networkConnectedError = 'networkConnectedError',
    /// Error that occurs when the time is forcibly manipulated on an Android device
    detectedDeviceTimeModifiedError = 'detectedDeviceTimeModifiedError',
    /// Error that occurs when migrating from SDK
    migrationError = 'migrationError',
    /// Error that occurs when licenseCipher from SDK
    licenseCipherError = 'licenseCipherError',
    /// Unknown error type
    unknownError = 'unknownError',
    /// Download progress data
    progress = 'progress'
}
