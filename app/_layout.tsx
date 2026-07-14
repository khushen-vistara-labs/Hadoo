import { QueryClientProvider } from "@tanstack/react-query";
import { Ionicons } from "@expo/vector-icons";
import { useFonts } from "expo-font";
import { Stack, usePathname } from "expo-router";
import { StatusBar } from "expo-status-bar";
import { useEffect } from "react";
import { GestureHandlerRootView } from "react-native-gesture-handler";

import { MiniPlayer } from "@/components/player/MiniPlayer";
import { queryClient } from "@/data/queryClient";
import { playerService } from "@/modules/player/playerService";

export default function RootLayout() {
  const [, fontError] = useFonts(Ionicons.font);
  const pathname = usePathname();

  useEffect(() => {
    void playerService.setup();
  }, []);

  useEffect(() => {
    if (fontError && __DEV__) {
      console.warn("Ionicons failed to load", fontError);
    }
  }, [fontError]);

  return (
    <GestureHandlerRootView style={{ flex: 1 }}>
      <QueryClientProvider client={queryClient}>
        <StatusBar style="light" />
        <Stack screenOptions={{ headerShown: false }}>
          <Stack.Screen name="(tabs)" />
          <Stack.Screen name="now-playing" options={{ presentation: "modal" }} />
          <Stack.Screen name="queue" options={{ presentation: "modal" }} />
          <Stack.Screen name="playlist/[id]" options={{ presentation: "card" }} />
          <Stack.Screen name="lyrics" options={{ presentation: "modal" }} />
          <Stack.Screen name="sleep-timer" options={{ presentation: "modal" }} />
          <Stack.Screen name="player-settings" options={{ presentation: "card" }} />
          <Stack.Screen name="source-settings" options={{ presentation: "card" }} />
        </Stack>
        {pathname !== "/now-playing" ? <MiniPlayer /> : null}
      </QueryClientProvider>
    </GestureHandlerRootView>
  );
}
