import { Tabs } from "expo-router";
import { StyleSheet, View } from "react-native";
import { useSafeAreaInsets } from "react-native-safe-area-context";

import { SymbolIcon } from "@/components/ui/SymbolIcon";
import { useTheme } from "@/hooks/useTheme";

export default function TabsLayout() {
  const theme = useTheme();
  const insets = useSafeAreaInsets();
  const bottomInset = Math.max(insets.bottom, 8);
  const tabBarHeight = 56 + bottomInset;

  return (
    <Tabs
      screenOptions={{
        headerShown: false,
        tabBarShowLabel: false,
        tabBarStyle: {
          position: "absolute",
          left: 16,
          right: 16,
          bottom: 14,
          height: tabBarHeight,
          paddingBottom: bottomInset,
          paddingTop: 8,
          paddingHorizontal: 10,
          borderTopColor: theme.border,
          backgroundColor: theme.surface,
          borderRadius: 28,
          borderWidth: 1,
          elevation: 10,
          shadowColor: "#000",
          shadowOpacity: 0.22,
          shadowRadius: 24,
          shadowOffset: {
            width: 0,
            height: 10,
          },
        },
        tabBarActiveTintColor: theme.accent,
        tabBarInactiveTintColor: theme.textMuted,
        tabBarItemStyle: {
          height: 48,
          borderRadius: 18,
          justifyContent: "center",
          alignItems: "center",
          paddingVertical: 0,
          paddingBottom: 0,
          paddingTop: 0,
        },
        tabBarIconStyle: {
          marginBottom: 0,
          marginTop: 0,
        },
        tabBarBackground: () => <View style={[StyleSheet.absoluteFill, styles.tabBarBackground]} />,
      }}
    >
      <Tabs.Screen
        name="index"
        options={{
          title: "Home",
          tabBarIcon: ({ color, size }) => <SymbolIcon name="home" color={color} size={size} />,
        }}
      />
      <Tabs.Screen
        name="search"
        options={{
          title: "Search",
          tabBarIcon: ({ color, size }) => <SymbolIcon name="search" color={color} size={size} />,
        }}
      />
      <Tabs.Screen
        name="library"
        options={{
          title: "Library",
          tabBarIcon: ({ color, size }) => <SymbolIcon name="library" color={color} size={size} />,
        }}
      />
      <Tabs.Screen
        name="settings"
        options={{
          title: "Settings",
          tabBarIcon: ({ color, size }) => <SymbolIcon name="settings" color={color} size={size} />,
        }}
      />
      <Tabs.Screen
        name="playlist/[id]"
        options={{
          href: null,
        }}
      />
    </Tabs>
  );
}

const styles = StyleSheet.create({
  tabBarBackground: {
    borderRadius: 28,
    overflow: "hidden",
  },
});
