#![allow(non_upper_case_globals)]
#![allow(non_camel_case_types)]
#![allow(non_snake_case)]
#![allow(dead_code)]

mod ffi {
    include!(concat!(env!("OUT_DIR"), "/bindings.rs"));
}

use std::ffi::c_int;
use std::ptr;

pub enum Channels {
    Mono,
    Stereo,
}

impl Channels {
    fn to_c_int(&self) -> c_int {
        match self {
            Channels::Mono => 1,
            Channels::Stereo => 2,
        }
    }

    pub fn count(&self) -> usize {
        match self {
            Channels::Mono => 1,
            Channels::Stereo => 2,
        }
    }
}

pub struct Decoder {
    ptr: *mut ffi::OpusDecoder,
    channels: Channels,
}

unsafe impl Send for Decoder {}

impl Decoder {
    pub fn new(sample_rate: u32, channels: Channels) -> Result<Decoder, i32> {
        let mut err: c_int = 0;
        let ptr = unsafe {
            ffi::opus_decoder_create(
                sample_rate as i32,
                channels.to_c_int(),
                &mut err,
            )
        };
        if err != 0 || ptr.is_null() {
            Err(err)
        } else {
            Ok(Decoder { ptr, channels })
        }
    }

    pub fn decode_float(
        &mut self,
        input: &[u8],
        output: &mut [f32],
        fec: bool,
    ) -> Result<usize, i32> {
        let frame_size = output.len() / self.channels.count();
        let result = unsafe {
            ffi::opus_decode_float(
                self.ptr,
                input.as_ptr(),
                input.len() as i32,
                output.as_mut_ptr(),
                frame_size as i32,
                if fec { 1 } else { 0 },
            )
        };
        if result < 0 {
            Err(result)
        } else {
            Ok(result as usize * self.channels.count())
        }
    }

    pub fn get_nb_samples(&mut self, packet: &[u8]) -> Result<usize, i32> {
        let result = unsafe {
            ffi::opus_decoder_get_nb_samples(
                self.ptr,
                packet.as_ptr(),
                packet.len() as i32,
            )
        };
        if result < 0 {
            Err(result)
        } else {
            Ok(result as usize)
        }
    }

    pub fn reset_state(&mut self) -> Result<(), i32> {
        let result = unsafe { ffi::opus_decoder_ctl(self.ptr, ffi::OPUS_RESET_STATE as i32) };
        if result != 0 {
            Err(result)
        } else {
            Ok(())
        }
    }
}

impl Drop for Decoder {
    fn drop(&mut self) {
        if !self.ptr.is_null() {
            unsafe {
                ffi::opus_decoder_destroy(self.ptr);
            }
            self.ptr = ptr::null_mut();
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    // Exercise the real C library, including repacketizer.c, whose omission
    // from the source list can go unnoticed until a final native link.
    #[test]
    fn encoded_repacketized_silence_decodes() {
        let mut error = 0;
        let encoder = unsafe {
            ffi::opus_encoder_create(48_000, 2, ffi::OPUS_APPLICATION_AUDIO as i32, &mut error)
        };
        assert_eq!(error, 0);
        assert!(!encoder.is_null());
        let mut packet = [0u8; 1275];
        let length = unsafe {
            let length = ffi::opus_encode_float(
                encoder, [0.0f32; 960 * 2].as_ptr(), 960,
                packet.as_mut_ptr(), packet.len() as i32,
            );
            ffi::opus_encoder_destroy(encoder);
            length
        };
        assert!(length > 0);

        let mut combined = [0u8; 2550];
        let combined_length = unsafe {
            let repacketizer = ffi::opus_repacketizer_create();
            assert!(!repacketizer.is_null());
            let first = ffi::opus_repacketizer_cat(repacketizer, packet.as_ptr(), length);
            let second = ffi::opus_repacketizer_cat(repacketizer, packet.as_ptr(), length);
            let length = ffi::opus_repacketizer_out(
                repacketizer, combined.as_mut_ptr(), combined.len() as i32,
            );
            ffi::opus_repacketizer_destroy(repacketizer);
            assert_eq!((first, second), (0, 0));
            length
        };
        assert!(combined_length > 0);
        let combined = &combined[..combined_length as usize];
        let mut decoder = Decoder::new(48_000, Channels::Stereo).unwrap();
        assert_eq!(decoder.get_nb_samples(combined).unwrap(), 1920);
        let mut output = [0.0f32; 1920 * 2];
        assert_eq!(decoder.decode_float(combined, &mut output, false).unwrap(), output.len());
        assert!(output.iter().all(|sample| sample.is_finite() && sample.abs() < 0.001));
    }
}
