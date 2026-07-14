import { create } from "zustand";
import { createJSONStorage, persist } from "zustand/middleware";

import { appStorage } from "@/store/persistence";
import type { SleepTimerOption } from "@/types/lyrics";

type SleepTimerStore = {
  activeOption: SleepTimerOption | null;
  expiresAt: number | null;
  setTimer: (option: SleepTimerOption) => void;
  clearTimer: () => void;
};

const durationMsByOption: Record<Exclude<SleepTimerOption, "end_of_track">, number> = {
  "5m": 5 * 60 * 1000,
  "10m": 10 * 60 * 1000,
  "15m": 15 * 60 * 1000,
  "30m": 30 * 60 * 1000,
  "45m": 45 * 60 * 1000,
  "60m": 60 * 60 * 1000,
};

export const useSleepTimerStore = create<SleepTimerStore>()(
  persist(
    (set) => ({
      activeOption: null,
      expiresAt: null,
      setTimer: (option) =>
        set({
          activeOption: option,
          expiresAt: option === "end_of_track" ? null : Date.now() + durationMsByOption[option],
        }),
      clearTimer: () => set({ activeOption: null, expiresAt: null }),
    }),
    {
      name: "sleep-timer-store",
      storage: createJSONStorage(() => appStorage),
    },
  ),
);
