const playerCache = new Map<string, Promise<YouTubePlayerJs>>();
const DIRECT_DECIPHER_D = 159;

const findMatchingBrace = (source: string, startIndex: number) => {
  let depth = 0;
  let inString = false;
  let quoteChar = "";
  let escaped = false;

  for (let index = startIndex; index < source.length; index += 1) {
    const char = source[index];

    if (inString) {
      if (escaped) {
        escaped = false;
      } else if (char === "\\") {
        escaped = true;
      } else if (char === quoteChar) {
        inString = false;
        quoteChar = "";
      }
      continue;
    }

    if (char === "'" || char === '"' || char === "`") {
      inString = true;
      quoteChar = char;
      continue;
    }

    if (char === "{") {
      depth += 1;
    } else if (char === "}") {
      depth -= 1;
      if (depth === 0) {
        return index;
      }
    }
  }

  return -1;
};

const extractAssignmentFunction = (source: string) => {
  const pattern = /([A-Za-z0-9$]+)=function\(([A-Za-z0-9$]+)\)\{\2=\2\.split\(""\);/g;
  const match = pattern.exec(source);
  if (!match || match.index < 0) {
    return undefined;
  }

  const functionName = match[1];
  const functionIndex = source.indexOf(`${functionName}=function`, match.index);
  const bodyStart = source.indexOf("{", functionIndex);
  const bodyEnd = findMatchingBrace(source, bodyStart);
  if (bodyStart < 0 || bodyEnd < 0) {
    return undefined;
  }

  return {
    name: functionName,
    code: source.slice(functionIndex, bodyEnd + 1),
  };
};

const extractHelperObjectName = (functionCode: string) => {
  const helperMatch = functionCode.match(/;([A-Za-z0-9$]{2,})\.([A-Za-z0-9$]{2,})\(/);
  return helperMatch?.[1];
};

const extractObjectLiteral = (source: string, objectName: string) => {
  const patterns = [`var ${objectName}={` , `${objectName}={`];

  for (const pattern of patterns) {
    const start = source.indexOf(pattern);
    if (start < 0) {
      continue;
    }

    const braceStart = source.indexOf("{", start);
    const braceEnd = findMatchingBrace(source, braceStart);
    if (braceStart < 0 || braceEnd < 0) {
      continue;
    }

    return source.slice(start, braceEnd + 1);
  }

  return undefined;
};

const parseConstantArray = (source: string) => {
  const match = source.match(/var c='([^']*)'\.split\(";"\)/) ?? source.match(/var c='([^']*)'\.split\(";"\),/);
  if (!match) {
    return undefined;
  }

  return match[1]
    .replace(/\\\\/g, "\\")
    .split(";");
};

const buildFallbackDecipher = (source: string) => {
  const constants = parseConstantArray(source);
  const match = source.match(/mP=function\(A,P,D\)\{([\s\S]*?)return B\}/);
  if (!constants || !match) {
    return undefined;
  }

  const body = match[1];
  const operationMatches = [...body.matchAll(/FK\[c\[d\^(\d+)\]\]\(u,([^)]+)\)/g)];
  if (!operationMatches.length) {
    return undefined;
  }

  const operations = operationMatches
    .map((operationMatch) => {
      const opName = constants[DIRECT_DECIPHER_D ^ Number(operationMatch[1])];
      const rawArg = operationMatch[2].trim();
      const arg = /^d\^\d+$/.test(rawArg)
        ? DIRECT_DECIPHER_D ^ Number(rawArg.split("^")[1])
        : Number(rawArg);

      if (!opName || Number.isNaN(arg)) {
        return undefined;
      }

      return { opName, arg };
    })
    .filter(Boolean) as { opName: string; arg: number }[];

  if (!operations.length) {
    return undefined;
  }

  return (value: string) => {
    const chars = value.split("");

    operations.forEach(({ opName, arg }) => {
      switch (opName) {
        case "Q7":
          chars.splice(0, arg);
          break;
        case "Mc": {
          const index = arg % chars.length;
          const first = chars[0];
          chars[0] = chars[index];
          chars[index] = first;
          break;
        }
        case "IO":
          chars.reverse();
          break;
        default:
          throw new Error(`Unsupported YouTube decipher op: ${opName}`);
      }
    });

    return chars.join("");
  };
};

const compileDecipher = (helperObjectCode: string, functionCode: string, functionName: string) =>
  new Function(
    `"use strict"; ${helperObjectCode.startsWith("var ") ? helperObjectCode : `var ${helperObjectCode}`}; var ${functionCode}; return function(sig){ return ${functionName}(sig); };`,
  )() as (value: string) => string;

export type YouTubePlayerJs = {
  signatureTimestamp?: number;
  decipher?: (value: string) => string;
};

const parsePlayerJs = (source: string): YouTubePlayerJs => {
  const signatureTimestamp = Number(source.match(/signatureTimestamp[:=](\d+)/)?.[1] ?? source.match(/\bsts[:=](\d+)/)?.[1]);
  const fallbackDecipher = buildFallbackDecipher(source);

  const functionMatch = extractAssignmentFunction(source);
  if (!functionMatch) {
    return {
      signatureTimestamp: Number.isFinite(signatureTimestamp) ? signatureTimestamp : undefined,
      decipher: fallbackDecipher,
    };
  }

  const helperObjectName = extractHelperObjectName(functionMatch.code);
  if (!helperObjectName) {
    return {
      signatureTimestamp: Number.isFinite(signatureTimestamp) ? signatureTimestamp : undefined,
      decipher: fallbackDecipher,
    };
  }

  const helperObjectCode = extractObjectLiteral(source, helperObjectName);
  if (!helperObjectCode) {
    return {
      signatureTimestamp: Number.isFinite(signatureTimestamp) ? signatureTimestamp : undefined,
      decipher: fallbackDecipher,
    };
  }

  if (fallbackDecipher) {
    return {
      signatureTimestamp: Number.isFinite(signatureTimestamp) ? signatureTimestamp : undefined,
      decipher: fallbackDecipher,
    };
  }

  let decipher: ((value: string) => string) | undefined;

  try {
    decipher = compileDecipher(helperObjectCode, functionMatch.code, functionMatch.name);
  } catch {
    decipher = fallbackDecipher;
  }

  return {
    signatureTimestamp: Number.isFinite(signatureTimestamp) ? signatureTimestamp : undefined,
    decipher,
  };
};

export const fetchYouTubePlayerJs = async (playerUrl?: string) => {
  if (!playerUrl) {
    return {} satisfies YouTubePlayerJs;
  }

  if (!playerCache.has(playerUrl)) {
    playerCache.set(
      playerUrl,
      (async () => {
        const response = await fetch(playerUrl, {
          headers: {
            "accept-language": "en-US,en;q=0.9",
          },
        });
        if (!response.ok) {
          throw new Error(`YouTube player JS request failed with ${response.status}`);
        }

        return parsePlayerJs(await response.text());
      })(),
    );
  }

  return playerCache.get(playerUrl)!;
};
