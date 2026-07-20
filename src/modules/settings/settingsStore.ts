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
  preferredHomeProvider: MusicProvider;
  audioQuality: "auto" | "low" | "medium" | "high";
  toggleProvider: (provider: MusicProvider) => void;
  setPreferredHomeProvider: (provider: MusicProvider) => void;
  setTheme: (themeId: ThemeId) => void;
  setAccentOverride: (color?: string) => void;
  setAudioQuality: (value: "auto" | "low" | "medium" | "high") => void;
};

const providerStates: Record<MusicProvider, boolean> = {
  mock: false,
  local: false,
  youtube_experimental: true,
  youtube_music_experimental: true,
  spotify_experimental: true,
  amazon_music_experimental: false,
  tidal_experimental: false,
  deezer_experimental: false,
  soundcloud_experimental: false,
  jiosaavn_experimental: false,
  cached: false,
};

export const useSettingsStore = create<SettingsStore>()(
  persist(
    (set, get) => ({
      themeId: "midnight",
      accentOverride: undefined,
      providerStates,
      preferredHomeProvider: "youtube_music_experimental",
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
      setPreferredHomeProvider: (preferredHomeProvider) => set({ preferredHomeProvider }),
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
