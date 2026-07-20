import { ActivityIndicator, StyleSheet, View } from "react-native";

import { BrandLogo } from "@/components/ui/BrandLogo";

export const AppBootstrapScreen = () => (
  <View style={styles.container}>
    <View style={styles.logoFrame}>
      <BrandLogo accessibilityLabel="Hadoo" size={280} variant="wordmark" />
      <ActivityIndicator color="#2AAEC7" size="small" style={styles.wordmarkSpinner} />
    </View>
  </View>
);

const styles = StyleSheet.create({
  container: {
    ...StyleSheet.absoluteFillObject,
    alignItems: "center",
    justifyContent: "center",
    backgroundColor: "#FFFFFF",
    zIndex: 100,
  },
  logoFrame: {
    width: 280,
    height: 280,
  },
  wordmarkSpinner: {
    position: "absolute",
    top: 194,
    right: 28,
  },
});
