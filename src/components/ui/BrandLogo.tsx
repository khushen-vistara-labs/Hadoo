import { Image, type ImageStyle, type StyleProp } from "react-native";

type BrandLogoProps = {
  size: number;
  accessibilityLabel?: string;
  style?: StyleProp<ImageStyle>;
  variant?: "mark" | "wordmark";
};

const logoSources = {
  mark: require("../../../assets/images/hadoo-mark.png"),
  wordmark: require("../../../assets/images/hadoo-logo.png"),
};

export const BrandLogo = ({ size, accessibilityLabel, style, variant = "mark" }: BrandLogoProps) => (
  <Image
    accessibilityLabel={accessibilityLabel}
    accessible={Boolean(accessibilityLabel)}
    resizeMode="contain"
    source={logoSources[variant]}
    style={[{ width: size, height: size }, style]}
  />
);
