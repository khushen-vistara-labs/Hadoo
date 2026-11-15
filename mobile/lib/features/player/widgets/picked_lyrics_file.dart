import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

Future<String?> readTextFromPickedLyricsFile(PlatformFile file) async {
  try {
    return _decodeLyricsBytes(await file.readAsBytes());
  } on FileSystemException {
    return null;
  }
}

String? _decodeLyricsBytes(Uint8List bytes) {
  try {
    return utf8.decode(bytes);
  } catch (_) {
    try {
      return latin1.decode(bytes);
    } catch (_) {
      return null;
    }
  }
}
