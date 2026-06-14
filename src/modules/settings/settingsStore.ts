import { create } from "zustand";
import { createJSONStorage, persist } from "zustand/middleware";

import { sourceRegistry } from "@/modules/sources/SourceRegistry";
import { appStorage } from "@/store/persistence";
import type { ThemeId } from "@/constants/theme";
import type { MusicProvider } from "@/types/source";

type SettingsStore = {
  themeId: ThemeId;
  accentOverride?: string;
  providerStates: Record<MusicProvider, boolean>;
  audioQuality: "auto" | "low" | "medium" | "high";
  toggleProvider: (provider: MusicProvider) => void;
  setTheme: (themeId: ThemeId) => void;
  setAccentOverride: (color?: string) => void;
  setAudioQuality: (value: "auto" | "low" | "medium" | "high") => void;
};

const providerStates: Record<MusicProvider, boolean> = {
  mock: true,
  local: false,
  youtube_music_experimental: true,
  jiosaavn_experimental: false,
  cached: false,
};

export const useSettingsStore = create<SettingsStore>()(
  persist(
    (set, get) => ({
      themeId: "midnight",
      accentOverride: undefined,
      providerStates,
      audioQuality: "auto",
      toggleProvider: (provider) => {
        const next = !get().providerStates[provider];
        sourceRegistry.setProviderEnabled(provider, next);
        set({
          providerStates: {
            ...get().providerStates,
            [provider]: next,
          },
        });
      },
      setTheme: (themeId) => set({ themeId }),
      setAccentOverride: (accentOverride) => set({ accentOverride }),
      setAudioQuality: (audioQuality) => set({ audioQuality }),
    }),
    {
      name: "settings-store",
      storage: createJSONStorage(() => appStorage),
    },
  ),
);
