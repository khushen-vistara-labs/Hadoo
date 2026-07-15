import { router } from "expo-router";
import { LinearGradient } from "expo-linear-gradient";
import { Pressable, StyleSheet, View } from "react-native";

import { CachedArtwork } from "@/components/artwork/CachedArtwork";
import { SymbolIcon } from "@/components/ui/SymbolIcon";
import { Text } from "@/components/ui/Text";
import { useMiniPlayerLayout } from "@/hooks/useMiniPlayerLayout";
import { usePlayer } from "@/hooks/usePlayer";
import { useTheme } from "@/hooks/useTheme";
import { playerService } from "@/modules/player/playerService";
import { formatDuration } from "@/utils/formatDuration";

export const MiniPlayer = () => {
  const { currentTrack, isPlaying, progress, duration } = usePlayer();
  const theme = useTheme();
  const { isTabScreen, miniPlayerBottomOffset } = useMiniPlayerLayout();

  if (!currentTrack) {
    return null;
  }

  const progressRatio = duration > 0 ? Math.min(Math.max(progress / duration, 0), 1) : 0;

  return (
    <Pressable onPress={() => router.push("/now-playing")} style={[styles.wrapper, { bottom: miniPlayerBottomOffset }]}>
      <View style={[styles.shell, { backgroundColor: theme.surface, borderColor: theme.border }]}>
        <LinearGradient colors={["rgba(255,255,255,0.06)", "rgba(255,255,255,0.02)"]} style={styles.card}>
          {currentTrack.artwork ? (
            <CachedArtwork
              artwork={currentTrack.artwork}
              category="track"
              variant="thumbnail"
              width={isTabScreen ? 46 : 52}
              height={isTabScreen ? 46 : 52}
              borderRadius={isTabScreen ? 16 : 18}
            />
          ) : (
            <LinearGradient colors={["#1D314A", "#0A1626"]} style={[styles.thumbFallback, isTabScreen ? styles.thumbFallbackCompact : null]}>
              <SymbolIcon name="disc" size={22} color={theme.accent} />
            </LinearGradient>
          )}

          <View style={styles.meta}>
            <Text numberOfLines={1}>{currentTrack.title}</Text>
            <Text muted numberOfLines={1}>
              {currentTrack.artist}
            </Text>
            <View style={styles.progressRail}>
              <View style={[styles.progressFill, { width: `${progressRatio * 100}%`, backgroundColor: theme.accent }]} />
            </View>
          </View>

          <View style={styles.rightCluster}>
            {!isTabScreen ? <Text muted>{formatDuration(duration || currentTrack.duration)}</Text> : null}
            <View style={styles.actions}>
              <Pressable
                hitSlop={8}
                onPress={(event) => {
                  event.stopPropagation();
                  void (isPlaying ? playerService.pause() : playerService.resume());
                }}
                style={[styles.actionButton, { backgroundColor: theme.surfaceAlt }]}
              >
                <SymbolIcon name={isPlaying ? "pause" : "play"} size={18} color={theme.text} />
              </Pressable>
              {!isPlaying ? (
                <Pressable
                  hitSlop={8}
                  onPress={(event) => {
                    event.stopPropagation();
                    void playerService.dismissMiniPlayer();
                  }}
                  style={[styles.dismissButton, { backgroundColor: theme.surfaceAlt }]}
                >
                  <SymbolIcon name="close" size={16} color={theme.textMuted} />
                </Pressable>
              ) : null}
            </View>
          </View>
        </LinearGradient>
      </View>
    </Pressable>
  );
};

const styles = StyleSheet.create({
  wrapper: {
    position: "absolute",
    left: 16,
    right: 16,
  },
  shell: {
    borderRadius: 26,
    borderWidth: 1,
    overflow: "hidden",
    shadowColor: "#000",
    shadowOpacity: 0.28,
    shadowRadius: 20,
    shadowOffset: {
      width: 0,
      height: 10,
    },
    elevation: 12,
  },
  card: {
    flexDirection: "row",
    alignItems: "center",
    gap: 12,
    paddingHorizontal: 14,
    paddingVertical: 10,
  },
  thumb: {
    width: 52,
    height: 52,
    borderRadius: 18,
  },
  thumbFallback: {
    width: 52,
    height: 52,
    borderRadius: 18,
    alignItems: "center",
    justifyContent: "center",
  },
  thumbFallbackCompact: {
    width: 46,
    height: 46,
    borderRadius: 16,
  },
  meta: {
    flex: 1,
    gap: 4,
  },
  progressRail: {
    height: 3,
    borderRadius: 999,
    overflow: "hidden",
    backgroundColor: "rgba(255,255,255,0.10)",
  },
  progressFill: {
    height: "100%",
    borderRadius: 999,
  },
  rightCluster: {
    alignItems: "flex-end",
    gap: 6,
  },
  actions: {
    flexDirection: "row",
    alignItems: "center",
    gap: 8,
  },
  actionButton: {
    width: 34,
    height: 34,
    borderRadius: 17,
    alignItems: "center",
    justifyContent: "center",
  },
  dismissButton: {
    width: 28,
    height: 28,
    borderRadius: 14,
    alignItems: "center",
    justifyContent: "center",
  },
});
