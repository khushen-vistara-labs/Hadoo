import type { PropsWithChildren } from "react";
import { StyleSheet, Text as RNText, type TextProps } from "react-native";

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
  },
  title: {
    fontSize: 28,
    fontWeight: "700",
  },
  headline: {
    fontSize: 19,
    fontWeight: "700",
  },
  body: {
    fontSize: 15,
  },
  caption: {
    fontSize: 12,
    textTransform: "uppercase",
    letterSpacing: 0.8,
  },
});
