import {MultiDrmEventType} from "./MultiDrmEventType";
import {MultiDrmReceiveEvent, MultiDrmErrorEvent, ProgressEvent} from ".";

type EnumKeys = keyof typeof MultiDrmEventType;
type EnumKeyFields = {
    [key in EnumKeys]:any;
}
export interface MultiDrmEvent extends EnumKeyFields{
    [MultiDrmEventType.complete]: MultiDrmReceiveEvent;
    [MultiDrmEventType.pause]: MultiDrmReceiveEvent;
    [MultiDrmEventType.remove]: MultiDrmReceiveEvent;
    [MultiDrmEventType.stop]: MultiDrmReceiveEvent;
    [MultiDrmEventType.download]: MultiDrmReceiveEvent;
    [MultiDrmEventType.contentDataError]: MultiDrmErrorEvent;
    [MultiDrmEventType.drmError]: MultiDrmErrorEvent;
    [MultiDrmEventType.licenseServerError]: MultiDrmErrorEvent;
    [MultiDrmEventType.downloadError]: MultiDrmErrorEvent;
    [MultiDrmEventType.networkConnectedError]: MultiDrmErrorEvent;
    [MultiDrmEventType.detectedDeviceTimeModifiedError]: MultiDrmErrorEvent;
    [MultiDrmEventType.migrationError]: MultiDrmErrorEvent;
    [MultiDrmEventType.licenseCipherError]: MultiDrmErrorEvent;
    [MultiDrmEventType.unknownError]: MultiDrmErrorEvent;
    [MultiDrmEventType.progress]: ProgressEvent;
}
