import {DrmType} from "./DrmType";

export interface DrmContentConfiguration {
    /** content url */
    contentUrl: string;

    /** content id */
    contentId: string;

    /** drm type
     * @see DrmType
     */
    drmType?: DrmType;

    /** token */
    token?: string;

    /** custom data */
    customData?: string;

    /** content cookie */
    contentCookie?: string;

    /** content http headers */
    contentHttpHeaders?: Map<string, string>;

    /** license server cookie */
    licenseCookie?: string;

    /** license server http headers */
    licenseHttpHeaders?: Map<string, string>;

    /** license url */
    licenseUrl?: string;

    /** certificate url */
    certificateUrl?: string;

    /** license cipher table path */
    licenseCipherTablePath?: string;
}
