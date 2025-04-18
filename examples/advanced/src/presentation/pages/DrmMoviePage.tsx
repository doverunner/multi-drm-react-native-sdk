import React, { Component, useEffect, useRef, useState } from "react"
import drmMovieController from "../controllers/DrmMovieController"
import { DrmMovie } from "../../domain/model/DrmMovie"
import Icon from "react-native-vector-icons/MaterialCommunityIcons"
import {
  Text,
  View,
  StyleSheet,
  LogBox,
  FlatList,
  TouchableHighlight,
  TouchableOpacity,
  useColorScheme,
  AppState,
} from "react-native"

import { downloadState } from "../../domain/model/DownloadState"
import Toast from "react-native-toast-message"
import { SafeAreaView } from "react-native-safe-area-context"
import { useFocusEffect } from "@react-navigation/core"
import { Pressable, Alert } from "react-native"

LogBox.ignoreLogs(["Remote debugger"])

export default function DrmMoviePage({ navigation }: any) {
  const appState = useRef(AppState.currentState)

  const isDarkMode = useColorScheme() === "dark"
  const styles = StyleSheet.create({
    item: {
      flexDirection: "row",
      justifyContent: "space-between",
      alignItems: "center",
      height: 65,
      paddingHorizontal: 20,
      borderTopWidth: 1,
      borderColor: isDarkMode ? "#FFF" : "#000",
      backgroundColor: isDarkMode ? "#444" : "#EEE",
    },
    itemContent: {
      flex: 1,
      flexDirection: "row",
      alignItems: "center",
    },
    itemText: {
      flex: 0.9,
      color: isDarkMode ? "#AAA" : "#444",
      marginRight: 10,
    },
    iconContainer: {
      flex: 0.1,
      alignItems: "flex-end",
    },
    progressText: {
      color: "#e88504",
    },
    progressBtn: {
      backgroundColor: "transparent",
    },
  })

  const didMount = useRef(false)
  const {
    sdkInit,
    setMultiDrmEvents,
    getMovies,
    getPlayerData,
    downloadMovie,
    pauseMovie,
    removeMovie,
    removeLicense,
    removeListeners,
    clearError,
    downloadPercent,
    movies,
    error,
  } = drmMovieController()

  const onPress = (drmMovie: DrmMovie) => {
    switch (drmMovie.downloadState) {
      case downloadState.success:
        removeMovie(drmMovie)
        break
      case downloadState.running:
        pauseMovie(drmMovie)
        break
      default:
        downloadMovie(drmMovie)
        break
    }
  }

  const playMovie = async (item: DrmMovie) => {
    const json = await getPlayerData(item)
    navigation.navigate("DrmMoviePlayerPage", { json: json })
  }

  const iconButton = (
    drmMovie: DrmMovie,
    percent: [string, number] | undefined,
    onPress: (drmMovie: DrmMovie) => void
  ) => {
    switch (drmMovie.downloadState) {
      case downloadState.success:
        return (
          <Icon
            name="delete"
            size={25}
            color="#e88504"
            onPress={() => onPress(drmMovie)}
          />
        )
      case downloadState.running:
        return (
          <TouchableOpacity
            style={styles.progressBtn}
            onPress={() => onPress(drmMovie)}
          >
            <Text style={styles.progressText}>
              {(percent ? percent[1] : 0) + "%"}
            </Text>
          </TouchableOpacity>
        )
      default:
        return (
          <Icon
            name="download"
            size={25}
            color="#e88504"
            onPress={() => onPress(drmMovie)}
          />
        )
    }
  }

  useEffect(() => {
    if (!didMount.current) {
      sdkInit()
      const asyncGetMovies = async () => {
        await getMovies()
      }
      setMultiDrmEvents()
      asyncGetMovies()
      didMount.current = true
    }

    // if (movies.length > 0) {
    //   setMultiDrmEvents()
    // }

    if (error && error.length > 0) {
      Toast.show({
        type: "error",
        text1: "Error",
        text2: error,
      })
      clearError()
    }
  }, [error, movies])

  useFocusEffect(() => {
    const isActive = navigation.isFocused() // 화면이 현재 활성화 중인지 확인

    // if (isActive) {
    //   setMultiDrmEvents()
    // }
  })

  const showMenu = (item: DrmMovie) => {
    Alert.alert(
      item.title,
      "작업을 선택하세요",
      [
        { text: "Remove License", onPress: () => removeLicense(item) },
        { text: "Cancel", style: "cancel" },
      ],
      { cancelable: true }
    )
  }

  return (
    <SafeAreaView>
      <FlatList
        data={movies}
        renderItem={({ item }) => (
          <Pressable
            key={item.url}
            onPress={() => playMovie(item)}
            onLongPress={() => showMenu(item)}
            style={({ pressed }) => [
              styles.item,
              { opacity: pressed ? 0.6 : 1 },
            ]}
          >
            <View style={styles.itemContent}>
              <Text
                style={styles.itemText}
                numberOfLines={1}
                ellipsizeMode="tail"
              >
                {item.title}
              </Text>
              <View style={styles.iconContainer}>
                {iconButton(
                  item,
                  downloadPercent.find((i) => i[0] === item.url),
                  onPress
                )}
              </View>
            </View>
          </Pressable>
        )}
      />
    </SafeAreaView>
  )
}
