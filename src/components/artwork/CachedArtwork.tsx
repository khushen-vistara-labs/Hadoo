import { LinearGradient } from "expo-linear-gradient";
import { useEffect, useMemo, useRef, useState } from "react";
import {
  Animated,
  StyleSheet,
  View,
  type ImageResizeMode,
  type StyleProp,
  type ViewStyle,
} from "react-native";

import { SymbolIcon } from "@/components/ui/SymbolIcon";
import type { ArtworkCategory, ArtworkLike, ArtworkVariant } from "@/types/artwork";
import { getArtworkCandidates, getDecodePixelSize, markArtworkUrlFailed } from "@/utils/artwork";

type Props = {
  artwork?: ArtworkLike;
  fallbackArtwork?: ArtworkLike;
  category: ArtworkCategory;
  variant?: ArtworkVariant;
  fit?: ImageResizeMode;
  width: number;
  height: number;
  borderRadius?: number;
  style?: StyleProp<ViewStyle>;
};

const placeholderIcon: Record<ArtworkCategory, "disc" | "person" | "albums" | "library" | "sparkles"> = {
  track: "disc",
  album: "albums",
  artist: "person",
  playlist: "library",
  hero: "sparkles",
};

const placeholderColors: Record<ArtworkCategory, [string, string]> = {
  track: ["#1A2E44", "#101A28"],
  album: ["#243750", "#0F1724"],
  artist: ["#203149", "#121C2A"],
  playlist: ["#182A3E", "#0C1520"],
  hero: ["#223757", "#101826"],
};

export const CachedArtwork = ({
  artwork,
  fallbackArtwork,
  category,
  variant = "card",
  fit = "cover",
  width,
  height,
  borderRadius = 0,
  style,
}: Props) => {
  const candidates = useMemo(
    () => getArtworkCandidates(artwork, fallbackArtwork, variant),
    [artwork, fallbackArtwork, variant],
  );
  const [candidateIndex, setCandidateIndex] = useState(0);
  const [loaded, setLoaded] = useState(false);
  const fade = useRef(new Animated.Value(0)).current;
  const current = candidates[candidateIndex];
  const decodeWidth = getDecodePixelSize(width);
  const decodeHeight = getDecodePixelSize(height);

  useEffect(() => {
    setCandidateIndex(0);
    setLoaded(false);
    fade.setValue(0);
  }, [artwork, fallbackArtwork, variant, fade]);

  return (
    <View style={[{ width, height, borderRadius }, style]}>
      {current ? (
        <Animated.Image
          source={{
            uri: current.uri,
            width: decodeWidth,
            height: decodeHeight,
          }}
          resizeMode={fit}
          onLoad={() => {
            setLoaded(true);
            Animated.timing(fade, {
              toValue: 1,
              duration: 180,
              useNativeDriver: true,
            }).start();
          }}
          onError={() => {
            markArtworkUrlFailed(current.uri);
            setCandidateIndex((index) => index + 1);
          }}
          style={[
            styles.image,
            {
              width,
              height,
              borderRadius,
              opacity: fade,
            },
          ]}
        />
      ) : null}

      {!current ? (
        <Placeholder category={category} width={width} height={height} borderRadius={borderRadius} />
      ) : !loaded ? (
        <View pointerEvents="none" style={[styles.loadingMask, { width, height, borderRadius }]} />
      ) : null}
    </View>
  );
};

CachedArtwork.deterministic = CachedArtwork;

const Placeholder = ({
  category,
  width,
  height,
  borderRadius,
}: {
  category: ArtworkCategory;
  width: number;
  height: number;
  borderRadius: number;
}) => (
  <LinearGradient colors={placeholderColors[category]} style={{ width, height, borderRadius, alignItems: "center", justifyContent: "center" }}>
    <SymbolIcon name={placeholderIcon[category]} size={Math.max(20, Math.min(width, height) * 0.28)} color="#7CFFB2" />
  </LinearGradient>
);

const styles = StyleSheet.create({
  image: {
    position: "absolute",
    top: 0,
    left: 0,
  },
  loadingMask: {
    position: "absolute",
    top: 0,
    left: 0,
    backgroundColor: "rgba(255,255,255,0.03)",
  },
});
