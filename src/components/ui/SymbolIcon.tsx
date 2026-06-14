import { StyleSheet, Text as RNText } from "react-native";

type SymbolName =
  | "home"
  | "search"
  | "library"
  | "settings"
  | "play"
  | "pause"
  | "back"
  | "next"
  | "repeat"
  | "shuffle"
  | "down";

const glyphs: Record<SymbolName, string> = {
  home: "⌂",
  search: "⌕",
  library: "☰",
  settings: "⚙",
  play: "▶",
  pause: "⏸",
  back: "⏮",
  next: "⏭",
  repeat: "⟲",
  shuffle: "⇅",
  down: "⌄",
};

type Props = {
  name: SymbolName;
  size?: number;
  color: string;
};

export const SymbolIcon = ({ name, size = 18, color }: Props) => (
  <RNText style={[styles.icon, { fontSize: size, color }]}>{glyphs[name]}</RNText>
);

const styles = StyleSheet.create({
  icon: {
    fontWeight: "700",
    textAlign: "center",
    includeFontPadding: false,
  },
});
