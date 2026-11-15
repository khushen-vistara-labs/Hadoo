import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flick/features/player/widgets/picked_lyrics_file.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:share_plus/share_plus.dart' show XFile;

void main() {
  test('reads UTF-8 lyrics from a picker file without a local path', () async {
    final file = _PickedFile(utf8.encode('[00:01.00]夜曲'));
    expect(file.path, isNull);
    expect(await readTextFromPickedLyricsFile(file), '[00:01.00]夜曲');
  });

  test('preserves Latin-1 fallback for imported lyrics', () async {
    final file = _PickedFile(latin1.encode('[00:01.00]café'));
    expect(await readTextFromPickedLyricsFile(file), '[00:01.00]café');
  });

  test('unreadable picker files still return no lyrics', () async {
    final file = _PickedFile([], error: const FileSystemException('gone'));
    expect(await readTextFromPickedLyricsFile(file), isNull);
  });
}

final class _PickedFile extends PlatformFile {
  _PickedFile(List<int> bytes, {this.error})
    : bytes = Uint8List.fromList(bytes);
  final Uint8List bytes;
  final FileSystemException? error;

  @override
  String get name => 'lyrics.lrc';
  @override
  Uri get uri => Uri.parse('content://documents/lyrics');
  @override
  XFile get xFile => XFile.fromData(bytes, name: name);
  @override
  int lengthSync() => bytes.length;
  @override
  Future<int> length() async => bytes.length;
  @override
  Future<Uint8List> readAsBytes() async {
    if (error != null) throw error!;
    return bytes;
  }

  @override
  Stream<Uint8List> readAsByteStream() => Stream.value(bytes);
}
