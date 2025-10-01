import React, { useEffect, useRef } from "react"
import {
  AppState,
  FlatList,
  StyleSheet,
  Text,
  TouchableHighlight,
  TouchableOpacity,
  View,
} from "react-native"
import Video from "react-native-video"
import base64 from "react-native-base64"
import Toast from "react-native-toast-message"

export default function DrmMoviePlayerPage({ route }: any) {
  const VideoComponent: any = Video
  const styles = StyleSheet.create({
    container: {
      flex: 1,
      justifyContent: "center",
      alignItems: "center",
      backgroundColor: "black",
    },
    halfScreen: {
      position: "absolute",
      top: 50,
      left: 50,
      bottom: 100,
      right: 100,
    },
    fullScreen: {
      position: "absolute",
      top: 0,
      left: 0,
      bottom: 0,
      right: 0,
    },
    bottomControls: {
      backgroundColor: "transparent",
      borderRadius: 5,
      position: "absolute",
      bottom: 20,
      left: 20,
      right: 20,
    },
    leftControls: {
      backgroundColor: "transparent",
      borderRadius: 5,
      position: "absolute",
      top: 20,
      bottom: 20,
      left: 20,
    },
    rightControls: {
      backgroundColor: "transparent",
      borderRadius: 5,
      position: "absolute",
      top: 20,
      bottom: 20,
      right: 20,
    },
    topControls: {
      backgroundColor: "transparent",
      borderRadius: 4,
      position: "absolute",
      top: 20,
      left: 20,
      right: 20,
      flex: 1,
      flexDirection: "row",
      overflow: "hidden",
      paddingBottom: 10,
    },
    generalControls: {
      flex: 1,
      flexDirection: "row",
      borderRadius: 4,
      overflow: "hidden",
      paddingBottom: 10,
    },
    rateControl: {
      flex: 1,
      flexDirection: "row",
      justifyContent: "center",
    },
    volumeControl: {
      flex: 1,
      flexDirection: "row",
      justifyContent: "center",
    },
    resizeModeControl: {
      flex: 1,
      flexDirection: "row",
      alignItems: "center",
      justifyContent: "center",
    },
    leftRightControlOption: {
      alignSelf: "center",
      fontSize: 11,
      color: "white",
      padding: 10,
      lineHeight: 12,
    },
    controlOption: {
      alignSelf: "center",
      fontSize: 11,
      color: "white",
      paddingLeft: 2,
      paddingRight: 2,
      lineHeight: 12,
    },
    IndicatorStyle: {
      flex: 1,
      justifyContent: "center",
    },
    seekbarContainer: {
      flex: 1,
      flexDirection: "row",
      borderRadius: 4,
      height: 30,
    },
    seekbarTrack: {
      backgroundColor: "#333",
      height: 1,
      position: "relative",
      top: 14,
      width: "100%",
    },
    seekbarFill: {
      backgroundColor: "#FFF",
      height: 1,
      width: "100%",
    },
    seekbarHandle: {
      position: "absolute",
      marginLeft: -7,
      height: 28,
      width: 28,
    },
    seekbarCircle: {
      borderRadius: 12,
      position: "relative",
      top: 8,
      left: 8,
      height: 12,
      width: 12,
    },
    picker: {
      color: "white",
      flex: 1,
      flexDirection: "row",
      justifyContent: "center",
    },
  })

  const state = {
    rate: 1,
    volume: 1,
    muted: false,
    resizeMode: "contain",
    duration: 0.0,
    currentTime: 0.0,
    videoWidth: 0,
    videoHeight: 0,
    paused: false,
    fullscreen: true,
    decoration: true,
    isLoading: false,
    seekerFillWidth: 0,
    seekerPosition: 0,
    seekerOffset: 0,
    seeking: false,
    audioTracks: [],
    textTracks: [],
    selectedAudioTrack: undefined,
    selectedTextTrack: undefined,
    srcListId: 0,
    loop: false,
    showRNVControls: true,
  }

  const videoRef = useRef<any>(null)

  const onLoad = (data: any) => {
    console.log("onLoad")
  }

  const onProgress = (data: any) => {
    console.log("onProgress")
  }

  const onEnd = () => {
    console.log("onEnd")
  }

  const onError = (err: any) => {
    console.log(JSON.stringify(err?.error.errorCode))
    console.log(JSON.stringify(err?.error.localizedDescription));
    console.log(JSON.stringify(err?.error.localizedFailureReason));
    // If the error code is 50000, it indicates that the license has expired.
    Toast.show({
      type: "error",
      text1: err?.error.errorCode,
      text2: err?.error.localizedFailureReason,
    })

    const errorCode = err?.error?.errorCode || "UNKNOWN"
    const errorDescription = err?.error?.localizedDescription || ""
    const errorReason = err?.error?.localizedFailureReason || ""

    if (errorCode === "50000" || errorCode === 50000) {
      Toast.show({
        type: "error",
        text1: "license expired",
      })
      return
    }
    
    Toast.show({
      type: "error",
      text1: `Error Code: ${errorCode}`,
      text2: errorReason || errorDescription || "An error occurred while playing.",
    })
  }

  const viewStyle = state.fullscreen ? styles.fullScreen : styles.halfScreen

  useEffect(() => { }, [])

  const decodedJson: string = base64.decode(route.params.json)
  let parsedData
  try {
    parsedData = JSON.parse(decodedJson)
  } catch (error) {
    console.error("Error parsing JSON:", error)
    return null
  }

  const videoUrl = parsedData.url

  return (
    <TouchableOpacity style={viewStyle}>
      <VideoComponent
        ref={videoRef}
        source={{
          uri: videoUrl, // URL을 여기에 추가
          headers: { MultiDrmJson: decodedJson },
        }}
        style={viewStyle}
        resizeMode="contain"
        rate={state.rate}
        paused={state.paused}
        volume={state.volume}
        muted={state.muted}
        controls={state.showRNVControls}
        onLoad={onLoad}
        onProgress={onProgress}
        onEnd={onEnd}
        progressUpdateInterval={1000}
        onError={onError}
        playInBackground={false}
      />
    </TouchableOpacity>
  )
  // return (
  //     <View style={styles.container}>
  //         <Video
  //             source={{
  //                 headers: {MultiDrmJson: route.params.json},
  //             }}
  //             style={styles.fullScreen}
  //             paused={false}
  //             resizeMode={'cover'}
  //             onLoad={(e: any) => console.log(e)}
  //             repeat={true}
  //         />
  //     </View>
  // );
}
