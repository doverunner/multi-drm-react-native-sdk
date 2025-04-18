//
//  DownloadState.swift
//  FairPlayReactNativeSdk
//
//  Created by sungju Yun on 2023/03/29.
//  Copyright © 2023 DOVERUNNER. All rights reserved.
//

import Foundation

enum DownloadState {
    case downloading
    case completed
    case pause
    case not
}

extension DownloadState {
    var name: String {
        switch self {
        case .downloading: return "DOWNLOADING"
        case .completed: return "COMPLETED"
        case .pause: return "PAUSED"
        case .not: return "NOT"
        }
    }
}
