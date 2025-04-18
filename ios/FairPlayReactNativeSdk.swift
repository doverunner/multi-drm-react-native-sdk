//
//  RNPallyConDrmSdk.swift
//  RNPallyConDrmSdk
//
//  Created by sungju Yun on 2023/01/25.
//  Copyright © 2023 Facebook. All rights reserved.
//

import Foundation

@objc(RNPallyConDrmSdk)
public class RNPallyConDrmSdk: RCTEventEmitter {
    private let defaultLicenseUrl = "https://license-global.pallycon.com/ri/licenseManager.do"

    override public init() {
        super.init()
        PallyConSdk.shared.setPallyConEvent(pallyConEvent: PallyConEventImpl(emitter: self))
        PallyConSdk.shared.setDownloadProgress(downloadProgressEvent: DownloadProgressEventImpl(emitter: self))
    }

    @objc(supportedEvents)
    override public func supportedEvents() -> [String] {
        return EventEmitter.shared.allEvents
    }

    @objc(initialize:resolver:rejecter:)
    public func initialize(_ siteId: String, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
        PallyConSdk.shared.initialize(siteId: siteId)
        resolve(nil)
    }

    @objc(release:rejecter:)
    public func release(_ resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
        PallyConSdk.shared.release()
        resolve(nil)
    }

    @objc(setPallyConEvents:rejecter:)
    public func setPallyConEvents(_ resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
        PallyConSdk.shared.setPallyConEvent(pallyConEvent: PallyConEventImpl(emitter: self))
    }

    @objc(getObjectForContent:resolver:rejecter:)
    public func getObjectForContent(_ data: NSDictionary, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
        guard let url = data["contentUrl"] as? String,
            let contentId = data["contentId"] as? String,
            !(data["token"] == nil && data["customData"] == nil) else {
            resolve(RCTMakeError("required argument", nil, nil))
            return
        }

        let token = data["token"] as? String
        let customData = data["customData"] as? String
        let contentCookie = data["contentCookie"] as? String
        let licenseCookie = data["licenseCookie"] as? String
        let contentHttpHeaders = data["contentHttpHeaders"] as? Dictionary<String, String>
        let licenseHttpHeaders = data["licenseHttpHeaders"] as? Dictionary<String, String>
        let licenseUrl = data["licenseUrl"] as? String ?? defaultLicenseUrl
        let appleCertUrl = data["certificateUrl"] as? String

        let object = PallyConSdk.shared.getObjectForContent(
            url: url,
            contentId: contentId,
            token: token,
            customData: customData,
            contentHttpHeaders: contentHttpHeaders,
            licenseHttpHeaders: licenseHttpHeaders,
            contentCookie: contentCookie,
            licenseCookie: licenseCookie,
            drmLicenseUrl: licenseUrl,
            appleCertUrl: appleCertUrl
        )
        resolve(object)
    }

    @objc(getDownloadState:resolver:rejecter:)
    public func getDownloadState(_ data: NSDictionary, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
        guard let url = data["contentUrl"] as? String else {
            resolve(RCTMakeError("required argument", nil, nil))
            return
        }

        let state = PallyConSdk.shared.getDownloadState(url: url)
        resolve(state)
    }

    @objc(addStartDownload:resolver:rejecter:)
    public func addStartDownload(_ data: NSDictionary, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
        guard let url = data["contentUrl"] as? String,
            let contentId = data["contentId"] as? String,
            !(data["token"] == nil && data["customData"] == nil) else {
            resolve(RCTMakeError("required argument", nil, nil))
            return
        }

        let token = data["token"] as? String
        let customData = data["customData"] as? String
        let contentCookie = data["contentCookie"] as? String
        let licenseCookie = data["licenseCookie"] as? String
        let contentHttpHeaders = data["contentHttpHeaders"] as? Dictionary<String, String>
        let licenseHttpHeaders = data["licenseHttpHeaders"] as? Dictionary<String, String>
        let licenseUrl = data["licenseUrl"] as? String ?? defaultLicenseUrl
        let appleCertUrl = data["certificateUrl"] as? String

        PallyConSdk.shared.addStartDownload(
                    url: url,
                    contentId: contentId,
                    token: token,
                    customData: customData,
                    contentHttpHeaders: contentHttpHeaders,
                    licenseHttpHeaders: licenseHttpHeaders,
                    contentCookie: contentCookie,
                    licenseCookie: licenseCookie,
                    drmLicenseUrl: licenseUrl,
                    appleCertUrl: appleCertUrl
                )
        resolve(nil)
    }

    @objc(resumeDownloads:rejecter:)
    public func resumeDownloads(_ resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
        PallyConSdk.shared.resumeAll()
        resolve(nil)
    }

    @objc(cancelDownloads:rejecter:)
    public func cancelDownloads(_ resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
        PallyConSdk.shared.cancelAll()
        resolve(nil)
    }

    @objc(pauseDownloads:rejecter:)
    public func pauseDownloads(_ resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
        PallyConSdk.shared.pauseAll()
        resolve(nil)
    }

    @objc(removeDownload:resolver:rejecter:)
    public func removeDownload(_ data: NSDictionary, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
        guard let url = data["contentUrl"] as? String else {
            resolve(RCTMakeError("required argument", nil, nil))
            return
        }

        PallyConSdk.shared.removeDownload(url: url)
        resolve(nil)
    }

    @objc(removeLicense:resolver:rejecter:)
    public func removeLicense(_ data: NSDictionary, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
        guard let url = data["contentUrl"] as? String else {
            resolve(RCTMakeError("required argument", nil, nil))
            return
        }

        PallyConSdk.shared.removeLicense(url: url)
        resolve(nil)
    }

    @objc(needsMigrateDatabase:resolver:rejecter:)
    public func needsMigrateDatabase(_ data: NSDictionary, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
        resolve(false)
    }

    @objc(migrateDatabase:resolver:rejecter:)
    public func migrateDatabase(_ data: NSDictionary, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
        resolve(true)
    }

    @objc(migrateDatabase:rejecter:)
    public func reDownloadCertification(_ resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
        resolve(true)
    }

    @objc(updateSecureTime:rejecter:)
    public func updateSecureTime(_ resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
        resolve(true)
    }
}
