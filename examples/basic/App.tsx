import React, {useEffect, useState} from 'react';
import {
    Platform,
    StyleSheet,
    View,
    ActivityIndicator
} from 'react-native';
import {
    DrmContentConfiguration
} from 'doverunner-react-native-sdk';
import ReactMultiDrmSdk from 'doverunner-react-native-sdk';
import Video from 'react-native-video';
import base64 from 'react-native-base64';

const App = () => {
    const [decodedJson, setDecodedJson] = useState('');
    const [videoUrl, setVideoUrl] = useState('');
    const [isLoading, setIsLoading] = useState(true);

    useEffect(() => {
        const getData = async () => {
            try {
                // Multi-DRM React Native sdk use
                // Initialize SDK with ‘DEMO’ site ID
                ReactMultiDrmSdk.initialize('DEMO');

                let config: DrmContentConfiguration;
                if (Platform.OS === 'android') {
                    // android
                    config = {
                        contentUrl: 'https://drm-contents.doverunner.com/DEMO/app/big_buck_bunny/dash/stream.mpd',
                        contentId: 'demo-bbb-simple',
                        token: 'eyJkcm1fdHlwZSI6IldpZGV2aW5lIiwic2l0ZV9pZCI6IkRFTU8iLCJ1c2VyX2lkIjoidGVzdFVzZXIiLCJjaWQiOiJkZW1vLWJiYi1zaW1wbGUiLCJwb2xpY3kiOiI5V3FJV2tkaHB4VkdLOFBTSVljbkp1dUNXTmlOK240S1ZqaTNpcEhIcDlFcTdITk9uYlh6QS9pdTdSa0Vwbk85c0YrSjR6R000ZkdCMzVnTGVORGNHYWdPY1Q4Ykh5c3k0ZHhSY2hYV2tUcDVLdXFlT0ljVFFzM2E3VXBnVVdTUCIsInJlc3BvbnNlX2Zvcm1hdCI6Im9yaWdpbmFsIiwia2V5X3JvdGF0aW9uIjpmYWxzZSwidGltZXN0YW1wIjoiMjAyMi0wOS0xOVQwNzo0Mjo0MFoiLCJoYXNoIjoiNDBDb1RuNEpFTnpZUHZrT1lTMHkvK2VIN1dHK0ZidUIvcThtR3VoaHVNRT0ifQ'
                    };
                } else {
                    // iOS
                    config = {
                        contentUrl: 'https://drm-contents.doverunner.com/DEMO/app/big_buck_bunny/hls/master.m3u8',
                        contentId: 'demo-bbb-simple',
                        token: 'eyJrZXlfcm90YXRpb24iOmZhbHNlLCJyZXNwb25zZV9mb3JtYXQiOiJvcmlnaW5hbCIsInVzZXJfaWQiOiJ0ZXN0VXNlciIsImRybV90eXBlIjoiZmFpcnBsYXkiLCJzaXRlX2lkIjoiREVNTyIsImhhc2giOiJKOHZTeWVPenVMZTQzRXM4OURpekc1YzFBa2trTnI2RkJcLzhBd3d3dHNaUT0iLCJjaWQiOiJkZW1vLWJiYi1zaW1wbGUiLCJwb2xpY3kiOiI5V3FJV2tkaHB4VkdLOFBTSVljbkpzY3Z1QTlzeGd1YkxzZCthanVcL2JvbVFaUGJxSSt4YWVZZlFvY2NrdnVFZnhEY2NtN2NXZFZYcXJkTWdBUWptcVo5bzdYTEZ6MjBOaG1Kdklpd1FidWhLaCtDMmZJSEw5T3UxU09Bc2hQU0FWZHhhWVVKSnJsWjVVMXU1UGNlcjE0NVpCczdnc3ZRc0lsbDlGVHZXanQ3bWhaOHJ3ejdybVNYcURBdEdqYTRsYmVrUnhcL1pyRWx4dkJhWXV0YWFvdVlISWpkNlZpRWVXZEVpRzJIV0VIMGczcW1LYW1QbUp2VUluN0tVODZrUDQiLCJ0aW1lc3RhbXAiOiIyMDI1LTA1LTExVDIyOjM0OjQ5WiJ9'
                    };
                }
                // Set the source object for the video player with the content configuration
                const sourceObject = await ReactMultiDrmSdk.getObjectForContent(config);
                const decodedJson: string = base64.decode(sourceObject);
                let parsedData;
                try {
                    parsedData = JSON.parse(decodedJson);
                } catch (error) {
                    console.error("Error parsing JSON:", error);
                    setIsLoading(false);
                    return;
                }

                const videoUrl = parsedData.url;
                
                setVideoUrl(videoUrl);
                setDecodedJson(decodedJson);
            } catch (error) {
                console.error('Error setting up video source:', error);
            } finally {
                setIsLoading(false);
            }
        };

        getData();
    }, []);


    const onLoad = (data: any) => {
        console.log('onLoad');
    };

    const onProgress = (data: any) => {
        console.log('onProgress');
    };

    const onEnd = () => {
        console.log('onEnd');
    };

    const onError = (err: any) => {
        console.log(JSON.stringify(err?.error.errorCode));
    };

    const viewStyle = state.fullscreen ? styles.fullScreen : styles.halfScreen;

    if (isLoading) {
        return (
            <View style={styles.container}>
                <ActivityIndicator size="large" color="#0000ff" />
            </View>
        );
    }

    return (
        <View style={styles.container}> 
            <Video
                source={{
                    uri: videoUrl,
                    headers: { MultiDrmJson: decodedJson }
                }}
                style={viewStyle}
                rate={state.rate}
                paused={state.paused}
                volume={state.volume}
                muted={state.muted}
                fullscreen={state.fullscreen}
                controls={state.showRNVControls}
                onLoad={onLoad}
                onProgress={onProgress}
                onEnd={onEnd}
                progressUpdateInterval={1000}
                onError={onError}
                playInBackground={false}
            />
        </View>
    );
};

