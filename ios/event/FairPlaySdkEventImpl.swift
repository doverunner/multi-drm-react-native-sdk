//
//  FairPlaySdkEventImpl.swift
//  FairPlayReactNativeSdk
//
//  Created by sungju Yun on 2023/03/29.
//  Copyright © 2023 DoveRunner. All rights reserved.
//

import Foundation

class FairPlaySdkEventImpl: FairPlaySdkEvent
{
    public var emitter: RCTEventEmitter?
    
    init(emitter: RCTEventEmitter) {
        self.emitter = emitter
    }
    
    func sendFairPlaySdkEvent(_ url: String, eventType: FairPlaySdkEventType, message: String, errorCode: String = "") {
        if (!Thread.isMainThread) {
            DispatchQueue.main.sync {
                emitter?.sendEvent(withName: eventType.name, body: ["url": url, "message": message, "errorCode": errorCode])
            }
        } else {
            emitter?.sendEvent(withName: eventType.name, body: ["url": url, "message": message, "errorCode": errorCode])
        }
    }
}
