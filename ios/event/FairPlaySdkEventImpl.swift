//
//  PallyConEventImpl.swift
//  RNPallyConDrmSdk
//
//  Created by sungju Yun on 2023/03/29.
//  Copyright © 2023 Facebook. All rights reserved.
//

import Foundation

class FairPlaySdkEventImpl: PallyConEvent
{
    public var emitter: RCTEventEmitter?
    
    init(emitter: RCTEventEmitter) {
        self.emitter = emitter
    }
    
    func sendFairPlaySdkEvent(_ url: String, eventType: PallyConEventType, message: String, errorCode: String = "") {
        if (!Thread.isMainThread) {
            DispatchQueue.main.sync {
                emitter?.sendEvent(withName: eventType.name, body: ["url": url, "message": message, "errorCode": errorCode])
            }
        } else {
            emitter?.sendEvent(withName: eventType.name, body: ["url": url, "message": message, "errorCode": errorCode])
        }
    }
}
