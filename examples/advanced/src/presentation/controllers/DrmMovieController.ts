import { useCallback, useEffect, useState } from "react"
import { DrmMovie } from "../../domain/model/DrmMovie"
import { GetDrmMovies } from "../../domain/usecase/GetDrmMovieUseCase"
import { MovieRepositoryImpl } from "../../data/repository/MovieRepositoryImpl"
import MovieUserDataSourceImpl from "../../data/datasource/MovieUserDataSource"
import { downloadState } from "../../domain/model/DownloadState"
import MultiDrmSdk, {
  MultiDrmEventType,
  DrmContentConfiguration,
  ContentDownloadState,
} from "doverunner-react-native-sdk"

export default function DrmMovieController() {
  const [movies, setMovies] = useState<DrmMovie[]>([])
  const [drmContentConfigs, setDrmContentConfigs] = useState<
  DrmContentConfiguration[]
  >([])
  const [downloadPercent, setDownloadPercent] = useState<[string, number][]>([])
  const [error, setError] = useState<string>("")
  const [isSdkInit, setSdkInit] = useState<boolean>(false)
  const siteId = "DEMO"
  const [listeners, setListeners] = useState<
    ReturnType<typeof MultiDrmSdk.addMultiDrmEvent>[]
  >([])

  const UseCase = new GetDrmMovies(
    new MovieRepositoryImpl(new MovieUserDataSourceImpl())
  )

  const sdkInit = () => {
    setSdkInit(true)
    MultiDrmSdk.initialize(siteId)
  }

  const setMultiDrmEvents = () => {
    if (listeners.length == 0) {
      const events = []
      events.push(
        MultiDrmSdk.addMultiDrmEvent(
          MultiDrmEventType.complete,
          (event) => {
            updateMovies(event.url, "downloadState", downloadState.success)
          }
        )
      )

      events.push(
        MultiDrmSdk.addMultiDrmEvent(
          MultiDrmEventType.pause,
          (event) => {
            updateMovies(event.url, "downloadState", downloadState.pause)
          }
        )
      )

      events.push(
        MultiDrmSdk.addMultiDrmEvent(
          MultiDrmEventType.remove,
          (event) => {
            updateMovies(event.url, "downloadState", "")
          }
        )
      )

      events.push(
        MultiDrmSdk.addMultiDrmEvent(
          MultiDrmEventType.stop,
          (event) => {
            updateMovies(event.url, "downloadState", "")
          }
        )
      )

      events.push(
        MultiDrmSdk.addMultiDrmEvent(
          MultiDrmEventType.download,
          (event) => {
            updateMovies(event.url, "downloadState", downloadState.running)
          }
        )
      )

      events.push(
        MultiDrmSdk.addMultiDrmEvent(
          MultiDrmEventType.contentDataError,
          (event) => {
            setError(event.errorCode + ": " + event.message)
          }
        )
      )

      events.push(
        MultiDrmSdk.addMultiDrmEvent(
          MultiDrmEventType.drmError,
          (event) => {
            setError(event.errorCode + ": " + event.message)
            // updateMovies(event.url, "downloadState", downloadState.failed);
          }
        )
      )

      events.push(
        MultiDrmSdk.addMultiDrmEvent(
          MultiDrmEventType.licenseServerError,
          (event) => {
            setError(event.errorCode + ": " + event.message)
          }
        )
      )

      events.push(
        MultiDrmSdk.addMultiDrmEvent(
          MultiDrmEventType.downloadError,
          (event) => {
            setError(event.errorCode + ": " + event.message)
            updateMovies(event.url, "downloadState", downloadState.failed)
          }
        )
      )

      events.push(
        MultiDrmSdk.addMultiDrmEvent(
          MultiDrmEventType.networkConnectedError,
          (event) => {
            setError(event.errorCode + ": " + event.message)
          }
        )
      )

      events.push(
        MultiDrmSdk.addMultiDrmEvent(
          MultiDrmEventType.detectedDeviceTimeModifiedError,
          (event) => {
            setError(event.errorCode + ": " + event.message)
          }
        )
      )

      events.push(
        MultiDrmSdk.addMultiDrmEvent(
          MultiDrmEventType.migrationError,
          (event) => {
            setError(event.errorCode + ": " + event.message)
          }
        )
      )

      events.push(
        MultiDrmSdk.addMultiDrmEvent(
          MultiDrmEventType.licenseCipherError,
          (event) => {
            setError(event.errorCode + ": " + event.message)
          }
        )
      )

      events.push(
        MultiDrmSdk.addMultiDrmEvent(
          MultiDrmEventType.unknownError,
          (event) => {
            setError(event.errorCode + ": " + event.message)
          }
        )
      )

      events.push(
        MultiDrmSdk.addMultiDrmEvent(
          MultiDrmEventType.progress,
          (event) => {
            updateProgress(event.url, event.percent)
          }
        )
      )

      setListeners(events)
    }

    MultiDrmSdk.setMultiDrmEvents()
  }

  const updateMovies = useCallback(
    (url: string | null, name: any, value: any) => {
      setMovies((prevMovies) => {
        const newArray = prevMovies.map((item, i) => {
          if (url === item.url) {
            return { ...item, [name]: value }
          } else {
            return item
          }
        })
        return newArray
      })
    },
    []
  )

  const getMovies = async () => {
    await setConfigs(await UseCase.invoke())
  }

  const downloadCheck = async (config: DrmContentConfiguration) => {
    try {
      const state = await MultiDrmSdk.getDownloadState(config)
      switch (state) {
        case ContentDownloadState.DOWNLOADING:
          return downloadState.running
        case ContentDownloadState.PAUSED:
          return downloadState.pause
        case ContentDownloadState.COMPLETED:
          return downloadState.success
        default:
          return downloadState.pending
      }
    } catch (e: any) {
      setError(e.message)
      return downloadState.failed
    }
  }

  const setConfigs = async (drmMovies: DrmMovie[]) => {
    const configs: DrmContentConfiguration[] = []
    const movies: DrmMovie[] = []
    for (let i = 0; i < drmMovies.length; i++) {
      const config: DrmContentConfiguration = {
        contentUrl: drmMovies[i].url,
        contentId: drmMovies[i].contentId,
        token: drmMovies[i].token,
        licenseUrl: drmMovies[i].licenseUrl,
        licenseCipherTablePath: drmMovies[i].licenseCipherTablePath,
        certificateUrl: drmMovies[i].certificateUrl,
      }

      const needsMigration = await MultiDrmSdk.needsMigrateDatabase(
        config
      )
      if (needsMigration) {
        await MultiDrmSdk.migrateDatabase(config)
      }

      const downloadState = await downloadCheck(config)
      const movie = drmMovies[i]
      movie.downloadState = downloadState
      movies.push(movie)
      configs.push(config)
    }

    setMovies(movies)
    setDrmContentConfigs(configs)
  }

  const getPlayerData = async (movie: DrmMovie): Promise<string> => {
    if (!isSdkInit) {
      sdkInit()
    }

    const index = drmContentConfigs.findIndex(
      (element) => element.contentUrl === movie.url
    )

    try {
      return await MultiDrmSdk.getObjectForContent(
        drmContentConfigs[index]
      )
    } catch (e: any) {
      setError(e.message)
      return ""
    }
  }

  const downloadMovie = async (movie: DrmMovie): Promise<void> => {
    if (!isSdkInit) {
      sdkInit()
    }

    const index = drmContentConfigs.findIndex(
      (element) => element.contentUrl === movie.url
    )
    if (movies[index].downloadState === downloadState.pause) {
      await MultiDrmSdk.resumeDownloads()
    } else {
      try {
        await MultiDrmSdk.addStartDownload(
          drmContentConfigs[index]
        )
      } catch (e: any) {
        setError(e.message)
      }
    }

    updateMovies(movie.url, "downloadState", downloadState.running)
  }

  const pauseMovie = (movie: DrmMovie) => {
    if (!isSdkInit) {
      sdkInit()
    }

    MultiDrmSdk.pauseDownloads()
  }

  const removeMovie = async (movie: DrmMovie): Promise<void> => {
    if (!isSdkInit) {
      sdkInit()
    }

    const index = drmContentConfigs.findIndex(
      (element) => element.contentUrl === movie.url
    )

    try {
      await MultiDrmSdk.removeDownload(drmContentConfigs[index])
    } catch (e: any) {
      setError(e.message)
    }
  }

  const removeLicense = async (movie: DrmMovie) => {
    if (!isSdkInit) {
      sdkInit()
    }

    const index = drmContentConfigs.findIndex(
      (element) => element.contentUrl === movie.url
    )

    try {
      await MultiDrmSdk.removeLicense(drmContentConfigs[index])
    } catch (e: any) {
      setError(e.message)
    }
  }

  // const updateMovies = (url: string | null, name: any, value: any) => {
  //     const newArray = movies.map((item, i) => {
  //         if (url === item.url) {
  //             return {...item, [name]: value};
  //         } else {
  //             return item;
  //         }
  //     });
  //     setMovies(newArray);
  // };

  const updateProgress = (url: string | null, percent: number | null) => {
    const index = downloadPercent.findIndex((element) => element[0] === url)
    if (url !== null && index < 0) {
      updateMovies(url!, "downloadState", downloadState.running)
      downloadPercent.push([url!, 0])
    }

    const newArray = downloadPercent.map((item, i) => {
      if (url === item[0]) {
        item[1] = percent ? Math.floor(percent) : 0
      }
      return item
    })
    setDownloadPercent(newArray)
  }

  const removeListeners = () => {
    setListeners([])
  }

  const clearError = () => {
    setError("")
  }

  return {
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
  }
}
