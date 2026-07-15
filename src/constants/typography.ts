import { Platform } from "react-native";

export const typography = {
  bodyFamily: Platform.select({
    ios: "Optima",
    android: "sans-serif-condensed",
    default: "sans-serif",
  }),
  bodyFamilyMedium: Platform.select({
    ios: "Optima Bold",
    android: "sans-serif-medium",
    default: "sans-serif-medium",
  }),
  bodyFamilyLight: Platform.select({
    ios: "Optima",
    android: "sans-serif-condensed",
    default: "sans-serif",
  }),
  displayFamily: Platform.select({
    ios: "CuteDisplay",
    android: "CuteDisplay",
    default: "CuteDisplay",
  }),
};
