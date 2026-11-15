import 'package:flutter/material.dart';
import 'package:flick/widgets/lokal/lokal_toast.dart';
import 'package:flutter/services.dart';
import 'package:flick/services/android_audio_device_service.dart';

/// Android owns output selection; no intermediate app dialog or route list.
Future<void> openAndroidOutputChooser(BuildContext context) async {
  String? error;
  try {
    if (!await AndroidAudioDeviceService.instance.showOutputSwitcher()) {
      error = 'Android could not open the output chooser. Start playback, then try again.';
    }
  } on PlatformException catch (failure) {
    error = failure.message ?? 'Could not open Android output selection.';
  } on MissingPluginException {
    error = 'Output selection requires the updated Android app.';
  }
  if (error != null && context.mounted) {
    LokalToast.fromSnackBar(context, SnackBar(content: Text(error)));
  }
}
