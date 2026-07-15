import type { PropsWithChildren } from "react";
import { ScrollView, StyleSheet, View, type StyleProp, type ViewStyle } from "react-native";
import { SafeAreaView } from "react-native-safe-area-context";

import { useMiniPlayerLayout } from "@/hooks/useMiniPlayerLayout";
import { useTheme } from "@/hooks/useTheme";

type ScreenProps = PropsWithChildren<{
  scroll?: boolean;
  contentContainerStyle?: StyleProp<ViewStyle>;
}>;

export const Screen = ({ children, scroll = true, contentContainerStyle }: ScreenProps) => {
  const theme = useTheme();
  const { contentBottomSpacing } = useMiniPlayerLayout();
  const flattenedContentStyle = StyleSheet.flatten(contentContainerStyle) ?? {};
  const { paddingBottom, ...restContentStyle } = flattenedContentStyle;
  const content = scroll ? (
    <ScrollView
      contentContainerStyle={[
        styles.content,
        restContentStyle,
        {
          paddingBottom: styles.scrollContent.paddingBottom + (typeof paddingBottom === "number" ? paddingBottom : 0) + contentBottomSpacing,
        },
      ]}
    >
      {children}
    </ScrollView>
  ) : (
    <View style={[styles.content, contentContainerStyle]}>{children}</View>
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
  scrollContent: {
    paddingBottom: 32,
  },
});
