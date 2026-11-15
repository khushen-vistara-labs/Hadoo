package com.mossapps.flick

import android.annotation.SuppressLint
import android.app.Activity
import android.app.Dialog
import android.graphics.Color
import android.graphics.drawable.ColorDrawable
import android.net.Uri
import android.view.Gravity
import android.view.KeyEvent
import android.view.View
import android.view.ViewGroup
import android.webkit.CookieManager
import android.webkit.WebResourceRequest
import androidx.webkit.WebViewCompat
import androidx.webkit.WebViewFeature
import kotlinx.coroutines.delay
import java.util.concurrent.ConcurrentHashMap
import android.webkit.WebStorage
import android.webkit.WebView
import android.webkit.WebViewClient
import android.widget.FrameLayout
import android.widget.ImageButton
import kotlinx.coroutines.CompletableDeferred
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import kotlinx.coroutines.withTimeoutOrNull
import org.json.JSONObject
import java.nio.charset.StandardCharsets

/**
 * BitChord-style Spotify web session support.
 *
 * The login is deliberately shown in one in-app WebView. The cookie stays in
 * Dart's encrypted store; this class only receives it when it needs to mint a
 * short-lived web-player bearer token for a Spotify API request.
 */
internal class SpotifyWebSession(private val activity: Activity) {
    class SessionException(message: String) : Exception(message)


    data class MintedTokens(
        val accessToken: String,
        val clientToken: String?,
        val expiresAtMs: Long,
        val queryHashes: Map<String, String>,
    ) {
        fun asMap(): Map<String, Any?> = mapOf(
            "accessToken" to accessToken,
            "clientToken" to clientToken,
            "expiresAtMs" to expiresAtMs,
            "queryHashes" to queryHashes,
        )
    }

    private data class LoginState(
        val dialog: Dialog,
        val webView: WebView,
        val callback: (String?) -> Unit,
    )

    private var loginState: LoginState? = null

    @SuppressLint("SetJavaScriptEnabled")
    fun authenticate(onResult: (String?) -> Unit) {
        if (loginState != null) {
            onResult(null)
            return
        }

        val dialog = Dialog(activity)
        val webView = WebView(activity)
        val container = FrameLayout(activity)
        val close = ImageButton(activity).apply {
            setImageResource(android.R.drawable.ic_menu_close_clear_cancel)
            setBackgroundColor(Color.TRANSPARENT)
            contentDescription = "Close Spotify sign-in"
            setOnClickListener { finishLogin(null) }
        }

        container.setBackgroundColor(Color.rgb(18, 18, 18))
        container.addView(
            webView,
            FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT,
            ),
        )
        container.addView(
            close,
            FrameLayout.LayoutParams(56, 56, Gravity.TOP or Gravity.END),
        )

        webView.settings.javaScriptEnabled = true
        webView.settings.domStorageEnabled = true
        webView.settings.userAgentString = browserUserAgent(webView.settings.userAgentString)
        webView.setBackgroundColor(Color.rgb(18, 18, 18))
        val cookies = CookieManager.getInstance()
        cookies.setAcceptCookie(true)
        cookies.setAcceptThirdPartyCookies(webView, true)

        webView.webViewClient = object : WebViewClient() {
            override fun shouldOverrideUrlLoading(
                view: WebView,
                request: WebResourceRequest,
            ): Boolean = !isLoginHost(request.url)

            @Suppress("DEPRECATION")
            override fun shouldOverrideUrlLoading(view: WebView, url: String): Boolean =
                !isLoginHost(Uri.parse(url))

            override fun onPageFinished(view: WebView, url: String?) {
                if (!isSpotifyOpenUrl(url)) return
                val cookie = extractSessionCookie(cookies.getCookie(SPOTIFY_OPEN_URL))
                if (cookie != null) {
                    view.visibility = View.GONE
                    finishLogin(cookie)
                }
            }
        }

