import { usePathname } from "expo-router";
import { useSafeAreaInsets } from "react-native-safe-area-context";

import { usePlayer } from "@/hooks/usePlayer";

const TAB_BAR_BASE_HEIGHT = 56;
const TAB_BAR_BOTTOM_GAP = 14;
const TAB_SCREEN_PLAYER_BOTTOM_OFFSET = 92;
const TAB_SCREEN_PLAYER_HEIGHT = 74;
const STACK_SCREEN_PLAYER_HEIGHT = 82;

export const useMiniPlayerLayout = () => {
  const { currentTrack } = usePlayer();
  const pathname = usePathname();
  const insets = useSafeAreaInsets();

  const isTabScreen =
    pathname === "/" ||
    pathname.startsWith("/search") ||
    pathname.startsWith("/library") ||
    pathname.startsWith("/settings") ||
    pathname.startsWith("/playlist/");
  const isNowPlaying = pathname === "/now-playing";
  const isVisible = Boolean(currentTrack) && !isNowPlaying;
  const bottomInset = Math.max(insets.bottom, 8);
  const tabBarHeight = TAB_BAR_BASE_HEIGHT + bottomInset;
  const miniPlayerBottomOffset = isTabScreen ? TAB_SCREEN_PLAYER_BOTTOM_OFFSET : Math.max(insets.bottom + 16, 24);
  const miniPlayerHeight = isTabScreen ? TAB_SCREEN_PLAYER_HEIGHT : STACK_SCREEN_PLAYER_HEIGHT;
  const tabScreenBaseSpacing = tabBarHeight + TAB_BAR_BOTTOM_GAP + 16;
  const contentBottomSpacing = isVisible
    ? isTabScreen
      ? tabScreenBaseSpacing + miniPlayerHeight
      : miniPlayerBottomOffset + miniPlayerHeight + 16
    : isTabScreen
      ? tabScreenBaseSpacing
      : 0;

  return {
    isVisible,
    isTabScreen,
    miniPlayerBottomOffset,
    miniPlayerHeight,
    contentBottomSpacing,
  };
};
