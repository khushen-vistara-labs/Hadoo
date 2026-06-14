import AsyncStorage from "@react-native-async-storage/async-storage";
import type { StateStorage } from "zustand/middleware";

export const appStorage: StateStorage = {
  setItem: async (name, value) => {
    await AsyncStorage.setItem(name, value);
  },
  getItem: async (name) => AsyncStorage.getItem(name),
  removeItem: async (name) => {
    await AsyncStorage.removeItem(name);
  },
};
