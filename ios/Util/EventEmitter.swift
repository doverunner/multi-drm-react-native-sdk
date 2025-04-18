//
//  EventEmitter.swift
//  FairPlayReactNativeSdk
//
//  Created by sungju Yun on 2023/01/30.
//  Copyright © 2023 DOVERUNNER. All rights reserved.
//

import Foundation

class EventEmitter {

    public static var shared = EventEmitter()

// Events sent to ReactNative are implemented in FairPlaySdkEventImpl.
//    private var eventEmitter: FairPlayReactNativeSdk!
//    
//    func register(eventEmitter: FairPlayReactNativeSdk) {
//        self.eventEmitter = eventEmitter
//    }
//
//    func emit(event: FairPlaySdkEventType, body: Any?) {
//        self.eventEmitter.sendEvent(withName: event.name, body: body)
//    }

    var allEvents = [
        FairPlaySdkEventType.complete.name,
        FairPlaySdkEventType.download.name,
        FairPlaySdkEventType.pause.name,
        FairPlaySdkEventType.remove.name,
        FairPlaySdkEventType.stop.name,
        FairPlaySdkEventType.contentDataError.name,
        FairPlaySdkEventType.drmError.name,
        FairPlaySdkEventType.licenseServerError.name,
        FairPlaySdkEventType.downloadError.name,
        FairPlaySdkEventType.networkConnectedError.name,
        FairPlaySdkEventType.detectedDeviceTimeModifiedError.name,
        FairPlaySdkEventType.migrationError.name,
        FairPlaySdkEventType.licenseCipherError.name,
        FairPlaySdkEventType.unknownError.name,
        FairPlaySdkEventType.progress.name,
    ]
}
