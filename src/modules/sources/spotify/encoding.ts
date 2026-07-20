const BASE32_ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567";
const BASE64_ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

export const decodeBase32 = (input: string) => {
  const normalized = input.toUpperCase().replace(/=+$/g, "").replace(/[^A-Z2-7]/g, "");
  let bits = 0;
  let value = 0;
  const output: number[] = [];

  for (const char of normalized) {
    const index = BASE32_ALPHABET.indexOf(char);
    if (index < 0) {
      continue;
    }

    value = (value << 5) | index;
    bits += 5;

    if (bits >= 8) {
      output.push((value >>> (bits - 8)) & 0xff);
      bits -= 8;
    }
  }

  return new Uint8Array(output);
};

export const decodeBase64 = (input: string) => {
  const normalized = input.replace(/[^A-Za-z0-9+/=]/g, "");
  let bits = 0;
  let value = 0;
  const output: number[] = [];

  for (const char of normalized) {
    if (char === "=") {
      break;
    }

    const index = BASE64_ALPHABET.indexOf(char);
    if (index < 0) {
      continue;
    }

    value = (value << 6) | index;
    bits += 6;

    if (bits >= 8) {
      output.push((value >>> (bits - 8)) & 0xff);
      bits -= 8;
    }
  }

  return new Uint8Array(output);
};

export const decodeBase64ToString = (input: string) => {
  const bytes = decodeBase64(input);
  return new TextDecoder().decode(bytes);
};
