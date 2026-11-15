package com.mossapps.flick.youtube

import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonArray
import kotlinx.serialization.json.JsonPrimitive
import kotlinx.serialization.json.contentOrNull
import okhttp3.Request
import java.util.Locale

/**
 * The minimum session state required by BitChord's InnerTubeX resolver.
 * Cookies are only supplied to YouTube API requests inside InnerTubeX and are
 * never attached to googlevideo media requests.
 */
internal object Innertube {
    @Volatile
    var cookie: String? = null
        private set

    @Volatile
    private var visitorData: String? = null

    @Volatile
    private var visitorIsSessionBound = false

    val currentRegion: String
        get() = Locale.getDefault().country.takeIf { it.isNotBlank() } ?: "US"

    val currentLanguage: String
        get() = Locale.getDefault().language.takeIf { it.isNotBlank() } ?: "en"

    @Synchronized
    fun updateSession(nextCookie: String?, signedVisitorData: String?): Boolean {
        val normalizedCookie = nextCookie?.takeIf { it.isNotBlank() }
        val previousCookie = cookie
        val previousVisitor = visitorData
        if (previousCookie != normalizedCookie) {
            cookie = normalizedCookie
            visitorData = null
            visitorIsSessionBound = false
        }
        if (!signedVisitorData.isNullOrBlank()) {
            visitorData = signedVisitorData
            visitorIsSessionBound = normalizedCookie != null
        }
        return previousCookie != normalizedCookie || previousVisitor != visitorData
    }

    suspend fun ensureVisitorData(refresh: Boolean = false): String? {
        if (!refresh && visitorData != null) return visitorData
        val fresh = runCatching {
            withContext(Dispatchers.IO) {
                val request = Request.Builder()
                    .url("https://www.youtube.com/sw.js_data")
                    .header(
                        "User-Agent",
                        "Mozilla/5.0 (Linux; Android 14; Pixel 7 Pro) AppleWebKit/537.36 " +
                            "(KHTML, like Gecko) Chrome/141.0.0.0 Mobile Safari/537.36",
                    )
                    .build()
                Http.client.newCall(request).execute().use { response ->
                    if (!response.isSuccessful) error("visitor bootstrap HTTP ${response.code}")
                    val body = response.body?.string().orEmpty()
                    val json = Json.parseToJsonElement(body.substringAfter("\n", body.drop(5)))
                    findVisitorData(json)
                }
            }
        }.onFailure { TrackLog.w("InnerTubeX", "Visitor-data bootstrap failed (${it.javaClass.simpleName}).") }
            .getOrNull()
        if (!fresh.isNullOrBlank() && (refresh || !visitorIsSessionBound)) {
            visitorData = fresh
            visitorIsSessionBound = false
        }
        return visitorData
    }

    private fun findVisitorData(value: kotlinx.serialization.json.JsonElement): String? =
        when (value) {
            is JsonArray -> value.firstNotNullOfOrNull(::findVisitorData)
            is JsonPrimitive -> value.contentOrNull?.takeIf { VISITOR_DATA.matches(it) }
            else -> null
        }

    private val VISITOR_DATA = Regex("""Cg[A-Za-z0-9_%-]{40,}""")
}
