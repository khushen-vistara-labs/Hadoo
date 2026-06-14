type CipherParts = {
  url: string;
  signature?: string;
  signatureParameter?: string;
};

export const extractExpiresAt = (url: string) => {
  try {
    const parsed = new URL(url);
    const expire = parsed.searchParams.get("expire");
    if (!expire) {
      return undefined;
    }

    const seconds = Number(expire);
    return Number.isFinite(seconds) ? seconds * 1000 : undefined;
  } catch {
    return undefined;
  }
};

const parseCipher = (value: string): CipherParts => {
  const params = new URLSearchParams(value);
  return {
    url: params.get("url") ?? "",
    signature: params.get("s") ?? undefined,
    signatureParameter: params.get("sp") ?? "sig",
  };
};

export const resolveCipheredUrl = (
  url?: string,
  signatureCipher?: string,
  cipher?: string,
  decipher?: (value: string) => string,
) => {
  if (url) {
    return url;
  }

  const payload = signatureCipher ?? cipher;
  if (!payload) {
    return undefined;
  }

  const parsed = parseCipher(payload);
  if (!parsed.url) {
    return undefined;
  }

  if (!parsed.signature) {
    return parsed.url;
  }

  if (!decipher) {
    throw new Error("YouTube stream signature required decipher logic, but no decipher function was available.");
  }

  const resolved = new URL(parsed.url);
  resolved.searchParams.set(parsed.signatureParameter ?? "sig", decipher(parsed.signature));
  return resolved.toString();
};
