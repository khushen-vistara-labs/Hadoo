import { Ionicons } from "@expo/vector-icons";

type SymbolName =
  | "home"
  | "search"
  | "library"
  | "settings"
  | "play"
  | "pause"
  | "back"
  | "navBack"
  | "next"
  | "repeat"
  | "shuffle"
  | "down"
  | "list"
  | "mic"
  | "moon"
  | "close"
  | "quote"
  | "albums"
  | "forward"
  | "menu"
  | "heart"
  | "heartOutline"
  | "share"
  | "sliders"
  | "equalizer"
  | "tune"
  | "add"
  | "download"
  | "link"
  | "refresh"
  | "sparkles"
  | "person"
  | "checkCircle";

const glyphs: Record<SymbolName, keyof typeof Ionicons.glyphMap> = {
  home: "home",
  search: "search",
  library: "library",
  settings: "settings",
  play: "play",
  pause: "pause",
  back: "play-skip-back",
  navBack: "chevron-back",
  next: "play-skip-forward",
  repeat: "repeat",
  shuffle: "shuffle",
  down: "chevron-down",
  list: "list",
  mic: "mic",
  moon: "moon",
  close: "close",
  quote: "document-text",
  albums: "albums",
  forward: "chevron-forward",
  menu: "ellipsis-horizontal",
  heart: "heart",
  heartOutline: "heart-outline",
  share: "share-social-outline",
  sliders: "options-outline",
  equalizer: "bar-chart-outline",
  tune: "construct-outline",
  add: "add-circle-outline",
  download: "download-outline",
  link: "open-outline",
  refresh: "refresh-outline",
  sparkles: "sparkles-outline",
  person: "person-outline",
  checkCircle: "checkmark-circle",
};

type Props = {
  name: SymbolName;
  size?: number;
  color: string;
};

export const SymbolIcon = ({ name, size = 18, color }: Props) => (
  <Ionicons name={glyphs[name]} size={size} color={color} />
);
