import TrackPlayer from "react-native-track-player";

import "expo-router/entry";
import { playbackService } from "./src/modules/player/playbackService";

TrackPlayer.registerPlaybackService(() => playbackService);
