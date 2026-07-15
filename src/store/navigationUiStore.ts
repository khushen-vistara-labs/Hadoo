import { create } from "zustand";

type NavigationUiStore = {
  isLoading: boolean;
  label?: string;
  start: (label?: string) => void;
  stop: () => void;
};

export const useNavigationUiStore = create<NavigationUiStore>((set) => ({
  isLoading: false,
  label: undefined,
  start: (label) => set({ isLoading: true, label }),
  stop: () => set({ isLoading: false, label: undefined }),
}));

