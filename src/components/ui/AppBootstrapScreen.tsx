import { ActivityIndicator, StyleSheet, View } from "react-native";
import { StatusBar } from "expo-status-bar";

import { BrandLogo } from "@/components/ui/BrandLogo";

export const AppBootstrapScreen = () => (
  <View style={styles.container}>
    <StatusBar backgroundColor="#FFFFFF" style="dark" />
    <View style={styles.logoFrame}>
      <BrandLogo accessibilityLabel="Hadoo" size={280} variant="wordmark" />
      <ActivityIndicator color="#2AAEC7" size="small" style={styles.wordmarkSpinner} />
    </View>
  </View>
);

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: "center",
    justifyContent: "center",
    backgroundColor: "#FFFFFF",
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
