import { router, type Href } from "expo-router";

import { useNavigationUiStore } from "@/store/navigationUiStore";

export const navigationService = {
  push(href: Href, label = "Opening…") {
    useNavigationUiStore.getState().start(label);
    router.push(href);
  },
  replace(href: Href, label = "Opening…") {
    useNavigationUiStore.getState().start(label);
    router.replace(href);
  },
  stop() {
    useNavigationUiStore.getState().stop();
  },
};

