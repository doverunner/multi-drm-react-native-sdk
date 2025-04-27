import {DeviceEventEmitter, EmitterSubscription, NativeEventEmitter, NativeModules, Platform} from 'react-native';
import {DrmContentConfiguration} from "./models/DrmContentConfiguration";
import {MultiDrmEvent, MultiDrmEventType} from "./events";
import base64 from "react-native-base64";
import {ContentDownloadState} from "./models";

/*
SDK for using Multi-DRM React Native.
 */
const { NativeMultiDrmSdkModule: ReactMultiDrmSdk } = NativeModules;
const emitter =
    Platform.OS !== 'android'
        ? new NativeEventEmitter(ReactMultiDrmSdk)
        : DeviceEventEmitter;

/**
 * Initializes the MultiDrmSdk.
 *
 * @param siteId issued by the DOVERUNNER.
 */
export function initialize(siteId: String) {
    return ReactMultiDrmSdk.initialize(siteId);
}

/**
 * release the MultiDrmSdk.
 * The MultiDrmSdk must not be used after calling this method.
 */
export function release() {
    ReactMultiDrmSdk.release();
}

/**
 * set Multi-DRM Event
 */
export function setMultiDrmEvents() {
    ReactMultiDrmSdk.setMultiDrmEvents();
}

/**
 * function that creates the objects needed to play the player.
 *
 * @param config Information about the content
 * @see DrmContentConfiguration
 * @returns If the player has a Base64 string
 * @throws ILLEGAL_ARGUMENT when the input parameters are null or incorrect
 */
export async function getObjectForContent(config: DrmContentConfiguration): Promise<string> {
    const object = await ReactMultiDrmSdk.getObjectForContent(config);
    const encoded: string = base64.encode(object);
    return encoded;
}

/**
 * Get a ContentDownloadState.
 *
 * @param config Information about the content
 * @see DrmContentConfiguration
 * @returns state of download for content
 * @see ContentDownloadState
 * @throws ILLEGAL_ARGUMENT when the input parameters are null or incorrect
 */
export async function getDownloadState(config: DrmContentConfiguration): Promise<ContentDownloadState> {
    const state = await ReactMultiDrmSdk.getDownloadState(config);
    switch (state) {
        case 'DOWNLOADING': {
            return ContentDownloadState.DOWNLOADING;
        }
        case 'COMPLETED': {
            return ContentDownloadState.COMPLETED
        }
        case 'PAUSED': {
            return ContentDownloadState.PAUSED;
        }
        default: {
            return ContentDownloadState.NOT;
        }
    }
}

/**
 * Add the specified listener, this call passes through
 *
 * @param eventType name of the event for which we are registering listener
 * @param listener the listener function
 * @see MultiDrmEvent
 * @returns EmitterSubscription represents a subscription with listener and context data.
 * @see EmitterSubscription
 */
export function addMultiDrmEvent<T extends MultiDrmEventType>(
    eventType: T,
    listener: MultiDrmEvent[T] extends never
        ? () => void
        : (eventType: MultiDrmEvent[T]) => void
): EmitterSubscription {
    return emitter.addListener(eventType, listener);
}

/**
 * Starts the service if not started already and adds a new download.
 * If an error occurs during DRM download, [MultiDrmEventType.downloadError] called.
 *
 * @param config Information about the content
 * @see DrmContentConfiguration
 * @throws ILLEGAL_ARGUMENT when the input parameters are null or incorrect
 */
export async function addStartDownload(config: DrmContentConfiguration): Promise<void> {
    ReactMultiDrmSdk.addStartDownload(config);
}

/**
 * Starts the service if not started already and resumes all downloads.
 */
export function resumeDownloads() {
    ReactMultiDrmSdk.resumeDownloads();
}

/**
 * Starts the service in not started already and cancels all downloads.
 */
export function cancelDownloads() {
    ReactMultiDrmSdk.cancelDownloads();
}

/**
 * Starts the service in not started already and pauses all downloads.
 */
export function pauseDownloads() {
    ReactMultiDrmSdk.pauseDownloads();
}

/**
 * Remove the content already downloaded.
 *
 * @param config Information about the content
 * @see DrmContentConfiguration
 * @throws ILLEGAL_ARGUMENT when the input parameters are null or incorrect
 */
export async function removeDownload(config: DrmContentConfiguration): Promise<void> {
    ReactMultiDrmSdk.removeDownload(config);
}

/**
 * Remove offline licenses already downloaded.
 *
 * @param config Information about the content
 * @see DrmContentConfiguration
 * @throws ILLEGAL_ARGUMENT when the input parameters are null or incorrect
 */
export async function removeLicense(config: DrmContentConfiguration): Promise<void> {
    ReactMultiDrmSdk.removeLicense(config);
}

export async function needsMigrateDatabase(config: DrmContentConfiguration): Promise<boolean> {
    return await ReactMultiDrmSdk.needsMigrateDatabase(config);
}

export async function migrateDatabase(config: DrmContentConfiguration): Promise<boolean> {
    return await ReactMultiDrmSdk.migrateDatabase(config);
}

export async function reDownloadCertification(): Promise<boolean> {
    return await ReactMultiDrmSdk.reDownloadCertification();
}

export async function updateSecureTime(): Promise<boolean> {
    return await ReactMultiDrmSdk.updateSecureTime();
}
