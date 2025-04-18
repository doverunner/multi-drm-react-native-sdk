//
//  PallyConEvent.swift
//  RNPallyConDrmSdk
//
//  Created by sungju Yun on 2023/03/29.
//  Copyright © 2023 Facebook. All rights reserved.
//

import Foundation

protocol PallyConEvent
{
    func sendFairPlaySdkEvent(_ url: String, eventType: PallyConEventType, message: String, errorCode: String)
}
