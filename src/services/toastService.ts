import { Alert, Platform, ToastAndroid } from "react-native";

export const toastService = {
  show(message: string) {
    if (Platform.OS === "android") {
      ToastAndroid.show(message, ToastAndroid.SHORT);
      return;
    }
    Alert.alert("Hadoo", message);
  },
};
