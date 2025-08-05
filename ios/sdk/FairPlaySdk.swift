import Foundation
import AVKit
import DoveRunnerFairPlay

struct DrmContent {
    let siteId: String
    let drmType: String
    var url: String
    var contentId: String
    var token: String
    var customData: String?
    var contentHttpHeader: Dictionary<String, String>?
    var licenseHttpHeader: Dictionary<String, String>?
    var contentCookie: String?
    var licenseCookie: String?
    var appleCertUrl: String?
    var drmLicenseUrl: String?
    var downloadState: DownloadState = DownloadState.not
    var downloadPath: String

    init(siteId: String, url: String, contentId: String, path: String) {
        self.init(siteId: siteId, drmType: "", url: url, contentId: contentId,
                  token: "", customData: "", contentHttpHeader: nil, licenseHttpHeader: nil, contentCookie: "", licenseCookie: "", drmLicenseUrl: "",
                  appleCertUrl: "",  downloadState: DownloadState.completed, path: path)
    }

    init(sitdeId: String, url: String, contentId: String, token: String) {
        self.init(siteId: sitdeId, drmType: "", url: url, contentId: contentId, token: token,
                  customData: "", contentHttpHeader: nil, licenseHttpHeader: nil, contentCookie: "", licenseCookie: "", drmLicenseUrl: "",
                  appleCertUrl: "", downloadState: DownloadState.not, path: "")
    }

    init(siteId: String, drmType: String, url: String, contentId: String, token: String, customData: String?,
        contentHttpHeader: Dictionary<String, String>?, licenseHttpHeader: Dictionary<String, String>?, contentCookie: String?,
        licenseCookie: String?, drmLicenseUrl: String?, appleCertUrl: String?, downloadState: DownloadState, path: String) {
        self.siteId = siteId
        self.drmType = drmType
        self.url = url
        self.contentId = contentId
        self.token = token
        self.customData = customData
        self.contentHttpHeader = contentHttpHeader
        self.licenseHttpHeader = licenseHttpHeader
        self.contentCookie = contentCookie
        self.licenseCookie = licenseCookie
        self.drmLicenseUrl = drmLicenseUrl
        self.appleCertUrl = appleCertUrl
        self.downloadState = downloadState
        self.downloadPath = path
    }

    func toFairPlayConfig() -> String {

        let customData = self.customData ?? ""
        let drmLicenseUrl = self.drmLicenseUrl ?? ""
        let certificateUrl = self.appleCertUrl ?? ""

        let configString = "{\"drmConfig\":{\"siteId\":\"\(self.siteId)\",\"contentId\":\"\(self.contentId)\",\"certificateUrl\":\"\(certificateUrl)\",\"drmLicenseUrl\":\"\(drmLicenseUrl)\",\"token\":\"\(self.token)\",\"customData\":\"\(customData)\"},\"url\":\"\(self.downloadPath)\"}"

        return configString
    }
}

class FairPlaySdk: NSObject {
    static let shared = FairPlaySdk()

    private var sdkEvent: FairPlaySdkEvent?
    private var progressEvent: DownloadProgressEvent?

    private var siteId: String = ""
    private var fpsSdk: DoveRunnerFairPlay?
    private var downloadTaskMap = [DownloadTask:DrmContent]()
    private var downloadedContentMap = [String:DrmContent]()

    static let baseDownloadURL: URL = URL(fileURLWithPath: NSHomeDirectory())

    public func setFairPlaySdkEvent(event: FairPlaySdkEvent?) {
        self.sdkEvent = event
    }

    public func setDownloadProgress(downloadProgressEvent: DownloadProgressEvent?) {
        self.progressEvent = downloadProgressEvent
    }

    public func initialize(siteId: String) {
        self.siteId = siteId
        fpsSdk = DoveRunnerFairPlay()
    }

    public func release()  {

    }

