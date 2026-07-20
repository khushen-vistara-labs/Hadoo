import { decodeBase32 } from "@/modules/sources/spotify/encoding";

const SPOTIFY_TOTP_SECRET =
  "GM3TMMJTGYZTQNZVGM4DINJZHA4TGOBYGMZTCMRTGEYDSMJRHE4TEOBUG4YTCMRUGQ4DQOJUGQYTAMRRGA2TCMJSHE3TCMBY";
export const SPOTIFY_TOTP_VERSION = 61;

const rotateLeft = (value: number, amount: number) => ((value << amount) | (value >>> (32 - amount))) >>> 0;

const sha1 = (message: Uint8Array) => {
  const originalLength = message.length;
  const bitLength = originalLength * 8;
  const withPaddingLength = ((originalLength + 9 + 63) >> 6) << 6;
  const padded = new Uint8Array(withPaddingLength);
  padded.set(message);
  padded[originalLength] = 0x80;

  const view = new DataView(padded.buffer);
  view.setUint32(withPaddingLength - 4, bitLength >>> 0);
  view.setUint32(withPaddingLength - 8, Math.floor(bitLength / 2 ** 32));

  let h0 = 0x67452301;
  let h1 = 0xefcdab89;
  let h2 = 0x98badcfe;
  let h3 = 0x10325476;
  let h4 = 0xc3d2e1f0;

  const words = new Uint32Array(80);

  for (let offset = 0; offset < padded.length; offset += 64) {
    for (let i = 0; i < 16; i += 1) {
      words[i] = view.getUint32(offset + i * 4);
    }

    for (let i = 16; i < 80; i += 1) {
      words[i] = rotateLeft(words[i - 3] ^ words[i - 8] ^ words[i - 14] ^ words[i - 16], 1);
    }

    let a = h0;
    let b = h1;
    let c = h2;
    let d = h3;
    let e = h4;

    for (let i = 0; i < 80; i += 1) {
      let f = 0;
      let k = 0;

      if (i < 20) {
        f = (b & c) | (~b & d);
        k = 0x5a827999;
      } else if (i < 40) {
        f = b ^ c ^ d;
        k = 0x6ed9eba1;
      } else if (i < 60) {
        f = (b & c) | (b & d) | (c & d);
        k = 0x8f1bbcdc;
      } else {
        f = b ^ c ^ d;
        k = 0xca62c1d6;
      }

      const temp = (rotateLeft(a, 5) + f + e + k + words[i]) >>> 0;
      e = d;
      d = c;
      c = rotateLeft(b, 30);
      b = a;
      a = temp;
    }

    h0 = (h0 + a) >>> 0;
    h1 = (h1 + b) >>> 0;
    h2 = (h2 + c) >>> 0;
    h3 = (h3 + d) >>> 0;
    h4 = (h4 + e) >>> 0;
  }

  const output = new Uint8Array(20);
  const outputView = new DataView(output.buffer);
  outputView.setUint32(0, h0);
  outputView.setUint32(4, h1);
  outputView.setUint32(8, h2);
  outputView.setUint32(12, h3);
  outputView.setUint32(16, h4);
  return output;
};

const hmacSha1 = (key: Uint8Array, message: Uint8Array) => {
  const blockSize = 64;
  let normalizedKey = key;
  if (normalizedKey.length > blockSize) {
    normalizedKey = sha1(normalizedKey);
  }

  const paddedKey = new Uint8Array(blockSize);
  paddedKey.set(normalizedKey);

  const outer = new Uint8Array(blockSize + 20);
  const inner = new Uint8Array(blockSize + message.length);

  for (let i = 0; i < blockSize; i += 1) {
    outer[i] = paddedKey[i] ^ 0x5c;
    inner[i] = paddedKey[i] ^ 0x36;
  }

  inner.set(message, blockSize);
  outer.set(sha1(inner), blockSize);
  return sha1(outer);
};

export const generateSpotifyTotp = (now = Date.now()) => {
  const key = decodeBase32(SPOTIFY_TOTP_SECRET);
  const counter = Math.floor(now / 1000 / 30);
  const counterBytes = new Uint8Array(8);
  const view = new DataView(counterBytes.buffer);
  view.setUint32(4, counter >>> 0);
  view.setUint32(0, Math.floor(counter / 2 ** 32));

  const digest = hmacSha1(key, counterBytes);
  const offset = digest[digest.length - 1] & 0x0f;
  const binary =
    ((digest[offset] & 0x7f) << 24) |
    (digest[offset + 1] << 16) |
    (digest[offset + 2] << 8) |
    digest[offset + 3];

  return String(binary % 1_000_000).padStart(6, "0");
};
