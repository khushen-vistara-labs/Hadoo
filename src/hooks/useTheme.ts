import { themePresets } from "@/constants/theme";
import { useSettingsStore } from "@/modules/settings/settingsStore";

export const useTheme = () => {
  const themeId = useSettingsStore((state) => state.themeId);
  const accentOverride = useSettingsStore((state) => state.accentOverride);
  const base = themePresets[themeId];

  return {
    ...base,
    accent: accentOverride ?? base.accent,
  };
};
