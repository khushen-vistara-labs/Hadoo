export const logger = {
  info: (...args: unknown[]) => {
    if (__DEV__) {
      console.log("[Hadoo]", ...args);
    }
  },
  warn: (...args: unknown[]) => {
    if (__DEV__) {
      console.warn("[Hadoo]", ...args);
    }
  },
  error: (...args: unknown[]) => {
    if (__DEV__) {
      console.error("[Hadoo]", ...args);
    }
  },
};
