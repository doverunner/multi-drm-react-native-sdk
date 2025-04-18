import Foundation
import AVKit
import PallyConFPSSDK

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

    func toPallyConConfig() -> String {

        let customData = self.customData ?? ""
        let drmLicenseUrl = self.drmLicenseUrl ?? ""
        let certificateUrl = self.appleCertUrl ?? ""

        let configString = "{\"drmConfig\":{\"siteId\":\"\(self.siteId)\",\"contentId\":\"\(self.contentId)\",\"certificateUrl\":\"\(certificateUrl)\",\"drmLicenseUrl\":\"\(drmLicenseUrl)\",\"token\":\"\(self.token)\",\"customData\":\"\(customData)\"},\"url\":\"\(self.downloadPath)\"}"

        return configString
    }
}

class PallyConSdk: NSObject {
    static let shared = PallyConSdk()

    private var pallyConEvent: PallyConEvent?
    private var progressEvent: DownloadProgressEvent?

    private var siteId: String = ""
    private var fpsSdk: PallyConFPSSDK?
    private var downloadTaskMap = [DownloadTask:DrmContent]()
    private var downloadedContentMap = [String:DrmContent]()

    static let baseDownloadURL: URL = URL(fileURLWithPath: NSHomeDirectory())

    public func setPallyConEvent(pallyConEvent: PallyConEvent?) {
        self.pallyConEvent = pallyConEvent
    }

    public func setDownloadProgress(downloadProgressEvent: DownloadProgressEvent?) {
        self.progressEvent = downloadProgressEvent
    }

    public func initialize(siteId: String) {
        self.siteId = siteId
        do {
            fpsSdk = try PallyConFPSSDK(siteId: self.siteId, siteKey: "", fpsLicenseDelegate: self)
        } catch PallyConSDKException.DatabaseProcessError(let message) {
             print("PallyConFPSSDK initilize failed.\n\(message)")
        } catch {
             print("Error: \(error).\nUnkown Error")
        }
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
            return drmContent.toPallyConConfig()
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
//        sendPallyConEvent(url: url, eventType: PallyConEventType.complete, message: "Complete")
        for (task, downloadContent) in downloadTaskMap {
            print("download task \(downloadContent.contentId)")
            if downloadContent.url == url {
                print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
                task.resume()
                return
            }
        }

        guard let contentUrl:URL = URL(string: url) else {
            pallyConEvent?.sendPallyConEvent(url, eventType: PallyConEventType.downloadError, message: "String to URL convert Error!", errorCode: "")
            return
        }

        guard let downloadTask = fpsSdk?.createDownloadTask(url: contentUrl, token: token!, downloadDelegate: self) else {
            pallyConEvent?.sendPallyConEvent(url, eventType: PallyConEventType.downloadError, message: "DownloadTask not Create! ", errorCode: "")
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
                pallyConEvent?.sendPallyConEvent(downloadTaskMap[task]!.url, eventType: PallyConEventType.pause, message: "User Downloaded Content Pause", errorCode: "")
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
        pallyConEvent?.sendPallyConEvent(url, eventType: PallyConEventType.remove, message: "Remove Downloaded Content", errorCode: "")
    }

    public func removeLicense(url: String) {
        guard let downloadedContent = downloadedContentMap[url] else {
            return
        }
        try! self.fpsSdk?.removeLicense(contentId: downloadedContent.contentId)
    }
}


extension PallyConSdk: PallyConFPSDownloadDelegate {
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
        var isError: Bool = false
        var localPath: String?
        var stopError: Error?
        if let error = error as? PallyConSDKException {
            switch error {
            case .DownloadUserCancel(let filePath):
                print("User Cancel Error \(filePath)")
                localPath = filePath
                stopError = error
                break
            case .DownloadUnknownError(let filePath):
                isError = true
                localPath = filePath
                stopError = error
                break
            case .DownloadDefaultError(let networkError, let filePath):
                print("didStopWithError error = \(networkError) \(filePath)")
                let alert = UIAlertController(title: "Download Failed", message: "If you want to download, please try again", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default))
                UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
            default:
                print("Error: \(error). Unkown.")
                isError = true
                break
            }
        }

