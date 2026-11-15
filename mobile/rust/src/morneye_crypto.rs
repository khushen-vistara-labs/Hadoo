//! The ciphers Morneye add-ons ask the host for, matching Lokal desktop's
//! electron/morneye/crypto.js (Node's crypto and egoroof-blowfish).

use aes::{Aes128, Aes192, Aes256};
use aes_gcm::aead::{Aead, KeyInit};
use aes_gcm::{Aes256Gcm, Nonce};
use blowfish::Blowfish;
use cipher::{Block, BlockCipherDecrypt, BlockCipherEncrypt};

/// One block cipher keyed for both directions.
enum Keyed {
    Aes128(Aes128),
    Aes192(Aes192),
    Aes256(Aes256),
    Blowfish(Blowfish),
}

impl Keyed {
    fn new(algorithm: &str, key: &[u8]) -> Result<Keyed, String> {
        let algorithm = algorithm.to_lowercase();
        if algorithm == "aes" || matches!(algorithm.as_str(), "aes-128" | "aes-192" | "aes-256") {
            if algorithm != "aes" && algorithm[4..].parse::<usize>().ok() != Some(key.len() * 8) {
                return Err("Invalid AES key length".into());
            }
            return match key.len() {
                16 => Ok(Keyed::Aes128(Aes128::new_from_slice(key).map_err(|_| "Invalid AES key length")?)),
                24 => Ok(Keyed::Aes192(Aes192::new_from_slice(key).map_err(|_| "Invalid AES key length")?)),
                32 => Ok(Keyed::Aes256(Aes256::new_from_slice(key).map_err(|_| "Invalid AES key length")?)),
                _ => Err("Invalid AES key length".into()),
            };
        }
        if algorithm != "blowfish" || key.len() < 4 || key.len() > 56 {
            return Err("Unsupported cipher or invalid key length".into());
        }
        Ok(Keyed::Blowfish(Blowfish::new_from_slice(key).map_err(|_| "Invalid Blowfish key length")?))
    }

    fn encrypt(&self, block: &mut [u8]) {
        match self {
            Keyed::Aes128(c) => c.encrypt_block(<&mut Block<Aes128>>::try_from(block).expect("whole block")),
            Keyed::Aes192(c) => c.encrypt_block(<&mut Block<Aes192>>::try_from(block).expect("whole block")),
            Keyed::Aes256(c) => c.encrypt_block(<&mut Block<Aes256>>::try_from(block).expect("whole block")),
            Keyed::Blowfish(c) => c.encrypt_block(<&mut Block<Blowfish>>::try_from(block).expect("whole block")),
        }
    }

    fn decrypt(&self, block: &mut [u8]) {
        match self {
            Keyed::Aes128(c) => c.decrypt_block(<&mut Block<Aes128>>::try_from(block).expect("whole block")),
            Keyed::Aes192(c) => c.decrypt_block(<&mut Block<Aes192>>::try_from(block).expect("whole block")),
            Keyed::Aes256(c) => c.decrypt_block(<&mut Block<Aes256>>::try_from(block).expect("whole block")),
            Keyed::Blowfish(c) => c.decrypt_block(<&mut Block<Blowfish>>::try_from(block).expect("whole block")),
        }
    }
}

/// AES (128/192/256) or Blowfish in CBC or CTR mode. CBC pads with PKCS#7
/// only when [pkcs7] is set, as Node's `setAutoPadding` does; CTR counts the
/// whole IV as one big-endian number.
pub fn transform(input: &[u8], algorithm: &str, mode: &str, key: &[u8], iv: &[u8], pkcs7: bool, decrypt: bool) -> Result<Vec<u8>, String> {
    let mode = mode.to_lowercase();
    if mode != "cbc" && mode != "ctr" {
        return Err("Unsupported block cipher mode".into());
    }
    let size = if algorithm.eq_ignore_ascii_case("blowfish") { 8 } else { 16 };
    if iv.len() != size {
        return Err(format!("IV must be {size} bytes"));
    }
    let cipher = Keyed::new(algorithm, key)?;
    let mut chain = iv.to_vec();
    if mode == "ctr" {
        let mut out = input.to_vec();
        for chunk in out.chunks_mut(size) {
            let mut pad = chain.clone();
            cipher.encrypt(&mut pad);
            for (byte, mask) in chunk.iter_mut().zip(pad) {
                *byte ^= mask;
            }
            for byte in chain.iter_mut().rev() {
                *byte = byte.wrapping_add(1);
                if *byte != 0 {
                    break;
                }
            }
        }
        return Ok(out);
    }
    let mut data = input.to_vec();
    if !decrypt && pkcs7 {
        let count = size - data.len() % size;
        data.extend(std::iter::repeat_n(count as u8, count));
    }
    if data.len() % size != 0 {
        return Err("CBC payload must be block aligned".into());
    }
    for block in data.chunks_mut(size) {
        if decrypt {
            let saved = block.to_vec();
            cipher.decrypt(block);
            for (byte, previous) in block.iter_mut().zip(&chain) {
                *byte ^= previous;
            }
            chain = saved;
        } else {
            for (byte, previous) in block.iter_mut().zip(&chain) {
                *byte ^= previous;
            }
            cipher.encrypt(block);
            chain.copy_from_slice(block);
        }
    }
    if decrypt && pkcs7 {
        let count = *data.last().ok_or("Invalid cipher padding")? as usize;
        if count == 0 || count > size || count > data.len() || !data[data.len() - count..].iter().all(|&b| b as usize == count) {
            return Err("Invalid cipher padding".into());
        }
        data.truncate(data.len() - count);
    }
    Ok(data)
}

