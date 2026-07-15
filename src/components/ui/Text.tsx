import type { PropsWithChildren } from "react";
import { Platform, StyleSheet, Text as RNText, type TextProps } from "react-native";

import { typography } from "@/constants/typography";
import { useTheme } from "@/hooks/useTheme";

type Props = PropsWithChildren<
  TextProps & {
    variant?: "title" | "headline" | "body" | "caption";
    muted?: boolean;
  }
>;

export const Text = ({ children, style, variant = "body", muted = false, ...props }: Props) => {
  const theme = useTheme();

  return (
    <RNText
      {...props}
      style={[
        styles.base,
        styles[variant],
        { color: muted ? theme.textMuted : theme.text },
        style,
      ]}
    >
      {children}
    </RNText>
  );
};

const styles = StyleSheet.create({
  base: {
    fontSize: 15,
    lineHeight: 20,
    fontFamily: typography.bodyFamilyLight,
  },
  title: {
    fontSize: 23,
    lineHeight: 33,
    fontFamily: typography.displayFamily,
    letterSpacing: 0.05,
    paddingTop: Platform.OS === "android" ? 3 : 0,
  },
  headline: {
    fontSize: 16,
    lineHeight: 24,
    fontFamily: typography.displayFamily,
    letterSpacing: 0.05,
    paddingTop: Platform.OS === "android" ? 1 : 0,
  },
  body: {
    fontSize: 15,
    lineHeight: 20,
  },
  caption: {
    fontSize: 11,
    textTransform: "uppercase",
    letterSpacing: 1.1,
    fontFamily: typography.bodyFamilyMedium,
  },
});
