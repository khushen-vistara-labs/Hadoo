import { LinearGradient } from "expo-linear-gradient";
import { router } from "expo-router";
import { Image, Pressable, ScrollView, StyleSheet, View, useWindowDimensions } from "react-native";
import { useMemo, useState } from "react";
import { useSafeAreaInsets } from "react-native-safe-area-context";

import { ProgressBar } from "@/components/ui/ProgressBar";
import { Screen } from "@/components/ui/Screen";
import { SymbolIcon } from "@/components/ui/SymbolIcon";
import { Text } from "@/components/ui/Text";
import { providerLabels } from "@/constants/providers";
import { usePlayer } from "@/hooks/usePlayer";
import { useTheme } from "@/hooks/useTheme";
import { playerService } from "@/modules/player/playerService";
import { formatDuration } from "@/utils/formatDuration";

const menuItems = [
  { icon: "next", title: "Play Next", hint: "Later" },
  { icon: "list", title: "Add to Queue", hint: "Later" },
  { icon: "heartOutline", title: "Add to Favorites", hint: "Later" },
  { icon: "add", title: "Add to Playlist", hint: "Later" },
  { icon: "sparkles", title: "Smart Replace", hint: "Later" },
  { icon: "refresh", title: "Get Latest Metadata", hint: "Later" },
  { icon: "checkCircle", title: "Available Offline", hint: "Later" },
  { icon: "share", title: "Share", hint: "Later" },
  { icon: "link", title: "Open Original Link", hint: "Later" },
  { icon: "person", title: "Go to Artist", hint: "Later" },
] as const;

const quickActions = [
  { icon: "quote", label: "Lyrics", route: "/lyrics" as const },
  { icon: "list", label: "Queue", route: "/queue" as const },
  { icon: "tune", label: "Settings", route: "/player-settings" as const },
  { icon: "moon", label: "Sleep", route: "/sleep-timer" as const },
  { icon: "share", label: "Share", route: null },
] as const;

