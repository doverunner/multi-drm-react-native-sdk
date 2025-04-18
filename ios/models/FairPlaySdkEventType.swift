import Foundation

enum FairPlaySdkEventType {
    case complete
    case download
    case pause
    case remove
    case stop
    case contentDataError
    case drmError
    case licenseServerError
    case downloadError
    case networkConnectedError
    case detectedDeviceTimeModifiedError
    case migrationError
    case licenseCipherError
    case unknownError
    case progress
}

extension FairPlaySdkEventType {
    var name: String {
        switch self {
        case .complete: return "complete"
        case .download: return "download"
        case .pause: return "pause"
        case .remove: return "remove"
        case .stop: return "stop"
        case .contentDataError: return "contentDataError"
        case .drmError: return "drmError"
        case .licenseServerError: return "licenseServerError"
        case .downloadError: return "downloadError"
        case .networkConnectedError: return "networkConnectedError"
        case .detectedDeviceTimeModifiedError: return "detectedDeviceTimeModifiedError"
        case .migrationError: return "migrationError"
        case .licenseCipherError: return "licenseCipherError"
        case .unknownError: return "unknownError"
        case .progress: return "progress"
        }
    }
}
