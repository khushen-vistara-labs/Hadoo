import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image;
import 'package:flick/services/color_extraction_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('CPU-isolate artwork sampler returns consistent dominant and palette colors', () async {
    final directory = await Directory.systemTemp.createTemp('artwork_colors');
    addTearDown(() => directory.delete(recursive: true));
    final path = '${directory.path}/cover.png';
    final art = image.Image(width: 128, height: 128);
    image.fill(art, color: image.ColorRgb8(40, 120, 208));
    await File(path).writeAsBytes(image.encodePng(art));

    final colors = ColorExtractionService();
    colors.clearCache();
    final dominant = await colors.extractDominantColor(path);
    expect(dominant, isNotNull);
    expect(dominant!.r * 255, closeTo(40, 2));
    expect(dominant.g * 255, closeTo(120, 2));
    expect(dominant.b * 255, closeTo(208, 2));

    // No second decode or GPU readback: the full-player palette shares the
    // cached 32x32 sample with the shell's dominant-color request.
    await File(path).delete();
    final palette = await colors.extractPalette(path);
    expect(palette, isNotEmpty);
    expect(palette.first.r * 255, closeTo(40, 2));
    expect(palette.first.b * 255, closeTo(208, 2));
    colors.clearCache();
  });

  test('missing artwork can be retried after the file appears', () async {
    final directory = await Directory.systemTemp.createTemp('artwork_retry');
    addTearDown(() => directory.delete(recursive: true));
    final path = '${directory.path}/future.png';
    final colors = ColorExtractionService()..clearCache();
    expect(await colors.extractDominantColor(path), isNull);
    final art = image.Image(width: 32, height: 32);
    image.fill(art, color: image.ColorRgb8(200, 20, 20));
    await File(path).writeAsBytes(image.encodePng(art));
    expect(await colors.extractDominantColor(path), isNotNull);
    colors.clearCache();
  });
}
