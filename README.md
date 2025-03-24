# **DoveRunner React Native SDK** Development Guide

A React-Native plugin which provides easy to apply Multi-DRM(Android: Widevine, iOS: FairPlay) when developing media service apps for Android and iOS. Please refer to the links below for detailed information.

## **Support Environment**

- Android 6.0 (API 23) & Android targetSdkVersion 34 or higher
- iOS 14.0 higher

## **Important**

- To develop using the SDK, you must first sign up for the [DoveRunner Site](https://doverunner.com/) and obtain a `Site ID`.

## **SDK usage**

To add `DoveRunner React Native SDK` to your React-Native app, read the [Installation](https://yarnpkg.com/) instructions. Below are the Android and iOS properties required for `PallyConMultiDrmSdk` to work properly.

### DoveRunner Multi-DRM SDK - Android, iOS

The `DoveRunner React Native SDK` uses the [DoveRunner Multi-DRM SDK](https://doverunner.com/). This `DoveRunner Multi-DRM SDK` is used to acquire and manage licences. This SDK is applied to the forked [react-native-video](https://github.com/doverunner/react-native-video.git) and downloaded when running `yarn install`.

### React Native Video

The example project in `DoveRunner React Native SDK` uses [react-native-video](https://github.com/TheWidlarzGroup/react-native-video) to play DRM content.

The provided `react-native-video` is applied with `DoveRunner Multi-DRM SDK`, and if you use `DoveRunner React Native SDK`, you need to configure it like below.

```json
dependencies: {
	...
	//examples/advanced/package.json or examples/basic/package.json
	"react-native-video": "git+https://github.com/inka-pallycon/react-native-video.git"
	...
}
```

<details>
<summary>Android</summary>

## Adding Widevine Android SDK from GitHub Packages

To integrate the Widevine Android SDK, follow these steps to add the GitHub package repository to your `build.gradle` file:

### 1. Update your `build.gradle` file

Add the following code snippet to the `allprojects` section of your `build.gradle` file to include the DoveRunner Widevine Android SDK GitHub repository:

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

### 2. GitHub Authentication

The username should be your GitHub User ID.
The password should be your GitHub Personal Access Token (PAT).
For instructions on generating a Personal Access Token, refer to the official GitHub documentation: [Managing your Personal Access Tokens.](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens)

### 3. Set compileSdkVersion

Make sure you set `compileSdkVersion` in "android/app/build.gradle".

```
android {
  compileSdkVersion 34

  ...
}
```

</details>

<details>
<summary>iOS</summary>

`pallycon-react-native-sdk` uses cocoapods to install `DoveRunner Multi-DRM iOS SDK`.

> For information on how to install and use cocoapods, please refer to the [cocoapods official website](https://cocoapods.org/).

#### examples/advanced

- DRM content streaming playback
- DRM content download and offline playback

#### examples/basic

- DRM content streaming playback

### How to Run DoveRunner React Native SDK Example

- Run the following command to execute the example.

```shell
// move to the pallycon-react-native-sdk folder
% cd pallycon-react-native-sdk
% yarn install
% yarn pack -o pallycon-react-native-sdk.tgz

// move to the example/advanced or example/basic folder
% cd example/advanced
% yarn install

// move to ios folder
% cd ios
% pod install
% cd ..
// run ios
% npx react-native run-ios
// xcode run
% cd ios && open advanced.xcworkspace
```

</details>

### **Import**

```typescript
import PallyConMultiDrmSdk, {
  PallyConEventType,
  PallyConContentConfiguration,
  PallyConDownloadState,
} from "pallycon-react-native-sdk"
```

### **Initialize**

```typescript
PallyConMultiDrmSdk.initialize(siteId)
```

### **Set Event**

Register events that occur inside the SDK.

```typescript
PallyConMultiDrmSdk.addPallyConEvent(PallyConEventType.complete, (event) => {
  // Called when download is complete
})

PallyConMultiDrmSdk.addPallyConEvent(PallyConEventType.pause, (event) => {
  // Called when downloading is stopped during download
})

PallyConMultiDrmSdk.addPallyConEvent(PallyConEventType.remove, (event) => {
  // Called when download remove
})

PallyConMultiDrmSdk.addPallyConEvent(PallyConEventType.stop, (event) => {
  // Called when download stops
})

PallyConMultiDrmSdk.addPallyConEvent(PallyConEventType.download, (event) => {
  // Called when download starts
})

PallyConMultiDrmSdk.addPallyConEvent(
  PallyConEventType.contentDataError,
  (event) => {
    // Called when an error occurs in the parameters passed to the sdk
  }
)

PallyConMultiDrmSdk.addPallyConEvent(PallyConEventType.drmError, (event) => {
  // Called when a license error occurs
})

PallyConMultiDrmSdk.addPallyConEvent(
  PallyConEventType.licenseServerError,
  (event) => {
    // Called when an error comes down from the license server
  }
)

PallyConMultiDrmSdk.addPallyConEvent(
  PallyConEventType.downloadError,
  (event) => {
    // Called when an error occurs during download
  }
)

PallyConMultiDrmSdk.addPallyConEvent(
  PallyConEventType.networkConnectedError,
  (event) => {
    // Called in case of network error
  }
)

PallyConMultiDrmSdk.addPallyConEvent(
  PallyConEventType.detectedDeviceTimeModifiedError,
  (event) => {
    // Called when device time is forcibly manipulated
  }
)

PallyConMultiDrmSdk.addPallyConEvent(
  PallyConEventType.migrationError,
  (event) => {
    // Called when sdk migration fails
  }
)

PallyConMultiDrmSdk.addPallyConEvent(
  PallyConEventType.licenseCipherError,
  (event) => {
    // Called when license cipher fails
  }
)

PallyConMultiDrmSdk.addPallyConEvent(
  PallyConEventType.unknownError,
  (event) => {
    // Internally called when an unknown error occurs
  }
)
```

When downloading, register a listener to know the size of the currently downloaded data.

```typescript
PallyConMultiDrmSdk.addPallyConEvent(PallyConEventType.progress, (event) => {
  // event.url is url
  // event.percent is downloaded percent
})
```

### **Get content download status**

Get the current download status of the content.

```typescript
try {
  const state = await PallyConMultiDrmSdk.getDownloadState(config)
  switch (state) {
    case PallyConDownloadState.DOWNLOADING:
      break
    case PallyConDownloadState.PAUSED:
      break
    case PallyConDownloadState.COMPLETED:
      break
    default:
      break
  }
} catch (e) {
  setError(e.message)
}
```

### **Download**

Describes the API required for the content download process.

```typescript
// start download
PallyConMultiDrmSdk.addStartDownload(PallyConContentConfiguration)

// cancel downloads
PallyConMultiDrmSdk.cancelDownloads()

// pause downloads
PallyConMultiDrmSdk.pauseDownloads()

// resume downloads
PallyConMultiDrmSdk.resumeDownloads()
```

### **Remove License or Contents**

Remove the downloaded license and content.

```typescript
// remove downloaded content
PallyConMultiDrmSdk.removeDownload(PallyConContentConfiguration)

// remove license for content
PallyConMultiDrmSdk.removeLicense(PallyConContentConfiguration)
```

### **Release**

Called when you end using the SDK.

```typescript
DoveRunnerMultiDrmSdk.release()
```
