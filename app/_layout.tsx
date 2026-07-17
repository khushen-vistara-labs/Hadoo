import { QueryClientProvider } from "@tanstack/react-query";
import { Ionicons } from "@expo/vector-icons";
import { useFonts } from "expo-font";
import * as SplashScreen from "expo-splash-screen";
import { Stack, router, usePathname } from "expo-router";
import { StatusBar } from "expo-status-bar";
import { useEffect } from "react";
import { GestureHandlerRootView } from "react-native-gesture-handler";

import { MiniPlayer } from "@/components/player/MiniPlayer";
import { AppBootstrapScreen } from "@/components/ui/AppBootstrapScreen";
import { AppLoadingOverlay } from "@/components/ui/AppLoadingOverlay";
import { queryClient } from "@/data/queryClient";
import { playerService } from "@/modules/player/playerService";
import { useTasteProfileStore } from "@/modules/recommendations/tasteProfileStore";
import { navigationService } from "@/services/navigationService";

void SplashScreen.preventAutoHideAsync().catch(() => {
  // Ignore duplicate calls during fast refresh.
});

export default function RootLayout() {
  const [fontsLoaded, fontError] = useFonts({
    ...Ionicons.font,
    CuteDisplay: require("../assets/fonts/Skia.ttf"),
  });
  const pathname = usePathname();
  const hasHydrated = useTasteProfileStore((state) => state.hasHydrated);
  const onboardingCompleted = useTasteProfileStore((state) => state.tasteProfile.onboardingCompleted);
  const isBootstrapping = !hasHydrated || (!fontsLoaded && !fontError);

  useEffect(() => {
    void playerService.setup();
  }, []);

  useEffect(() => {
    if (fontError && __DEV__) {
      console.warn("Ionicons failed to load", fontError);
    }
  }, [fontError]);

  useEffect(() => {
    if (!hasHydrated) {
      return;
    }

    if (!onboardingCompleted && pathname !== "/onboarding") {
      router.replace("/onboarding");
    }
  }, [hasHydrated, onboardingCompleted, pathname]);

  useEffect(() => {
    const timeout = setTimeout(() => {
      navigationService.stop();
    }, 350);

    return () => clearTimeout(timeout);
  }, [pathname]);

  useEffect(() => {
    if (isBootstrapping) {
      return;
    }

    void SplashScreen.hideAsync().catch(() => {
      // Ignore hide failures and continue boot.
    });
  }, [isBootstrapping]);

  return (
    <GestureHandlerRootView style={{ flex: 1 }}>
      <QueryClientProvider client={queryClient}>
        <StatusBar
          backgroundColor={isBootstrapping ? "#FFFFFF" : "transparent"}
          style={isBootstrapping ? "dark" : "light"}
        />
        <Stack screenOptions={{ headerShown: false }}>
          <Stack.Screen name="(tabs)" />
          <Stack.Screen name="onboarding" options={{ presentation: "card" }} />
          <Stack.Screen name="now-playing" options={{ presentation: "modal" }} />
          <Stack.Screen name="queue" options={{ presentation: "modal" }} />
          <Stack.Screen name="lyrics" options={{ presentation: "modal" }} />
          <Stack.Screen name="sleep-timer" options={{ presentation: "modal" }} />
          <Stack.Screen name="player-settings" options={{ presentation: "card" }} />
          <Stack.Screen name="source-settings" options={{ presentation: "card" }} />
        </Stack>
        {!isBootstrapping && pathname !== "/now-playing" ? <MiniPlayer /> : null}
        <AppLoadingOverlay />
        {isBootstrapping ? <AppBootstrapScreen /> : null}
      </QueryClientProvider>
    </GestureHandlerRootView>
  );
}
