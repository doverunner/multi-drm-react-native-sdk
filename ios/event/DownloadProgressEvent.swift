//
//  DownloadProgressEvent.swift
//  FairPlayReactNativeSdk
//
//  Created by sungju Yun on 2023/03/29.
//  Copyright © 2023 DoveRunner. All rights reserved.
//

import Foundation

protocol DownloadProgressEvent
{
    func sendProgressEvent(_ url: String, percent: Double, downloadedBytes: Int64)
}
