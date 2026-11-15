package com.mossapps.flick.youtube.potoken

import android.util.Base64
import org.json.JSONArray
import org.json.JSONObject

/**
 * Adapt the BotGuard Create/GenerateIT wire responses into JavaScript values.
 * The Create payload is either a nested JSON array or a scrambled base64 array.
 */
internal fun parseChallengeData(rawChallengeData: String): String {
    val response = JSONArray(rawChallengeData)
    val challenge = when (val payload = response.get(1)) {
        is JSONArray -> payload
        is String -> JSONArray(descrambleChallenge(payload))
        else -> throw IllegalArgumentException("Unexpected BotGuard challenge payload")
    }

    fun firstStringIn(index: Int): String? {
        val items = challenge.optJSONArray(index) ?: return null
        for (i in 0 until items.length()) {
            val item = items.opt(i)
            if (item is String) return item
        }
        return null
    }

    val interpreter = JSONObject()
        .put("privateDoNotAccessOrElseSafeScriptWrappedValue", firstStringIn(1) ?: JSONObject.NULL)
        .put("privateDoNotAccessOrElseTrustedResourceUrlWrappedValue", firstStringIn(2) ?: JSONObject.NULL)

    return JSONObject()
        .put("messageId", challenge.getString(0))
        .put("interpreterJavascript", interpreter)
        .put("interpreterHash", challenge.getString(3))
        .put("program", challenge.getString(4))
        .put("globalName", challenge.getString(5))
        .put("clientExperimentsStateBlob", challenge.getString(7))
        .toString()
}

/** The token itself is base64, and the second field is its lifetime in seconds. */
internal fun parseIntegrityTokenData(rawIntegrityTokenData: String): Pair<String, Long> {
    val data = JSONArray(rawIntegrityTokenData)
    return asUint8Array(decodeYoutubeBase64(data.getString(0))) to data.getLong(1)
}

/** Pass an identifier to the JS minter as a UTF-8 Uint8Array, not an escaped JS string. */
internal fun stringToU8(identifier: String): String =
    asUint8Array(identifier.toByteArray(Charsets.UTF_8))

/** Convert the comma-separated Uint8Array callback into YouTube's URL-safe base64. */
internal fun u8ToBase64(poTokenU8: String): String {
    val bytes = if (poTokenU8.isEmpty()) {
        byteArrayOf()
    } else {
        poTokenU8.split(',').map { value ->
            val byte = value.trim().toInt()
            require(byte in 0..255) { "Invalid PoToken byte" }
            byte.toByte()
        }.toByteArray()
    }
    return Base64.encodeToString(bytes, Base64.NO_WRAP)
        .replace('+', '-')
        .replace('/', '_')
}

private fun descrambleChallenge(encoded: String): String =
    decodeYoutubeBase64(encoded)
        .map { (it.toInt() + 97).toByte() }
        .toByteArray()
        .toString(Charsets.UTF_8)

private fun asUint8Array(bytes: ByteArray): String =
    "new Uint8Array([" + bytes.joinToString(",") { (it.toInt() and 0xff).toString() } + "])"

private fun decodeYoutubeBase64(value: String): ByteArray {
    val normalized = value.replace('-', '+').replace('_', '/').replace('.', '=')
    return Base64.decode(normalized, Base64.DEFAULT)
}
