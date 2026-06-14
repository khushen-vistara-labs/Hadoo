import type { PropsWithChildren } from "react";
import { ScrollView, StyleSheet, View } from "react-native";
import { SafeAreaView } from "react-native-safe-area-context";

import { useTheme } from "@/hooks/useTheme";

type ScreenProps = PropsWithChildren<{
  scroll?: boolean;
}>;

export const Screen = ({ children, scroll = true }: ScreenProps) => {
  const theme = useTheme();
  const content = scroll ? (
    <ScrollView contentContainerStyle={styles.content}>{children}</ScrollView>
  ) : (
    <View style={styles.content}>{children}</View>
  );

  return <SafeAreaView style={[styles.safeArea, { backgroundColor: theme.background }]}>{content}</SafeAreaView>;
};

const styles = StyleSheet.create({
  safeArea: {
    flex: 1,
  },
  content: {
    padding: 20,
    gap: 18,
  },
});
