package com.mossapps.flick.youtube

import okhttp3.OkHttpClient
import java.util.concurrent.TimeUnit

/** Dedicated, bounded transport shared by InnerTubeX and BotGuard. */
internal object Http {
    val client: OkHttpClient = OkHttpClient.Builder()
        .connectTimeout(15, TimeUnit.SECONDS)
        .readTimeout(20, TimeUnit.SECONDS)
        .writeTimeout(20, TimeUnit.SECONDS)
        .callTimeout(30, TimeUnit.SECONDS)
        .retryOnConnectionFailure(true)
        .build()
}
