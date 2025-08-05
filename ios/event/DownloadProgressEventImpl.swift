//
//  DownloadProgressEventImpl.swift
//  FairPlayReactNativeSdk
//
//  Created by sungju Yun on 2023/03/29.
//  Copyright © 2023 DoveRunner. All rights reserved.
//

import Foundation

class DownloadProgressEventImpl: DownloadProgressEvent
{
    public var emitter: RCTEventEmitter?
    
    init(emitter: RCTEventEmitter) {
        self.emitter = emitter
    }
    
    func sendProgressEvent(_ url: String, percent: Double, downloadedBytes: Int64) {
        if (!Thread.isMainThread) {
            DispatchQueue.main.sync {
                emitter?.sendEvent(withName: FairPlaySdkEventType.progress.name, body: ["url": url, "percent": percent, "downloadedBytes": downloadedBytes])
            }
        } else {
            emitter?.sendEvent(withName: FairPlaySdkEventType.progress.name, body: ["url": url, "percent": percent, "downloadedBytes": downloadedBytes])
        }
    }
}
