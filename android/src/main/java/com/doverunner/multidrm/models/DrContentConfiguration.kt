import android.content.Context
import android.os.Bundle

class DrContentConfiguration(
    context: Context, bundle: Bundle
) {
    var contentUrl: String? = null
    var contentId: String? = null
    var drmType: String? = null
    var token: String? = null
    var customData: String? = null
    var contentCookie: String? = null
    var contentHttpHeaders: MutableMap<String, String>? = null
    var licenseCookie: String? = null
    var licenseHttpHeaders: MutableMap<String, String>? = null
    var licenseUrl: String? = null
    var certificateUrl: String? = null
    var licenseCipherTablePath: String? = null

    init {
        contentUrl = bundle?.getString("contentUrl")
        contentId = bundle?.getString("contentId")
        drmType = bundle?.getString("drmType")
        token = bundle?.getString("token")
        customData = bundle?.getString("customData")
        contentCookie = bundle?.getString("contentCookie")
        val contentHeaders = bundle.getBundle("contentHttpHeaders")
        if (contentHeaders != null) {
            contentHttpHeaders = HashMap()
            for (header in contentHeaders.keySet()) {
                contentHttpHeaders!![header] = contentHeaders.getString(header)!!
            }
        }
        licenseCookie = bundle?.getString("licenseCookie")
        val licenseHeaders = bundle.getBundle("licenseHttpHeaders")
        if (licenseHeaders != null) {
            licenseHttpHeaders = HashMap()
            for (header in licenseHeaders.keySet()) {
                licenseHttpHeaders!![header] = licenseHeaders.getString(header)!!
            }
        }
        licenseUrl = bundle?.getString("licenseUrl")
        certificateUrl = bundle?.getString("certificateUrl")
        licenseCipherTablePath = bundle?.getString("licenseCipherTablePath")
    }

    fun isSuccessConvert(): Boolean {
        if (this.contentUrl != null && this.contentId != null) {
            return true
        }

        return false;
    }
}
