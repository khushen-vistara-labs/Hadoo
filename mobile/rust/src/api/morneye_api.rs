//! Morneye add-ons for Dart: see `crate::morneye`.

use std::sync::Arc;

use flutter_rust_bridge::{frb, DartFnFuture};

use crate::morneye::Engine;

/// One running add-on package.
#[frb(opaque)]
pub struct MorneyeEngine(Engine);

impl MorneyeEngine {
    /// Starts [code] after desktop's [bootstrap] prelude with [config_json].
    /// [host] answers the package's host calls: (method, JSON args) → JSON.
    pub fn start(
        code: String,
        bootstrap: String,
        config_json: String,
        host: impl Fn(String, String) -> DartFnFuture<String> + Send + Sync + 'static,
    ) -> anyhow::Result<MorneyeEngine> {
        let host = Arc::new(move |method: String, json: String| host(method, json));
        Engine::start(code, bootstrap, config_json, host).map(MorneyeEngine).map_err(anyhow::Error::msg)
    }

    /// The functions the package registered.
    #[frb(sync)]
    pub fn methods(&self) -> Vec<String> {
        self.0.methods()
    }

    #[frb(sync)]
    pub fn is_closed(&self) -> bool {
        self.0.is_closed()
    }

    /// Calls [method] with JSON [args_json]; returns its JSON result.
    pub async fn invoke(&self, method: String, args_json: String, timeout_ms: u64) -> anyhow::Result<String> {
        self.0.invoke(method, args_json, timeout_ms).await.map_err(anyhow::Error::msg)
    }

    /// Runs the package's progress callback [id] during the host call that
    /// received it. Returns the package's error message, empty on success.
    pub async fn callback(&self, id: u64, args_json: String) -> String {
        self.0.callback(id, args_json).await
    }

    #[frb(sync)]
    pub fn close(&self) {
        self.0.close()
    }
}

/// AES or Blowfish in CBC/CTR mode, as desktop's add-on host offers.
#[frb(sync)]
pub fn morneye_cipher(
    data: Vec<u8>,
    algorithm: String,
    mode: String,
    key: Vec<u8>,
    iv: Vec<u8>,
    pkcs7: bool,
    decrypt: bool,
) -> anyhow::Result<Vec<u8>> {
    crate::morneye_crypto::transform(&data, &algorithm, &mode, &key, &iv, pkcs7, decrypt).map_err(anyhow::Error::msg)
}

/// AES-256-GCM sealing for add-on logins and settings.
#[frb(sync)]
pub fn morneye_seal(data: Vec<u8>, key: Vec<u8>, nonce: Vec<u8>) -> anyhow::Result<Vec<u8>> {
    crate::morneye_crypto::seal(&data, &key, &nonce).map_err(anyhow::Error::msg)
}

#[frb(sync)]
pub fn morneye_open(data: Vec<u8>, key: Vec<u8>) -> anyhow::Result<Vec<u8>> {
    crate::morneye_crypto::open(&data, &key).map_err(anyhow::Error::msg)
}

/// What an add-on's download holds, shaped like desktop's ffprobe summary
/// (codec, bit depth, sample rate, channels, duration, bitrate, container).
pub fn morneye_media_info(path: String) -> anyhow::Result<String> {
    use std::fs::File;
    use std::path::Path;
    use symphonia::core::codecs::audio::well_known::*;
    use symphonia::core::codecs::audio::CODEC_ID_NULL_AUDIO;
    use symphonia::core::codecs::CodecParameters;
    use symphonia::core::formats::probe::Hint;
    use symphonia::core::formats::FormatOptions;
    use symphonia::core::io::MediaSourceStream;
    use symphonia::core::meta::MetadataOptions;

    let path_obj = Path::new(&path);
    let size = std::fs::metadata(path_obj)?.len();
    let file = File::open(path_obj)?;
    let mss = MediaSourceStream::new(Box::new(file), Default::default());
    let mut hint = Hint::new();
    if let Some(ext) = path_obj.extension().and_then(|e| e.to_str()) {
        hint.with_extension(ext);
    }
    let probed = symphonia::default::get_probe()
        .probe(&hint, mss, FormatOptions::default(), MetadataOptions::default())
        .map_err(|e| anyhow::anyhow!("Unreadable audio: {e}"))?;
    let format = probed.format_info().short_name.to_string();
    let track = probed
        .tracks()
        .iter()
        .find(|t| matches!(&t.codec_params, Some(CodecParameters::Audio(p)) if p.codec != CODEC_ID_NULL_AUDIO))
        .ok_or_else(|| anyhow::anyhow!("The addon produced no audio stream"))?;
    let params = track.codec_params.as_ref().and_then(|p| p.audio()).ok_or_else(|| anyhow::anyhow!("The addon produced no audio stream"))?;
    let codec = match params.codec {
        CODEC_ID_FLAC => "flac",
        CODEC_ID_ALAC => "alac",
        CODEC_ID_AAC => "aac",
        CODEC_ID_MP3 => "mp3",
        CODEC_ID_OPUS => "opus",
        CODEC_ID_VORBIS => "vorbis",
        CODEC_ID_WAVPACK => "wavpack",
        CODEC_ID_PCM_S16LE => "pcm_s16le",
        CODEC_ID_PCM_S24LE => "pcm_s24le",
        CODEC_ID_PCM_S32LE => "pcm_s32le",
        CODEC_ID_PCM_F32LE => "pcm_f32le",
        _ => "unknown",
    };
    let sample_rate = params.sample_rate.unwrap_or(0);
    let duration = match (track.num_frames, sample_rate) {
        (Some(frames), rate) if rate > 0 => frames as f64 / rate as f64,
        _ => 0.0,
    };
    let bitrate = if duration > 0.0 { (size as f64 * 8.0 / duration) as u64 } else { 0 };
    let bit_depth = params.bits_per_sample.or(params.bits_per_coded_sample).unwrap_or(0);
    Ok(serde_json::json!({
        "success": true,
        "codec": codec,
        "audio_codec": codec,
        "bit_depth": bit_depth,
        "bitDepth": bit_depth,
        "sample_rate": sample_rate,
        "sampleRate": sample_rate,
        "channels": params.channels.as_ref().map(|c| c.count()).unwrap_or(0),
        "duration": duration,
        "duration_ms": (duration * 1000.0).round() as u64,
        "bitrate": bitrate,
        "format": format,
    })
    .to_string())
}