        var contentUrl:String = ""
        if isError {
            for (task, downloadContent) in downloadTaskMap {
                if downloadContent.contentId == contentId {
                    contentUrl = downloadContent.url
                    downloadTaskMap.removeValue(forKey: task)
                    break
                }
            }
            pallyConEvent?.sendPallyConEvent(contentUrl, eventType: PallyConEventType.unknownError, message: "download stop : \(String(describing: localPath))", errorCode: "")
        } else {
            pallyConEvent?.sendPallyConEvent(contentUrl, eventType: PallyConEventType.pause, message: "user download stop : \(String(describing: localPath))", errorCode: "")
        }

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

        pallyConEvent?.sendPallyConEvent(contentUrl, eventType: PallyConEventType.complete, message: "\(location.absoluteString)", errorCode: "")
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
}


extension PallyConSdk: PallyConFPSLicenseDelegate {
    func fpsLicenseDidSuccessAcquiring(contentId: String) {
        print("License Success : \(contentId)")
        pallyConEvent?.sendPallyConEvent(contentId, eventType: PallyConEventType.complete, message: contentId, errorCode: "")
    }

    func fpsLicense(contentId: String, didFailWithError error: Error) {
        print("License Failed  : \(contentId)")

        var errorMessage = ""
        var eventType: PallyConEventType = PallyConEventType.licenseServerError
        if let error = error as? PallyConSDKException {
            switch error {
            case .ServerConnectionFail(let message):
                eventType = PallyConEventType.licenseServerError
                errorMessage = "server connection fail = \(message)"
            case .NetworkError(let networkError):
                errorMessage = "Network Error = \(networkError)"
                eventType = PallyConEventType.networkConnectedError
            case .AcquireLicenseFailFromServer(let code, let message):
                errorMessage = "ServerCode = \(code).\n\(message)"
                eventType = PallyConEventType.licenseServerError
            case .DatabaseProcessError(let message):
                errorMessage = "DB Error = \(message)"
                eventType = PallyConEventType.drmError
            case .InternalException(let message):
                errorMessage = "SDK internal Error = \(message)"
                eventType = PallyConEventType.drmError
            default:
                print("Error: \(error). Unkown.")
                eventType = PallyConEventType.unknownError
                break
            }
        } else {
            print("Error: \(error). Unkown")
        }

        pallyConEvent?.sendPallyConEvent(contentId, eventType: eventType, message: errorMessage, errorCode: "")
    }
}


extension PallyConSdk {
    // managed download contents
    func loadDownloadedContent(with url: String, contentId: String ) -> DrmContent? {
        let userDefaults = UserDefaults.standard
        guard let localFileLocation = userDefaults.value(forKey: url) as? String else { return nil }

        let localFilePath = PallyConSdk.baseDownloadURL.appendingPathComponent(localFileLocation)
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
        let contentUrl =  PallyConSdk.baseDownloadURL.appendingPathComponent(location.relativePath)
        downloadedContentMap[drmContent.url]?.downloadPath = contentUrl.absoluteString
        let userDefaults = UserDefaults.standard
        userDefaults.set(location.relativePath, forKey: drmContent.url)
    }

    func deleteDowndloadedContent(for drmContent: DrmContent) {
        let userDefaults = UserDefaults.standard

        do {
            if let localFileLocation = userDefaults.value(forKey: drmContent.url) as? String {
                let localFileLocation = PallyConSdk.baseDownloadURL.appendingPathComponent(localFileLocation)
                try FileManager.default.removeItem(at: localFileLocation)
                userDefaults.removeObject(forKey: drmContent.url)

                self.removeLicense(url: drmContent.url)
            }
        } catch {
            print("An error occured deleting the file: \(error)")
        }
    }
}