export default function NowPlayingScreen() {
  const player = usePlayer();
  const theme = useTheme();
  const insets = useSafeAreaInsets();
  const { width } = useWindowDimensions();
  const [seekDraft, setSeekDraft] = useState<number | null>(null);
  const [menuOpen, setMenuOpen] = useState(false);
  const [liked, setLiked] = useState(false);
  const duration = player.duration || player.currentTrack?.duration || 0;
  const elapsed = seekDraft ?? player.progress;
  const progress = duration ? elapsed / duration : 0;
  const contextLabel = useMemo(() => {
    if (!player.currentTrack) {
      return "Ready to play";
    }

    if (player.currentTrack.album) {
      return player.currentTrack.album;
    }

    if (player.currentTrack.provider !== "mock") {
      return providerLabels[player.currentTrack.provider];
    }

    return "Now Playing";
  }, [player.currentTrack]);
  const canControlPlayback = Boolean(player.currentTrack);
  const artworkSize = Math.min(width * 0.58, 244);
  const artworkRadius = artworkSize * 0.2;
  const artworkInset = Math.max(8, artworkSize * 0.04);
  const heroHaloInset = Math.max(10, artworkSize * 0.05);
  const primaryActionSize = Math.min(width * 0.2, 80);
  const primaryActionRadius = primaryActionSize / 2;
  const verticalGap = Math.max(width * 0.016, 6);
  const lowerSectionTop = Math.max(width * 0.01, 2);

  return (
    <Screen scroll={false} contentContainerStyle={styles.screenContent}>
      <View
        style={[
          styles.content,
          {
            paddingBottom: Math.max(insets.bottom * 0.35, 10),
            gap: verticalGap,
          },
        ]}
      >
        <View pointerEvents="none" style={styles.backgroundOrbs}>
          <View style={[styles.orb, styles.orbLeft, { backgroundColor: theme.accent }]} />
          <View style={[styles.orb, styles.orbRight, { backgroundColor: theme.accentAlt }]} />
        </View>

        <View style={styles.topSection}>
          <View style={styles.header}>
            <View style={styles.headerSide}>
              <Pressable
                hitSlop={10}
                onPress={() => router.back()}
                style={styles.headerButton}
              >
                <SymbolIcon name="down" size={20} color={theme.text} />
              </Pressable>
            </View>
            <View style={styles.headerTitle}>
              <Text muted style={styles.headerEyebrow}>
                Now Spinning
              </Text>
              <Text numberOfLines={1}>{contextLabel}</Text>
            </View>
            <View style={styles.headerActions}>
              <Pressable
                hitSlop={10}
                onPress={() => router.push("/player-settings")}
                style={styles.headerButton}
              >
                <SymbolIcon name="equalizer" size={18} color={theme.text} />
              </Pressable>
              <Pressable
                hitSlop={10}
                onPress={() => setMenuOpen(true)}
                style={styles.headerButton}
              >
                <SymbolIcon name="menu" size={18} color={theme.text} />
              </Pressable>
            </View>
          </View>

          <View style={styles.hero}>
            <View style={[styles.artworkHalo, { backgroundColor: theme.surfaceAlt, padding: heroHaloInset }]}>
              <LinearGradient
                colors={[theme.surfaceAlt, theme.surface, theme.card]}
                start={{ x: 0, y: 0 }}
                end={{ x: 1, y: 1 }}
                style={[
                  styles.artworkFrame,
                  {
                    width: artworkSize,
                    borderRadius: artworkRadius * 1.3,
                    padding: artworkInset,
                  },
                ]}
              >
                <View
                  style={[
                    styles.artworkShell,
                    { backgroundColor: theme.card, borderRadius: artworkRadius },
                  ]}
                >
                  {player.currentTrack?.artwork ? (
                    <Image source={{ uri: player.currentTrack.artwork }} style={styles.artwork} resizeMode="cover" />
                  ) : (
                    <View style={[styles.artwork, { backgroundColor: theme.card }]} />
                  )}
                </View>
              </LinearGradient>
            </View>
          </View>

          <View style={styles.meta}>
            <View style={styles.titleRow}>
              <View style={styles.titleMeta}>
                <Text numberOfLines={2} variant="title" style={styles.title}>
                  {player.currentTrack?.title ?? "Nothing playing"}
                </Text>
                <Text muted numberOfLines={1} style={styles.subtitle}>
                  {player.currentTrack
                    ? `${player.currentTrack.artist}${detailSuffix(player.currentTrack.album)}`
                    : "Choose something from home or search."}
                </Text>
              </View>
              <Pressable
                hitSlop={8}
                onPress={() => setLiked((current) => !current)}
                style={[styles.likeButton, { backgroundColor: theme.surfaceAlt, borderColor: theme.border }]}
              >
                <SymbolIcon
                  name={liked ? "heart" : "heartOutline"}
                  size={20}
                  color={liked ? theme.accent : theme.textMuted}
                />
              </Pressable>
            </View>
          </View>
        </View>

        <View style={styles.bottomSection}>
        <View style={[styles.playerShell, { paddingTop: lowerSectionTop }]}>
          <View style={styles.progressGroup}>
            <ProgressBar
              progress={progress}
              interactive={duration > 0}
              onScrubStart={() => setSeekDraft(player.progress)}
              onScrubChange={(nextProgress) => setSeekDraft(nextProgress * duration)}
              onScrubComplete={async (nextProgress) => {
                const nextPosition = nextProgress * duration;
                try {
                  setSeekDraft(nextPosition);
                  await playerService.seek(nextPosition);
                } finally {
                  setSeekDraft(null);
                }
              }}
            />
            <View style={styles.timeRow}>
              <Text muted>{formatDuration(elapsed)}</Text>
              <Text muted>{duration ? `-${formatDuration(Math.max(duration - elapsed, 0))}` : "--:--"}</Text>
            </View>
          </View>
          <View style={styles.transportStage}>
            <LinearGradient
              colors={[theme.surfaceAlt, theme.surface]}
              start={{ x: 0, y: 0.5 }}
              end={{ x: 1, y: 0.5 }}
              style={styles.transportDeck}
            >
              <Pressable
                disabled={!canControlPlayback}
                hitSlop={10}
                onPress={() => playerService.toggleShuffle()}
                style={styles.sideControl}
              >
                <SymbolIcon name="shuffle" size={20} color={player.shuffle ? theme.accent : theme.textMuted} />
              </Pressable>
              <Pressable
                disabled={!canControlPlayback}
                hitSlop={10}
                onPress={() => playerService.skipPrevious()}
                style={styles.transportButton}
              >
                <SymbolIcon name="back" size={26} color={canControlPlayback ? theme.text : theme.textMuted} />
              </Pressable>
              <View style={styles.transportCenterSpacer} />
              <Pressable
                disabled={!canControlPlayback}
                hitSlop={10}
                onPress={() => playerService.skipNext()}
                style={styles.transportButton}
              >
                <SymbolIcon name="next" size={26} color={canControlPlayback ? theme.text : theme.textMuted} />
              </Pressable>
              <Pressable
                disabled={!canControlPlayback}
                hitSlop={10}
                onPress={() => playerService.toggleRepeat()}
                style={styles.sideControl}
              >
                <SymbolIcon name="repeat" size={20} color={player.repeatMode !== "off" ? theme.accent : theme.textMuted} />
              </Pressable>
            </LinearGradient>
            <LinearGradient
              colors={[theme.accentAlt, theme.accent]}
              start={{ x: 0, y: 0 }}
              end={{ x: 1, y: 1 }}
              style={[
                styles.primaryAction,
                {
                  width: primaryActionSize,
                  height: primaryActionSize,
                  borderRadius: primaryActionRadius,
                },
              ]}
            >
              <Pressable
                disabled={!canControlPlayback}
                style={styles.primaryActionPress}
                onPress={() => (player.isPlaying ? playerService.pause() : playerService.resume())}
              >
                <SymbolIcon name={player.isPlaying ? "pause" : "play"} size={30} color={theme.background} />
              </Pressable>
            </LinearGradient>
          </View>

          <View style={styles.quickActions}>
            {quickActions.map((action) => (
              <Pressable
                key={action.label}
                onPress={() => {
                  if (action.route) {
                    router.push(action.route);
                  }
                }}
                style={[
                  styles.quickAction,
                ]}
              >
                <SymbolIcon name={action.icon} size={19} color={theme.textMuted} />
              <Text muted style={styles.quickLabel}>{action.label}</Text>
            </Pressable>
          ))}
        </View>
        </View>
        </View>

        {menuOpen ? (
          <View style={styles.overlay}>
            <Pressable style={styles.backdrop} onPress={() => setMenuOpen(false)} />
            <View
              style={[
                styles.menuSheet,
                {
                  backgroundColor: theme.background,
                  paddingBottom: Math.max(insets.bottom, 18) + 20,
                },
              ]}
            >
              <View style={[styles.sheetHandle, { backgroundColor: theme.textMuted }]} />
              <View style={styles.menuTopBar}>
                <View style={styles.menuTopSpacer} />
                <Text muted variant="caption" style={styles.menuTopTitle}>
                  Track Options
                </Text>
                <Pressable
                  onPress={() => setMenuOpen(false)}
                  style={styles.menuCloseButton}
                >
                  <SymbolIcon name="close" size={18} color={theme.text} />
                </Pressable>
              </View>
              <ScrollView
                showsVerticalScrollIndicator={false}
                contentContainerStyle={styles.menuScrollContent}
              >
                <View style={styles.menuHeader}>
                  <View style={styles.menuArtworkWrap}>
                    {player.currentTrack?.artwork ? (
                      <Image source={{ uri: player.currentTrack.artwork }} style={styles.menuArtwork} resizeMode="cover" />
                    ) : (
                      <View style={[styles.menuArtwork, { backgroundColor: theme.surface }]} />
                    )}
                  </View>
                  <View style={styles.menuMeta}>
                    <Text numberOfLines={1}>{player.currentTrack?.title ?? "Current Track"}</Text>
                    <Text muted numberOfLines={1}>
                      {player.currentTrack?.artist ?? "No artist"}
                    </Text>
                  </View>
                </View>
                <View style={styles.menuGrid}>
                  <Pressable style={styles.menuChip} onPress={() => setMenuOpen(false)}>
                    <SymbolIcon name="next" size={16} color={theme.accent} />
                    <Text>Play Next</Text>
                  </Pressable>
                  <Pressable style={styles.menuChip} onPress={() => setMenuOpen(false)}>
                    <SymbolIcon name="list" size={16} color={theme.accent} />
                    <Text>Add to Queue</Text>
                  </Pressable>
                </View>
                <View style={styles.menuList}>
                  {menuItems.slice(2).map((item) => (
                    <Pressable
                      key={item.title}
                      onPress={() => setMenuOpen(false)}
                      style={styles.menuRow}
                    >
                      <View style={[styles.menuRowIcon, { backgroundColor: theme.surfaceAlt }]}>
                        <SymbolIcon
                          name={item.icon}
                          size={18}
                          color={item.icon === "checkCircle" ? theme.accent : theme.text}
                        />
                      </View>
                      <View style={styles.menuRowMeta}>
                        <Text>{item.title}</Text>
                        <Text muted style={styles.menuHint}>
                          {item.hint}
                        </Text>
                      </View>
                      <SymbolIcon name="forward" size={16} color={theme.textMuted} />
                    </Pressable>
                  ))}
                </View>
              </ScrollView>
            </View>
          </View>
        ) : null}
      </View>
    </Screen>
  );
}