    public func getObjectForContent(url: String, contentId: String, token: String?,
                                    customData: String?, contentHttpHeaders: Dictionary<String, String>?,
                                    licenseHttpHeaders: Dictionary<String, String>?, contentCookie: String?, licenseCookie: String?,
                                    drmLicenseUrl: String?, appleCertUrl: String?) -> String {
        if var drmContent = downloadedContentMap[url] {
            drmContent.contentId = contentId
            drmContent.drmLicenseUrl = drmLicenseUrl
            drmContent.token = token ?? ""
            drmContent.contentHttpHeader = contentHttpHeaders
            drmContent.licenseHttpHeader = licenseHttpHeaders
            drmContent.contentCookie = contentCookie
            drmContent.licenseCookie = licenseCookie
            drmContent.customData = customData
            drmContent.appleCertUrl = appleCertUrl ?? ""
            downloadedContentMap[url] = drmContent
            return drmContent.toFairPlayConfig()
        } else {
            // Streaming
            let strToken = token ?? ""
            let strCustomData = customData ?? ""
            let strDrmLicenseUrl = drmLicenseUrl ?? ""
            let strDrmCertUrl = appleCertUrl ?? ""
            let configString = "{\"drmConfig\":{\"siteId\":\"\(self.siteId)\",\"contentId\":\"\(contentId)\",\"certificateUrl\":\"\(strDrmCertUrl)\",\"drmLicenseUrl\":\"\(strDrmLicenseUrl)\",\"token\":\"\(strToken)\",\"customData\":\"\(strCustomData)\"},\"url\":\"\(url)\"}"
            return configString
        }
    }

    public func getDownloadState(url: String) -> String {
        if let contentInfo = loadDownloadedContent(with: url, contentId: "") {
            downloadedContentMap[url] = contentInfo
            return DownloadState.completed.name
        }

        return DownloadState.not.name
    }

    public func addStartDownload(url: String, contentId: String, token: String?, customData: String?, contentHttpHeaders: Dictionary<String, String>?, licenseHttpHeaders: Dictionary<String, String>?, contentCookie: String?, licenseCookie: String?, drmLicenseUrl: String?, appleCertUrl: String?) {
//        sendFairPlaySdkEvent(url: url, eventType: FairPlaySdkEventType.complete, message: "Complete")
        for (task, downloadContent) in downloadTaskMap {
            print("download task \(downloadContent.contentId)")
            if downloadContent.url == url {
                print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
                task.resume()
                return
            }
        }

        guard let contentUrl:URL = URL(string: url) else {
            sdkEvent?.sendFairPlaySdkEvent(url, eventType: FairPlaySdkEventType.downloadError, message: "String to URL convert Error!", errorCode: "")
            return
        }
        
        let aseet = AVURLAsset(url: contentUrl)
        let config = FairPlayConfiguration(avURLAsset: aseet, contentId: contentId, certificateUrl: appleCertUrl!, authData: token, delegate: self )
        
        guard let downloadTask = fpsSdk?.createDownloadTask(drm: config, delegate: self) else {
            sdkEvent?.sendFairPlaySdkEvent(url, eventType: FairPlaySdkEventType.downloadError, message: "DownloadTask not Create! ", errorCode: "")
            return
        }

        let contentInfo = DrmContent(siteId: self.siteId, drmType: "", url: url, contentId: contentId,
                                     token: token!, customData: customData, contentHttpHeader: contentHttpHeaders,
                                     licenseHttpHeader: licenseHttpHeaders, contentCookie: contentCookie, licenseCookie: licenseCookie, drmLicenseUrl: drmLicenseUrl,
                                     appleCertUrl: "", downloadState: DownloadState.not, path: "")
        downloadTaskMap[downloadTask] = contentInfo
        downloadTask.resume()
    }

    public func resumeAll() {
        for task in downloadTaskMap.keys {
            task.resume()
            downloadTaskMap[task]?.downloadState = DownloadState.downloading
        }
    }

