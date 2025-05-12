export interface MultiDrmErrorEvent {
  /** The content ID */
  contendId: string | null;
  /** The track url */
  url: string | null;
  /** error code */
  errorCode: string | null;
  /** error message */
  message: string | null;
}