/// AES-256-GCM: nonce (12) ‖ ciphertext ‖ tag (16), as desktop's `seal`.
pub fn seal(data: &[u8], key: &[u8], nonce: &[u8]) -> Result<Vec<u8>, String> {
    if nonce.len() != 12 {
        return Err("Invalid nonce".into());
    }
    let cipher = Aes256Gcm::new_from_slice(key).map_err(|_| "Invalid key")?;
    let nonce = Nonce::try_from(nonce).map_err(|_| "Invalid nonce")?;
    let sealed = cipher.encrypt(&nonce, data).map_err(|_| "Encryption failed")?;
    Ok([nonce.as_slice(), &sealed].concat())
}

/// Opens what [seal] made; fails when the key is wrong or the data changed.
pub fn open(data: &[u8], key: &[u8]) -> Result<Vec<u8>, String> {
    if data.len() < 28 {
        return Err("Invalid encrypted addon data".into());
    }
    let cipher = Aes256Gcm::new_from_slice(key).map_err(|_| "Invalid key")?;
    let nonce = Nonce::try_from(&data[..12]).map_err(|_| "Invalid encrypted addon data")?;
    cipher.decrypt(&nonce, &data[12..]).map_err(|_| "Invalid encrypted addon data".into())
}

#[cfg(test)]
mod tests {
    use super::*;

    fn hex(text: &str) -> Vec<u8> {
        (0..text.len()).step_by(2).map(|i| u8::from_str_radix(&text[i..i + 2], 16).unwrap()).collect()
    }

    #[test]
    fn aes_cbc_matches_nist() {
        // NIST SP 800-38A F.2.1, first block.
        let key = hex("2b7e151628aed2a6abf7158809cf4f3c");
        let iv = hex("000102030405060708090a0b0c0d0e0f");
        let plain = hex("6bc1bee22e409f96e93d7e117393172a");
        let out = transform(&plain, "aes", "cbc", &key, &iv, false, false).unwrap();
        assert_eq!(out, hex("7649abac8119b246cee98e9b12e9197d"));
        assert_eq!(transform(&out, "aes-128", "cbc", &key, &iv, false, true).unwrap(), plain);
    }

    #[test]
    fn aes_ctr_matches_nist_and_handles_a_partial_block() {
        // NIST SP 800-38A F.5.1.
        let key = hex("2b7e151628aed2a6abf7158809cf4f3c");
        let iv = hex("f0f1f2f3f4f5f6f7f8f9fafbfcfdfeff");
        let plain = hex("6bc1bee22e409f96e93d7e117393172aae2d8a571e03ac9c9eb76fac45af8e51");
        let out = transform(&plain, "aes", "ctr", &key, &iv, false, false).unwrap();
        assert_eq!(out, hex("874d6191b620e3261bef6864990db6ce9806f66b7970fdff8617187bb9fffdff"));
        assert_eq!(transform(&out[..20], "aes", "ctr", &key, &iv, false, true).unwrap(), &plain[..20]);
    }

    #[test]
    fn blowfish_cbc_round_trips_with_padding() {
        let key = b"g4el58wc0zvf9na1".to_vec();
        let iv = hex("0001020304050607");
        let plain = b"Lokal on the phone".to_vec();
        let out = transform(&plain, "blowfish", "cbc", &key, &iv, true, false).unwrap();
        assert_eq!(out.len(), 24);
        assert_eq!(transform(&out, "blowfish", "cbc", &key, &iv, true, true).unwrap(), plain);
    }

    #[test]
    fn blowfish_matches_known_vector() {
        // Schneier's test vector: key 0000000000000000, plaintext 0 → 4EF997456198DD78.
        let key = hex("0000000000000000");
        let out = transform(&hex("0000000000000000"), "blowfish", "cbc", &key, &hex("0000000000000000"), false, false).unwrap();
        assert_eq!(out, hex("4ef997456198dd78"));
    }

    #[test]
    fn rejects_bad_parameters() {
        assert!(transform(b"x", "aes", "ecb", &[0; 16], &[0; 16], false, false).is_err());
        assert!(transform(b"x", "aes-256", "ctr", &[0; 16], &[0; 16], false, false).is_err());
        assert!(transform(b"abc", "aes", "cbc", &[0; 16], &[0; 16], false, false).is_err());
        assert!(transform(b"x", "blowfish", "ctr", &[0; 16], &[0; 16], false, false).is_err());
    }

    #[test]
    fn seal_round_trips_and_detects_tampering() {
        let key = [7u8; 32];
        let sealed = seal(b"token", &key, &[1; 12]).unwrap();
        assert_eq!(open(&sealed, &key).unwrap(), b"token");
        let mut broken = sealed.clone();
        broken[14] ^= 1;
        assert!(open(&broken, &key).is_err());
        assert!(open(&sealed, &[8u8; 32]).is_err());
    }
}