    public func cancelAll() {
        for task in downloadTaskMap.keys {
            task.cancel()
            downloadTaskMap[task]?.downloadState = DownloadState.pause
        }
    }

    public func pauseAll() {
        for task in downloadTaskMap.keys {
            if downloadTaskMap[task]?.downloadState == DownloadState.downloading {
                task.cancel()
                downloadTaskMap[task]?.downloadState = DownloadState.pause
                sdkEvent?.sendFairPlaySdkEvent(downloadTaskMap[task]!.url, eventType: FairPlaySdkEventType.pause, message: "User Downloaded Content Pause", errorCode: "")
            } else {
                task.resume()
                downloadTaskMap[task]?.downloadState = DownloadState.downloading
            }
        }
    }

    public func resumeDwonloadTask(_ contentId: String) {
        for (task, downloadContent) in downloadTaskMap {
            if downloadContent.contentId == contentId {
                task.resume()
                downloadTaskMap[task]?.downloadState = DownloadState.pause
                break
            }
        }
    }

    public func cancelDwonloadTask(_ contentId: String) {
        for (task, downloadContent) in downloadTaskMap {
            if downloadContent.contentId == contentId {
                task.cancel()
                downloadTaskMap[task]?.downloadState = DownloadState.pause
                break
            }
        }
    }

    public func removeDownload(url: String) {
        guard let downloadedContent = downloadedContentMap[url] else {
            return
        }
        self.deleteDowndloadedContent(for: downloadedContent)
        downloadedContentMap.removeValue(forKey: url)
        sdkEvent?.sendFairPlaySdkEvent(url, eventType: FairPlaySdkEventType.remove, message: "Remove Downloaded Content", errorCode: "")
    }

    public func removeLicense(url: String) {
        guard let downloadedContent = downloadedContentMap[url] else {
            return
        }
        try! self.fpsSdk?.removeLicense(contentId: downloadedContent.contentId)
    }
}


extension FairPlaySdk: FairPlayDownloadDelegate {
    func downloadContent(_ contentId: String, didStartDownloadWithAsset asset: AVURLAsset, subtitleDisplayName: String) {
        print("downloadContent : didStartDownloadWithAsset\(contentId) : \(subtitleDisplayName)")
        guard let downloadEvent = self.progressEvent else {
            print("downloadContent didStartDownloadWithAsset : downloadEvent")
            return
        }

        var contentUrl:String = ""
        for (downloadContent) in downloadTaskMap.values {
            if downloadContent.contentId == contentId {
                contentUrl = downloadContent.url
                break
            }
        }

        //downloadEvent(event)
        //setDownloadProgress(eventSink: downloadEvent)
    }

    func downloadContent(_ contentId: String, didStopWithError error: Error?) {
        print("downloadContent : didStopWithError \(contentId)")
        if let downloadError = error as NSError? {
            switch downloadError.code {
                case NSURLErrorCancelled:
                    // User cancellation is not a typical error, so no additional handling needed.
                    break
                case NSURLErrorNetworkConnectionLost:
                    showErrorAlert(title: "Network Error", message: "Connection was lost. Please try again.")
                case NSURLErrorTimedOut:
                    showErrorAlert(title: "Timeout Error", message: "Request timed out. Please try again later.")
                case NSURLErrorUnknown:
                    let detailedMessage = "Unknown error: \(downloadError.domain)\nCode: \(downloadError.code)\nDetails: \(downloadError.localizedDescription)"
                    showErrorAlert(title: "Download Failed", message: detailedMessage)
                default:
                    showErrorAlert(title: "Download Failed", message: "Error: \(downloadError.localizedDescription)")
            }
        }

        var contentUrl:String = ""
        for (task, downloadContent) in downloadTaskMap {
            if downloadContent.contentId == contentId {
                contentUrl = downloadContent.url
                downloadTaskMap.removeValue(forKey: task)
                break
            }
        }
        sdkEvent?.sendFairPlaySdkEvent(contentUrl, eventType: FairPlaySdkEventType.pause, message: "download stop : \(contentId)", errorCode: "")

    }