const styles = StyleSheet.create({
    container: {
        flex: 1,
        justifyContent: 'center',
        alignItems: 'center',
        backgroundColor: 'black',
    },
    halfScreen: {
        position: 'absolute',
        top: 50,
        left: 50,
        bottom: 100,
        right: 100,
    },
    fullScreen: {
        position: 'absolute',
        top: 0,
        left: 0,
        bottom: 0,
        right: 0,
    },
    bottomControls: {
        backgroundColor: 'transparent',
        borderRadius: 5,
        position: 'absolute',
        bottom: 20,
        left: 20,
        right: 20,
    },
    leftControls: {
        backgroundColor: 'transparent',
        borderRadius: 5,
        position: 'absolute',
        top: 20,
        bottom: 20,
        left: 20,
    },
    rightControls: {
        backgroundColor: 'transparent',
        borderRadius: 5,
        position: 'absolute',
        top: 20,
        bottom: 20,
        right: 20,
    },
    topControls: {
        backgroundColor: 'transparent',
        borderRadius: 4,
        position: 'absolute',
        top: 20,
        left: 20,
        right: 20,
        flex: 1,
        flexDirection: 'row',
        overflow: 'hidden',
        paddingBottom: 10,
    },
    generalControls: {
        flex: 1,
        flexDirection: 'row',
        borderRadius: 4,
        overflow: 'hidden',
        paddingBottom: 10,
    },
    rateControl: {
        flex: 1,
        flexDirection: 'row',
        justifyContent: 'center',
    },
    volumeControl: {
        flex: 1,
        flexDirection: 'row',
        justifyContent: 'center',
    },
    resizeModeControl: {
        flex: 1,
        flexDirection: 'row',
        alignItems: 'center',
        justifyContent: 'center',
    },
    leftRightControlOption: {
        alignSelf: 'center',
        fontSize: 11,
        color: 'white',
        padding: 10,
        lineHeight: 12,
    },
    controlOption: {
        alignSelf: 'center',
        fontSize: 11,
        color: 'white',
        paddingLeft: 2,
        paddingRight: 2,
        lineHeight: 12,
    },
    IndicatorStyle: {
        flex: 1,
        justifyContent: 'center',
    },
    seekbarContainer: {
        flex: 1,
        flexDirection: 'row',
        borderRadius: 4,
        height: 30,
    },
    seekbarTrack: {
        backgroundColor: '#333',
        height: 1,
        position: 'relative',
        top: 14,
        width: '100%',
    },
    seekbarFill: {
        backgroundColor: '#FFF',
        height: 1,
        width: '100%',
    },
    seekbarHandle: {
        position: 'absolute',
        marginLeft: -7,
        height: 28,
        width: 28,
    },
    seekbarCircle: {
        borderRadius: 12,
        position: 'relative',
        top: 8,
        left: 8,
        height: 12,
        width: 12,
    },
    picker: {
        color: 'white',
        flex: 1,
        flexDirection: 'row',
        justifyContent: 'center',
    },
});

const state = {
    rate: 1,
    volume: 1,
    muted: false,
    resizeMode: 'contain',
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
};

export default App;
