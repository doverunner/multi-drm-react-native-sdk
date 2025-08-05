# **Multi DRM React Native SDK** Development Guide

- A React-Native doverunner-react-native-sdk plugin which provides easy to apply Multi-DRM(Android: Widevine, iOS: FairPlay) when developing media service apps for Android and iOS. 
- Please refer to the links below for detailed information.

## **Support Environment**

- Android 6.0 (API 23) & Android targetSdkVersion 34 or higher
- iOS 14.0 higher

## **Important**

- To develop using the SDK, you must first sign up for the [DoveRunner Site][1] and obtain a `Site ID`.

## **Dependencies**

- Multi DRM React Native SDK uses `DoveRunner Multi-DRM SDK` and `react-native-video`.
  - To add `DoveRunner Multi-DRM Sdk` to your React-Native app, read the [Installation][2] instructions.
  - To add `react-native-video` to your React-Native app, read the [React Native Video](#react-native-video) instructions.

- `doverunner-react-native-sdk` and `react-native-video` must be added to `package.json`.
  > The example already includes the information below.

  ```json
  "dependencies": {
    "doverunner-react-native-sdk": "^1.1.2",
    "react-native-video": "git+https://github.com/doverunner/react-native-video.git"
  }
  ``` 

### Set Native Multi-DRM SDK - Android, iOS

- The `doverunner-react-native-sdk` uses the [DoveRunner Multi-DRM SDK][3].
- This `DoveRunner Multi-DRM SDK` is used to acquire and manage licences. 
- SDK is applied to Android and iOS platforms, and the settings and usage methods for each platform are as follows.

#### **Android**

- Adding Widevine Android SDK from GitHub Packages
  - To integrate the Widevine Android SDK, follow these steps to add the GitHub package repository to your `build.gradle` file:

- Update your `build.gradle` file
    - Add the following code snippet to the `allprojects` section of your `build.gradle` file to include the Widevine Android SDK GitHub repository:

      ```groovy
      allprojects {
          repositories {
              maven {
                  url = uri("https://maven.pkg.github.com/inka-pallycon/pallycon-widevine-android-sdk")
                  credentials {
                      username = "GitHub User ID"  // Replace with your GitHub User ID
                      password = "Token"  // Replace with your GitHub Personal Access Token
                  }
              }
              google()
              // other repositories...
          }
      }
      ```

  <details>
  <summary>GitHub Authentication </summary>

    - The username should be your GitHub User ID.
    - The password should be your GitHub Personal Access Token (PAT).
    - For instructions on generating a Personal Access Token. 
      - Github documentation: [Managing your Personal Access Tokens][4].
  </details>


#### **iOS**

- `doverunner-react-native-sdk` uses cocoapods to install `DoveRunner Multi-DRM iOS SDK`.

  > For information on how to install and use cocoapods, please refer to the [cocoapods official website][5].

- Add the following to `Podfile`.

    ```pod
    # examples/advanced/ios/Podfile
    pod 'DoveRunnerFairPlay'
    ```


### Set React Native Video

- The example project in `doverunner-react-native-sdk` uses [react-native-video][6] to play DRM content.
- `react-native-video` is a library that provides a video component for React Native.
  - `react-native-video` is a fork of [react-native-video][7].
  - forked from `react-native-video` to apply `DoveRunner Multi-DRM SDK`.
- The provided `react-native-video` is applied with `DoveRunner Multi-DRM SDK`, and if you use `doverunner-react-native-sdk`, you need to configure it like below.

  ```json
  "_comment": "path : examples/advanced/package.json or examples/basic/package.json",

  "dependencies": {
    "react-native-video": "git+https://github.com/doverunner/react-native-video.git"
  }
  ```


## **React Native SDK Example**
### **Overview**
- `doverunner-react-native-sdk` provides two examples.
  - advanced example
    - DRM content streaming playback
    - DRM content download and offline playback
  - basic example
    - DRM content streaming playback


### How to Run React Native SDK Example
  - Run the following command to execute the example.

    ```bsh
    // move to the doverunner-react-native-sdk folder
    % cd doverunner-react-native-sdk
    % yarn install
    % yarn pack -o pallycon-react-native-sdk.tgz

    // move to the example/advanced or example/basic folder
    % cd example/advanced
    % yarn install

    // if you want to run ios
    // % cd ios
    // % pod install
    // % cd ..

    % npx react-native start --reset-cache
    // run android
    % npx react-native run-android
    // run ios or xcode
    // % npx react-native run-ios
    // % cd ios && open advanced.xcworkspace
    ```

## React Native SDK API

This section describes the `Multi DRM React Native SDK` API.

### **Import**

- Import the `Multi-DRM React Native SDK` module.

  ```typescript
  import MultiDRMReactNativeSDK, {
    MultiDrmEventType,
    DrmContentConfiguration,
    ContentDownloadState,
  } from "doverunner-react-native-sdk"
  ```

### **Initialize**
- Initialize the `Multi DRM React Native SDK`.

  ```typescript
  // ex) advanced/src/presentation/controllers/DrmMovieController.ts
  MultiDRMReactNativeSDK.initialize(siteId)
  ```

### **React Native Multi Drm  Event**

- Register events that occur inside the SDK.
  ```typescript
  // ex) advanced/src/presentation/controllers/DrmMovieController.ts
  MultiDRMReactNativeSDK.setMultiDrmEvents()
  ```

- Multi Drm Event Type
  ```typescript
  // ex) advanced/src/presentation/controllers/DrmMovieController.ts
  export enum MultiDrmEventType {
      complete = 'complete',    /// The download completed
      pause = 'pause',          /// The download paused
      remove = 'remove',        /// The download is removed
      stop = 'stop',            /// The download is stop
      download = 'download',    /// The download is start
      /// Error when the content information to be downloaded is incorrect
      contentDataError = 'contentDataError',
      drmError = 'drmError',                            /// License error     
      licenseServerError = 'licenseServerError',        /// Server error when issuing license
      downloadError = 'downloadError',                  /// Error during download
      networkConnectedError = 'networkConnectedError',  /// Error when there is no network connection
      /// Error that occurs when the time is forcibly manipulated on an Android device
      detectedDeviceTimeModifiedError = 'detectedDeviceTimeModifiedError',
      migrationError = 'migrationError',            /// Error that occurs when migrating from SDK
      licenseCipherError = 'licenseCipherError',    /// Error that occurs when licenseCipher from SDK
      unknownError = 'unknownError',                /// Unknown error type
      progress = 'progress'                         /// Download progress data
  }

  ```

### **Download Event**

- When downloading, register a listener to know the size of the currently downloaded data.

  ```typescript
  // ex) advanced/src/presentation/controllers/DrmMovieController.ts
  MultiDRMReactNativeSDK.addMultiDrmEvent(MultiDrmEventType.progress, (event) => {
    // event.url is url
    // event.percent is downloaded percent
  })
  ```
- Get the current download status of the content.

  ```typescript
  // ex) advanced/src/presentation/controllers/DrmMovieController.ts
  try {
    const state = await MultiDRMReactNativeSDK.getDownloadState(config)
    switch (state) {
      case ContentDownloadState.DOWNLOADING:
        break
      case ContentDownloadState.PAUSED:
        break
      case ContentDownloadState.COMPLETED:
        break
      default:
        break
    }
  } catch (e) {
    setError(e.message)
  }
  ```

### **Download API**

- Describes the API required for the content download process.

  ```typescript
  // ex) advanced/src/presentation/controllers/DrmMovieController.ts
  // start download
  MultiDRMReactNativeSDK.addStartDownload(DrmContentConfiguration)

  // cancel downloads
  MultiDRMReactNativeSDK.cancelDownloads()

  // pause downloads
  MultiDRMReactNativeSDK.pauseDownloads()

  // resume downloads
  MultiDRMReactNativeSDK.resumeDownloads()
  ```

### **Remove License or Contents**

- Remove the downloaded license and content.

  ```typescript
  // ex) advanced/src/presentation/controllers/DrmMovieController.ts
  // remove downloaded content
  MultiDRMReactNativeSDK.removeDownload(DrmContentConfiguration)

  // remove license for content
  MultiDRMReactNativeSDK.removeLicense(DrmContentConfiguration)
  ```

### **Release**

- Called when you end using the SDK.

  ```typescript
    MultiDRMReactNativeSDK.release()
  ```


[1]: https://doverunner.com/
[2]: https://yarnpkg.com/
[3]: https://doverunner.com/sdk/
[4]: https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens
[5]: https://cocoapods.org/
[6]: https://github.com/doverunner/react-native-video.git
[7]: https://github.com/TheWidlarzGroup/react-native-video