    func downloadContent(_ contentId: String, didFinishDownloadingTo location: URL) {
        print("downloadContent : didFinishDownloadingTo : \(location)")

        var contentUrl:String = ""
        for (task, downloadContent) in downloadTaskMap {
            if downloadContent.contentId == contentId {
                contentUrl = downloadContent.url
                self.saveDownloadedContent(for: downloadContent, location: location)
                downloadTaskMap.removeValue(forKey: task)
                break
            }
        }

        sdkEvent?.sendFairPlaySdkEvent(contentUrl, eventType: FairPlaySdkEventType.complete, message: "\(location.absoluteString)", errorCode: "")
        return
    }

    func downloadContent(_ contentId: String, didLoad timeRange: CMTimeRange, totalTimeRangesLoaded loadedTimeRanges: [NSValue], timeRangeExpectedToLoad: CMTimeRange) {
        //print("downloadContent : didFinishDownloadingTo : \(contentId)")
        var contentUrl:String = ""
        for (task, downloadContent) in downloadTaskMap {
            if downloadContent.contentId == contentId {
                contentUrl = downloadContent.url
                downloadTaskMap[task]?.downloadState = DownloadState.downloading
                break
            }
        }

        var percentComplete:Double = 0.0
        for value in loadedTimeRanges {
            let loadedTimeRange : CMTimeRange = value.timeRangeValue
            percentComplete += CMTimeGetSeconds(loadedTimeRange.duration) / CMTimeGetSeconds(timeRangeExpectedToLoad.duration)
        }

        progressEvent?.sendProgressEvent(contentUrl, percent: (percentComplete*100), downloadedBytes: 0)
//        self.setDownloadProgress(eventSink: downloadEvent)
        print("downloadContent : didFinishDownloadingTo : \(contentId) : \(percentComplete*100)")
    }
    
    private func showErrorAlert(title: String, message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default))
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootViewController = windowScene.windows.first?.rootViewController {
                rootViewController.present(alert, animated: true)
            }
        }
    }
}


extension FairPlaySdk: FairPlayLicenseDelegate {
    func fpsLicenseDidSuccessAcquiring(contentId: String) {
        print("License Success : \(contentId)")
        sdkEvent?.sendFairPlaySdkEvent(contentId, eventType: FairPlaySdkEventType.complete, message: contentId, errorCode: "")
    }

    func fpsLicense(contentId: String, didFailWithError error: Error) {
        print("License Failed  : \(contentId)")

        var errorMessage = ""
        var eventType: FairPlaySdkEventType = FairPlaySdkEventType.licenseServerError
        if let error = error as? PallyConSDKException {
            switch error {
            case .ServerConnectionFail(let message):
                eventType = FairPlaySdkEventType.licenseServerError
                errorMessage = "server connection fail = \(message)"
            case .NetworkError(let networkError):
                errorMessage = "Network Error = \(networkError)"
                eventType = FairPlaySdkEventType.networkConnectedError
            case .AcquireLicenseFailFromServer(let code, let message):
                errorMessage = "ServerCode = \(code).\n\(message)"
                eventType = FairPlaySdkEventType.licenseServerError
            case .DatabaseProcessError(let message):
                errorMessage = "DB Error = \(message)"
                eventType = FairPlaySdkEventType.drmError
            case .InternalException(let message):
                errorMessage = "SDK internal Error = \(message)"
                eventType = FairPlaySdkEventType.drmError
            default:
                print("Error: \(error). Unkown.")
                eventType = FairPlaySdkEventType.unknownError
                break
            }
        } else {
            print("Error: \(error). Unkown")
        }
        
        sdkEvent?.sendFairPlaySdkEvent(contentId, eventType: eventType, message: errorMessage, errorCode: "")
    }
    