        loginState = LoginState(dialog, webView, onResult)
        dialog.setContentView(container)
        dialog.setOnCancelListener { finishLogin(null) }
        dialog.setOnKeyListener { _, keyCode, event ->
            if (keyCode != KeyEvent.KEYCODE_BACK || event.action != KeyEvent.ACTION_UP) {
                return@setOnKeyListener false
            }
            if (webView.canGoBack()) {
                webView.goBack()
            } else {
                finishLogin(null)
            }
            true
        }
        dialog.window?.setBackgroundDrawable(ColorDrawable(Color.TRANSPARENT))
        dialog.show()
        dialog.window?.setLayout(
            ViewGroup.LayoutParams.MATCH_PARENT,
            ViewGroup.LayoutParams.MATCH_PARENT,
        )
        webView.loadUrl(LOGIN_URL)
    }

    fun cancelLogin() {
        finishLogin(null)
    }

    fun clearSpotifyCookies() {
        val cookies = CookieManager.getInstance()
        for (url in COOKIE_URLS) {
            val names = cookies.getCookie(url)
                ?.split(";")
                ?.map { it.substringBefore("=").trim() }
                ?.filter { it.isNotEmpty() }
                .orEmpty()
            for (name in names) {
                val expired = "$name=; Max-Age=0; Expires=Thu, 01 Jan 1970 00:00:00 GMT; Path=/"
                cookies.setCookie(url, expired)
                cookies.setCookie(url, "$expired; Domain=.spotify.com")
            }
        }
        cookies.flush()
    }

    suspend fun mintTokens(spDc: String): MintedTokens? {
        val cookie = spDc.trim()
        if (cookie.isEmpty()) return null

        return withContext(Dispatchers.Main.immediate) { harvestSession(cookie) }
    }

    private fun finishLogin(cookie: String?) {
        val active = loginState ?: return
        loginState = null
        active.webView.stopLoading()
        active.webView.destroy()
        active.dialog.dismiss()
        active.callback(cookie)
    }

    @SuppressLint("SetJavaScriptEnabled")
    private suspend fun harvestSession(spDc: String): MintedTokens? {
        val cookies = CookieManager.getInstance().apply { setAcceptCookie(true) }
        runCatching { WebStorage.getInstance().deleteOrigin("https://open.spotify.com") }
        val cookieReady = CompletableDeferred<Unit>()
        // A previously entered host-only cookie takes precedence over the domain
        // cookie. Remove that copy before installing the replacement session.
        cookies.setCookie(SPOTIFY_OPEN_URL, "sp_dc=; Max-Age=0; Path=/; Secure") {
            cookies.setCookie(SPOTIFY_OPEN_URL, "sp_dc=$spDc; Domain=.spotify.com; Path=/; Secure; HttpOnly") { accepted ->
                if (accepted) cookieReady.complete(Unit)
                else cookieReady.completeExceptionally(SessionException("Android rejected the Spotify cookie. Paste only the sp_dc value."))
            }
        }
        if (withTimeoutOrNull(3000L) { cookieReady.await(); true } != true)
            throw SessionException("Android could not install the Spotify cookie. Try again.")
        val bridge = TokenBridge()
        val hook = activity.assets.open("flutter_assets/assets/spotify/session_hook.js").bufferedReader().use { it.readText() }
        val webView = WebView(activity)
        val host = activity.window.decorView as ViewGroup
        var loadFailure: String? = null
        val messageBridge = WebViewFeature.isFeatureSupported(WebViewFeature.WEB_MESSAGE_LISTENER)
        try {
            // An unattached WebView may never render/start the WebPlayer on
            // Android. Keep it attached behind the opaque Flutter surface for
            // this bounded session harvest; remove it before returning.
            webView.importantForAccessibility = View.IMPORTANT_FOR_ACCESSIBILITY_NO_HIDE_DESCENDANTS
            webView.isFocusable = false
            webView.isClickable = false
            host.addView(webView, 0, ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT))
            webView.onResume()
            webView.settings.javaScriptEnabled = true
            webView.settings.domStorageEnabled = true
            webView.settings.userAgentString = CANVAS_USER_AGENT
            webView.settings.mediaPlaybackRequiresUserGesture = true
            cookies.setAcceptThirdPartyCookies(webView, true)
            if (messageBridge) {
                WebViewCompat.addWebMessageListener(webView, BRIDGE_NAME, setOf("https://open.spotify.com")) { _, message, _, isMainFrame, _ ->
                    if (isMainFrame) bridge.onSessionPayload(message.data)
                }
            }
            if (WebViewFeature.isFeatureSupported(WebViewFeature.DOCUMENT_START_SCRIPT)) {
                WebViewCompat.addDocumentStartJavaScript(webView, hook, setOf("https://open.spotify.com"))
            }
            webView.webViewClient = object : WebViewClient() {
                override fun shouldOverrideUrlLoading(view: WebView, request: WebResourceRequest): Boolean =
                    !isSpotifyOpenUrl(request.url.toString())
                override fun onPageStarted(view: WebView, url: String?, favicon: android.graphics.Bitmap?) {
                    if (isSpotifyOpenUrl(url)) view.evaluateJavascript(hook, null)
                }
                override fun onPageFinished(view: WebView, url: String?) {
                    if (isSpotifyOpenUrl(url)) view.evaluateJavascript(hook, null)
                }
                override fun onReceivedError(view: WebView, request: WebResourceRequest, error: android.webkit.WebResourceError) {
                    if (request.isForMainFrame) loadFailure = "Spotify's web player could not load. Check your network, VPN or private DNS."
                }
                override fun onReceivedHttpError(view: WebView, request: WebResourceRequest, errorResponse: android.webkit.WebResourceResponse) {
                    if (request.isForMainFrame && errorResponse.statusCode >= 400)
                        loadFailure = "Spotify's web player returned HTTP ${errorResponse.statusCode}. Try again later."
                }
                override fun shouldInterceptRequest(view: WebView, request: WebResourceRequest): android.webkit.WebResourceResponse? {
                    val host = request.url.host.orEmpty()
                    if (request.url.scheme == "https" && (host == "spotify.com" || host.endsWith(".spotify.com"))) {
                        bridge.captureHeaders(request.requestHeaders)
                    }
                    return null
                }
            }
            webView.loadUrl(SPOTIFY_OPEN_URL)
            withTimeoutOrNull(HARVEST_TIMEOUT_MS) { bridge.ready.await() }
            // Wait briefly for the actual loaded query bundles, not only tokens.
            for (attempt in 0 until 8) {
                if (bridge.hashes.containsKey("home") && bridge.hashes.containsKey("canvas")) break
                delay(500L)
            }
            loadFailure?.let { throw SessionException(it) }
            if (bridge.anonymous) throw SessionException("Spotify did not recognize this cookie. Copy a fresh sp_dc value from your signed-in browser.")
            if (bridge.accessToken == null) throw SessionException("Spotify's web player did not finish signing in. Try again; the cookie may still be valid.")
            if (bridge.clientToken == null) throw SessionException("Spotify's web player did not initialize its client session. Update Android System WebView and retry.")
            // Discovery and Canvas use the actual WebPlayer credentials.
            // Do not gate these on api.spotify.com/v1/me: public Web API
            // policy/scopes can refuse a valid first-party WebPlayer bearer.
            // Explicit anonymous responses are rejected above; API callers
            // handle their own session/auth failures without fabricating tokens.
            return MintedTokens(bridge.accessToken!!, bridge.clientToken, minOf(bridge.expiresAtMs, bridge.clientExpiresAtMs), bridge.hashes.toMap())
        } finally {
            if (messageBridge) WebViewCompat.removeWebMessageListener(webView, BRIDGE_NAME)
            webView.stopLoading()
            host.removeView(webView)
            webView.destroy()
        }
    }

    private class TokenBridge {
        val ready = CompletableDeferred<Unit>()
        @Volatile var accessToken: String? = null
        @Volatile var clientToken: String? = null
        @Volatile var anonymous = false
        @Volatile var verifiedAccess = false
        @Volatile var expiresAtMs = System.currentTimeMillis() + 45 * 60 * 1000L
        @Volatile var clientExpiresAtMs = System.currentTimeMillis() + 45 * 60 * 1000L
        val hashes = ConcurrentHashMap<String, String>()
        private fun signal() { if (!anonymous && accessToken != null && clientToken != null && !ready.isCompleted) ready.complete(Unit) }
        @Synchronized fun captureHeaders(headers: Map<String, String>) {
            headers.entries.firstOrNull { it.key.equals("Authorization", true) }?.value
                ?.takeIf { it.startsWith("Bearer ") }?.removePrefix("Bearer ")?.takeIf { it.isNotBlank() }?.let { if (!verifiedAccess) accessToken = it }
            headers.entries.firstOrNull { it.key.equals("client-token", true) }?.value?.takeIf { it.isNotBlank() && it != "null" }?.let { clientToken = it }
            signal()
        }
        @Synchronized fun onSessionPayload(payload: String?) {
            if (payload == null || payload.length > 65536) return
            runCatching {
                val root = JSONObject(payload)
                when (root.optString("kind")) {
                    "headers" -> captureHeaders(mapOf("Authorization" to root.optString("authorization"), "client-token" to root.optString("clientToken")))
                    "access" -> root.getJSONObject("data").let { data ->
                        anonymous = data.optBoolean("isAnonymous", false)
                        verifiedAccess = data.has("accessToken") && !anonymous
                        data.optString("accessToken").takeIf { it.isNotBlank() }?.let { accessToken = it }
                        expiresAtMs = data.optLong("accessTokenExpirationTimestampMs", expiresAtMs)
                    }
                    "client" -> root.getJSONObject("data").optJSONObject("granted_token")?.let { data ->
                        clientExpiresAtMs = System.currentTimeMillis() + data.optLong("expires_after_seconds", 3600L) * 1000L
                        data.optString("token").takeIf { it.isNotBlank() && it != "null" }?.let { clientToken = it }
                    }
                    "hash" -> {
                        val op = root.optString("operation"); val hash = root.optString("hash")
                        if (op in setOf("home", "canvas", "searchTracks", "fetchPlaylist", "fetchLibraryTracks", "libraryV3", "addToLibrary") && hash.matches(Regex("[a-f0-9]{64}"))) hashes[op] = hash
                    }
                }
                signal()
            }
        }
    }

    private fun extractSessionCookie(raw: String?): String? = raw
        ?.split(";")
        ?.map { it.trim() }
        ?.firstOrNull { it.startsWith("sp_dc=") }
        ?.substringAfter('=')
        ?.takeIf { it.isNotBlank() }

    private fun isSpotifyOpenUrl(rawUrl: String?): Boolean {
        val uri = rawUrl?.let(Uri::parse) ?: return false
        return uri.scheme == "https" && uri.host?.lowercase() == "open.spotify.com"
    }

    private fun isLoginHost(uri: Uri?): Boolean {
        if (uri?.scheme != "https") return false
        val host = uri.host?.lowercase() ?: return false
        return LOGIN_HOST_SUFFIXES.any { suffix -> host == suffix || host.endsWith(".$suffix") }
    }

    private fun browserUserAgent(platformUserAgent: String?): String {
        val stripped = platformUserAgent
            ?.replace("; wv", "")
            ?.replace(Regex("Version\\d+(\\.\\d+)*\\s*"), "")
            ?.replace("  ", " ")
            ?.trim()
        return stripped?.takeIf { it.contains("Chrome/") } ?: FALLBACK_USER_AGENT
    }

    private companion object {
        const val LOGIN_URL =
            "https://accounts.spotify.com/login?continue=https%3A%2F%2Fopen.spotify.com%2F"
        const val SPOTIFY_OPEN_URL = "https://open.spotify.com/"
        const val SPOTIFY_ACCOUNTS_URL = "https://accounts.spotify.com/"
        const val BRIDGE_NAME = "KonnektedSpotifyTokenBridge"
        const val HARVEST_TIMEOUT_MS = 25_000L
        const val DEFAULT_TOKEN_LIFETIME_MS = 3_600_000L
        const val CANVAS_USER_AGENT =
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) " +
                "AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36"
        const val FALLBACK_USER_AGENT =
            "Mozilla/5.0 (Linux; Android 14; Mobile) " +
                "AppleWebKit/537.36 (KHTML, like Gecko) Chrome/129.0.0.0 Mobile Safari/537.36"
        val COOKIE_URLS = listOf(
            "https://open.spotify.com",
            "https://accounts.spotify.com",
            "https://www.spotify.com",
            "https://spotify.com",
        )
        val LOGIN_HOST_SUFFIXES = listOf(
            "spotify.com",
            "scdn.co",
            "google.com",
            "gstatic.com",
            "facebook.com",
            "apple.com",
        )
    }
}
