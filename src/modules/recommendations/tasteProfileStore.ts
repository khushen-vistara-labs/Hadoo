import { create } from "zustand";
import { createJSONStorage, persist } from "zustand/middleware";

import { appStorage } from "@/store/persistence";
import type { TasteProfile } from "@/modules/recommendations/types";

const createEmptyTasteProfile = (): TasteProfile => ({
  languages: [],
  genres: [],
  artists: [],
  moods: [],
  eras: [],
  onboardingCompleted: false,
  updatedAt: 0,
});

type TasteProfileStore = {
  tasteProfile: TasteProfile;
  hasHydrated: boolean;
  setHasHydrated: (value: boolean) => void;
  saveTasteProfile: (profile: Partial<TasteProfile>) => void;
  completeOnboarding: (profile: Omit<TasteProfile, "onboardingCompleted" | "updatedAt">) => void;
  resetTasteProfile: () => void;
};

export const useTasteProfileStore = create<TasteProfileStore>()(
  persist(
    (set, get) => ({
      tasteProfile: createEmptyTasteProfile(),
      hasHydrated: false,
      setHasHydrated: (hasHydrated) => set({ hasHydrated }),
      saveTasteProfile: (profile) =>
        set({
          tasteProfile: {
            ...get().tasteProfile,
            ...profile,
            updatedAt: Date.now(),
          },
        }),
      completeOnboarding: (profile) =>
        set({
          tasteProfile: {
            ...profile,
            onboardingCompleted: true,
            updatedAt: Date.now(),
          },
        }),
      resetTasteProfile: () =>
        set({
          tasteProfile: createEmptyTasteProfile(),
        }),
    }),
    {
      name: "taste-profile-store",
      storage: createJSONStorage(() => appStorage),
      onRehydrateStorage: () => (state) => {
        state?.setHasHydrated(true);
      },
    },
  ),
);
