package com.pallycon.multidrm

import PallyConContentConfiguration
import android.os.Bundle
import com.facebook.react.bridge.*
import com.pallycon.multidrm.event.DownloadProgressEventImpl
import com.pallycon.multidrm.event.PallyConEventImpl
import com.pallycon.multidrm.sdk.PallyConSdk
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.launch

class PallyConDrmSdk(reactContext: ReactApplicationContext) :
    ReactContextBaseJavaModule(reactContext) {
    private val context = reactContext
    private var drmSdk: PallyConSdk? = null
    private val scope = MainScope()
    private val licenseUrl = "https://drm-license.doverunner.com/ri/licenseManager.do"

    override fun getName(): String {
        return "PallyConDrmSdkModule"
    }

    override fun getConstants(): MutableMap<String, Any>? {
        val constants = HashMap<String, Any>()

//        constants["REPEAT_OFF"] = Player.REPEAT_MODE_OFF

        return constants;
    }

    override fun canOverrideExistingModule(): Boolean {
        return true
    }

    private fun bundleToConfig(bundle: Bundle?): PallyConContentConfiguration? {
        bundle?.let {
            val config = PallyConContentConfiguration(context, it)
            if (config.contentUrl == null || config.licenseUrl == null ||
                (config.token == null && config.customData == null)) {
                return config
            }

            return config
        } ?: run {
            return null
        }
    }

    @ReactMethod
    fun initialize(siteId: String) {
        print("initialize - $siteId")
        drmSdk = PallyConSdk.getInstance(context)
        drmSdk?.setMultiDrmEvents(PallyConEventImpl(context))
        drmSdk?.setDownloadProgressEvent(DownloadProgressEventImpl(context))
        drmSdk?.initialize(siteId)
    }

    @ReactMethod
    fun setMultiDrmEvents() {
        drmSdk?.setMultiDrmEvents(PallyConEventImpl(context))
    }

    @ReactMethod
    fun getObjectForContent(data: ReadableMap?, callback: Promise) = scope.launch {
        if (data == null) {
            callback.resolve(null)
            return@launch
        }

        var bundle = Arguments.toBundle(data)
        bundleToConfig(bundle)?.let {
            GlobalScope.launch {
                if (it.isSuccessConvert()) {
                    val gson = drmSdk?.getObjectForContent(it);
                    callback.resolve(gson)
                } else {
                    callback.reject("ILLEGAL_ARGUMENT", "required argument", null)
                }
            }
        }  ?: run {
            callback.reject("ILLEGAL_ARGUMENT", "required argument")
        }
    }

    @ReactMethod
    fun getDownloadState(data: ReadableMap?, callback: Promise) {
        if (data == null) {
            callback.resolve(null)
            return
        }

        var bundle = Arguments.toBundle(data)
        bundleToConfig(bundle)?.let {
            if (it.isSuccessConvert()) {
                val state = drmSdk?.getDownloadState(it);
                callback.resolve(state)
            } else {
                callback.reject("ILLEGAL_ARGUMENT", "required argument", null)
            }
        }  ?: run {
            callback.reject("ILLEGAL_ARGUMENT", "required argument")
        }
    }

    @ReactMethod
    fun addStartDownload(data: ReadableMap?, callback: Promise) {
        if (data == null) {
            callback.resolve(null)
            return
        }

        var bundle = Arguments.toBundle(data)
        bundleToConfig(bundle)?.let {
            if (it.isSuccessConvert()) {
                drmSdk?.addStartDownload(it)
                callback.resolve(null)
            } else {
                callback.reject("ILLEGAL_ARGUMENT", "required argument", null)
            }
        }  ?: run {
            callback.reject("ILLEGAL_ARGUMENT", "required argument")
        }
    }

    @ReactMethod
    fun resumeDownloads() {
        drmSdk?.resumeAll()
    }

    @ReactMethod
    fun cancelDownloads() {
        drmSdk?.cancelAll()
    }

    @ReactMethod
    fun pauseDownloads() {
        drmSdk?.pauseAll()
    }

    @ReactMethod
    fun removeDownload(data: ReadableMap?, callback: Promise) {
        if (data == null) {
            callback.resolve(null)
            return
        }

        var bundle = Arguments.toBundle(data)
        bundleToConfig(bundle)?.let {
            if (it.isSuccessConvert()) {
                val isOK = drmSdk?.removeDownload(it.contentUrl!!, it.contentId!!)
                if (isOK == true) {
                    callback.resolve(null)
                } else {
                    callback.reject("ILLEGAL_ARGUMENT", "check arguments", null)
                }
            } else {
                callback.reject("ILLEGAL_ARGUMENT", "required argument", null)
            }
        }  ?: run {
            callback.reject("ILLEGAL_ARGUMENT", "required argument")
        }
    }

    @ReactMethod
    fun removeLicense(data: ReadableMap?, callback: Promise) {
        if (data == null) {
            callback.resolve(null)
            return
        }

        var bundle = Arguments.toBundle(data)
        bundleToConfig(bundle)?.let {
            GlobalScope.launch {
                if (it.isSuccessConvert()) {
                    val isOK = drmSdk?.removeLicense(it.contentUrl!!, it.contentId!!)
                    if (isOK == true) {
                        callback.resolve(null)
                    } else {
                        callback.reject("ILLEGAL_ARGUMENT", "check arguments", null)
                    }
                } else {
                    callback.reject("ILLEGAL_ARGUMENT", "required argument", null)
                }
            }
        }  ?: run {
            callback.reject("ILLEGAL_ARGUMENT", "required argument")
        }
    }

    @ReactMethod
    fun needsMigrateDatabase(data: ReadableMap?, callback: Promise) = scope.launch {
        if (data == null) {
            callback.resolve(null)
            return@launch
        }

        var bundle = Arguments.toBundle(data)
        bundleToConfig(bundle)?.let {
            GlobalScope.launch {
                if (it.isSuccessConvert()) {
                    val isOK = drmSdk?.needsMigrateDatabase(it)
                    callback.resolve(isOK)
                } else {
                    callback.reject("ILLEGAL_ARGUMENT", "required argument", null)
                }
            }
        }  ?: run {
            callback.reject("ILLEGAL_ARGUMENT", "required argument")
        }
    }

    @ReactMethod
    fun migrateDatabase(data: ReadableMap?, callback: Promise) = scope.launch {
        if (data == null) {
            callback.resolve(null)
            return@launch
        }

        var bundle = Arguments.toBundle(data)
        bundleToConfig(bundle)?.let {
            GlobalScope.launch {
                if (it.isSuccessConvert()) {
                    val isOK = drmSdk?.migrateDatabase(it)
                    callback.resolve(isOK)
                } else {
                    callback.reject("ILLEGAL_ARGUMENT", "required argument", null)
                }
            }
        }  ?: run {
            callback.reject("ILLEGAL_ARGUMENT", "required argument")
        }
    }

    @ReactMethod
    fun reDownloadCertification(callback: Promise) = scope.launch {
        val isOK = drmSdk?.reDownloadCertification()
        callback.resolve(isOK)

//        var bundle = Arguments.toBundle(data)
//        bundleToConfig(bundle)?.let {
//            GlobalScope.launch {
//                if (it.isSuccessConvert()) {
//                    val isOK = drmSdk?.reDownloadCertification()
//                    callback.resolve(isOK)
//                } else {
//                    callback.reject("ILLEGAL_ARGUMENT", "required argument", null)
//                }
//            }
//        }  ?: run {
//            callback.reject("ILLEGAL_ARGUMENT", "required argument")
//        }
    }

    @ReactMethod
    fun updateSecureTime(callback: Promise) = scope.launch {
        val isOK = drmSdk?.updateSecureTime()
        callback.resolve(isOK)
    }
}