const detailSuffix = (album?: string) => (album ? ` • ${album}` : "");

const styles = StyleSheet.create({
  screenContent: {
    flex: 1,
    paddingBottom: 0,
  },
  content: {
    flex: 1,
    justifyContent: "flex-start",
  },
  topSection: {
    flex: 1,
    gap: 8,
    justifyContent: "space-between",
  },
  bottomSection: {
    justifyContent: "flex-start",
    flexShrink: 0,
  },
  backgroundOrbs: {
    ...StyleSheet.absoluteFillObject,
    overflow: "hidden",
  },
  orb: {
    position: "absolute",
    width: 220,
    height: 220,
    borderRadius: 999,
    opacity: 0.08,
  },
  orbLeft: {
    top: 30,
    left: -90,
  },
  orbRight: {
    top: 150,
    right: -110,
  },
  header: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
    marginTop: "-1%",
  },
  headerButton: {
    width: 36,
    height: 28,
    alignItems: "center",
    justifyContent: "center",
  },
  headerSide: {
    width: 80,
    justifyContent: "center",
    alignItems: "flex-start",
  },
  headerTitle: {
    flex: 1,
    alignItems: "center",
    gap: 2,
    paddingHorizontal: 8,
  },
  headerEyebrow: {
    fontSize: 11,
    letterSpacing: 0.7,
    textTransform: "uppercase",
  },
  headerActions: {
    flexDirection: "row",
    gap: 8,
    width: 80,
    justifyContent: "flex-end",
  },
  hero: {
    alignItems: "center",
    flexShrink: 0,
    marginTop: "-1%",
  },
  artworkHalo: {
    padding: 11,
    borderRadius: 999,
    opacity: 0.95,
  },
  artworkFrame: {
    width: 196,
    maxWidth: "100%",
    aspectRatio: 1,
    borderRadius: 38,
    alignItems: "center",
    justifyContent: "center",
    padding: 9,
    shadowColor: "#000000",
    shadowOpacity: 0.18,
    shadowRadius: 18,
    shadowOffset: { width: 0, height: 10 },
    elevation: 8,
  },
  artworkShell: {
    width: "100%",
    height: "100%",
    borderRadius: 30,
    overflow: "hidden",
  },
  artwork: {
    width: "100%",
    height: "100%",
  },
  meta: {
    gap: 7,
    flexShrink: 0,
  },
  titleRow: {
    flexDirection: "row",
    alignItems: "center",
    gap: 14,
  },
  titleMeta: {
    flex: 1,
    gap: 4,
  },
  title: {
    fontSize: 20,
    lineHeight: 25,
  },
  subtitle: {
    fontSize: 14,
  },
  likeButton: {
    width: 40,
    height: 40,
    borderRadius: 20,
    borderWidth: 1,
    alignItems: "center",
    justifyContent: "center",
  },
  playerShell: {
    gap: 14,
    justifyContent: "flex-end",
  },
  progressGroup: {
    gap: 8,
    paddingHorizontal: "3%",
  },
  timeRow: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
  },
  transportStage: {
    alignItems: "center",
    justifyContent: "center",
    minHeight: 100,
  },
  transportDeck: {
    width: "100%",
    borderRadius: 999,
    paddingVertical: 14,
    paddingHorizontal: 19,
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
    shadowColor: "#000000",
    shadowOpacity: 0.12,
    shadowRadius: 18,
    shadowOffset: { width: 0, height: 10 },
    elevation: 4,
  },
  transportButton: {
    width: 44,
    height: 44,
    alignItems: "center",
    justifyContent: "center",
  },
  sideControl: {
    width: 38,
    height: 38,
    alignItems: "center",
    justifyContent: "center",
  },
  transportCenterSpacer: {
    width: 76,
  },
  primaryAction: {
    position: "absolute",
    alignItems: "center",
    justifyContent: "center",
    shadowColor: "#000000",
    shadowOpacity: 0.2,
    shadowRadius: 22,
    shadowOffset: { width: 0, height: 12 },
    elevation: 7,
  },
  primaryActionPress: {
    width: "100%",
    height: "100%",
    alignItems: "center",
    justifyContent: "center",
  },
  quickActions: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "flex-start",
    paddingHorizontal: "2%",
  },
  quickAction: {
    width: "18%",
    alignItems: "center",
    gap: 10,
    paddingVertical: 2,
  },
  quickLabel: {
    fontSize: 10.5,
    textAlign: "center",
    letterSpacing: 0.2,
  },
  overlay: {
    ...StyleSheet.absoluteFillObject,
    justifyContent: "flex-end",
  },
  backdrop: {
    ...StyleSheet.absoluteFillObject,
    backgroundColor: "rgba(0,0,0,0.44)",
  },
  menuSheet: {
    borderTopLeftRadius: 28,
    borderTopRightRadius: 28,
    maxHeight: "76%",
    paddingHorizontal: 18,
    paddingTop: 16,
    paddingBottom: 24,
    gap: 18,
  },
  menuScrollContent: {
    gap: 16,
    paddingBottom: 18,
  },
  sheetHandle: {
    alignSelf: "center",
    width: 42,
    height: 5,
    borderRadius: 999,
    opacity: 0.5,
  },
  menuTopBar: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
    marginBottom: 4,
  },
  menuTopSpacer: {
    width: 24,
    height: 24,
  },
  menuTopTitle: {
    flex: 1,
    textAlign: "center",
    letterSpacing: 1.1,
  },
  menuCloseButton: {
    width: 24,
    height: 24,
    alignItems: "center",
    justifyContent: "center",
  },
  menuHeader: {
    flexDirection: "row",
    alignItems: "center",
    gap: 12,
    paddingVertical: 8,
  },
  menuArtworkWrap: {
    padding: 4,
    borderRadius: 20,
  },
  menuArtwork: {
    width: 52,
    height: 52,
    borderRadius: 16,
  },
  menuMeta: {
    flex: 1,
    gap: 2,
  },
  menuGrid: {
    flexDirection: "row",
    gap: 10,
  },
  menuChip: {
    flex: 1,
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "center",
    gap: 8,
    borderRadius: 999,
    paddingVertical: 12,
    paddingHorizontal: 12,
  },
  menuList: {
    gap: 6,
  },
  menuRow: {
    flexDirection: "row",
    alignItems: "center",
    gap: 12,
    borderRadius: 16,
    paddingHorizontal: 12,
    paddingVertical: 13,
  },
  menuRowIcon: {
    width: 40,
    height: 40,
    borderRadius: 14,
    alignItems: "center",
    justifyContent: "center",
  },
  menuRowMeta: {
    flex: 1,
    gap: 2,
  },
  menuHint: {
    fontSize: 12,
  },
});