    func license(result: LicenseResult) {
        print("License Result : \(result)")
        
        var message: String = "Success"
        var event: FairPlaySdkEventType = .complete
        var eCode: Int = -1
        if result.isSuccess == false {
             print("Error : \(String(describing: result.error?.localizedDescription))")
             if let error = result.error {
                  switch error {
                  case .database(comment: let comment):
                       print(comment)
                       message = comment
                      event = .drmError
                  case .server(errorCode: let errorCode, comment: let comment):
                       print("code : \(errorCode), comment: \(comment)")
                       message = "code : \(errorCode), comment: \(comment)"
                      event = .licenseServerError
                      eCode = errorCode
                  case .network(errorCode: let errorCode, comment: let comment):
                       print("code : \(errorCode), comment: \(comment)")
                       message = "code : \(errorCode), comment: \(comment)"
                      event = .networkConnectedError
                      eCode = errorCode
                  case .system(errorCode: let errorCode, comment: let comment):
                       print("code : \(errorCode), comment: \(comment)")
                       message = "code : \(errorCode), comment: \(comment)"
                      event = .licenseServerError
                      eCode = errorCode
                  case .failed(errorCode: let errorCode, comment: let comment):
                       print("code : \(errorCode), comment: \(comment)")
                       message = "code : \(errorCode), comment: \(comment)"
                      event = .drmError
                      eCode = errorCode
                  case .unknown(errorCode: let errorCode, comment: let comment):
                       print("code : \(errorCode), comment: \(comment)")
                       message = "code : \(errorCode), comment: \(comment)"
                      event = .unknownError
                      eCode = errorCode
                  case .invalid(comment: let comment):
                       print("comment: \(comment)")
                       message = "comment: \(comment)"
                      event = .drmError
                  default:
                       print("comment: \(error)")
                       message = "comment: \(error)"
                      event = .unknownError
                      break
                  }
                 sdkEvent?.sendFairPlaySdkEvent(result.contentId, eventType: event, message: message, errorCode: "\(eCode)")
             }
        } else {
            sdkEvent?.sendFairPlaySdkEvent(result.contentId, eventType: FairPlaySdkEventType.licenseServerError, message: message, errorCode: "0")
        }
    }
}


extension FairPlaySdk {
    // managed download contents
    func loadDownloadedContent(with url: String, contentId: String ) -> DrmContent? {
        let userDefaults = UserDefaults.standard
        guard let localFileLocation = userDefaults.value(forKey: url) as? String else { return nil }

        let localFilePath = FairPlaySdk.baseDownloadURL.appendingPathComponent(localFileLocation)
        print("\(localFilePath.absoluteString)")
        if FileManager.default.fileExists(atPath: localFilePath.path) {
            let drmContent = DrmContent(siteId: self.siteId, url: url, contentId: contentId, path: localFilePath.absoluteString)
            return drmContent
        }
        return nil
    }

    func saveDownloadedContent(for drmContent: DrmContent, location: URL) {
        downloadedContentMap[drmContent.url] = drmContent
        downloadedContentMap[drmContent.url]?.downloadState = DownloadState.completed
        let contentUrl =  FairPlaySdk.baseDownloadURL.appendingPathComponent(location.relativePath)
        downloadedContentMap[drmContent.url]?.downloadPath = contentUrl.absoluteString
        let userDefaults = UserDefaults.standard
        userDefaults.set(location.relativePath, forKey: drmContent.url)
    }

    func deleteDowndloadedContent(for drmContent: DrmContent) {
        let userDefaults = UserDefaults.standard

        do {
            if let localFileLocation = userDefaults.value(forKey: drmContent.url) as? String {
                let localFileLocation = FairPlaySdk.baseDownloadURL.appendingPathComponent(localFileLocation)
                try FileManager.default.removeItem(at: localFileLocation)
                userDefaults.removeObject(forKey: drmContent.url)

                self.removeLicense(url: drmContent.url)
            }
        } catch {
            print("An error occured deleting the file: \(error)")
        }
    }
}
