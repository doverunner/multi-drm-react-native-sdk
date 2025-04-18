//
//  FairPlaySdkEvent.swift
//  FairPlayReactNativeSdk
//
//  Created by sungju Yun on 2023/03/29.
//  Copyright © 2023 DOVERUNNER. All rights reserved.
//

import Foundation

protocol FairPlaySdkEvent
{
    func sendFairPlaySdkEvent(_ url: String, eventType: FairPlaySdkEventType, message: String, errorCode: String)
}
