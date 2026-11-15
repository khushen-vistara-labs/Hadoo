import 'dart:io';

import 'package:image/image.dart' as img;

/// Run from mobile/: dart run tool/gen_hadoo_branding.dart.
/// Resamples the existing mark, keeping the original source unchanged.
void main() {
  final input = img.decodePng(
    File('../assets/images/hadoo-mark.png').readAsBytesSync(),
  )!;
  for (final p in input) {
    final minimum = [
      p.r.toInt(),
      p.g.toInt(),
      p.b.toInt(),
    ].reduce((a, b) => a < b ? a : b);
    final maximum = [
      p.r.toInt(),
      p.g.toInt(),
      p.b.toInt(),
    ].reduce((a, b) => a > b ? a : b);
    if (maximum - minimum < 22 && minimum > 220)
      p.a = (p.a * ((248 - minimum).clamp(0, 28)) / 28).round();
  }
  img.Image icon(int size, {bool transparent = false, bool mono = false}) {
    final out = img.Image(width: size, height: size, numChannels: 4);
    if (!transparent) img.fill(out, color: img.ColorRgba8(7, 11, 9, 255));
    final mark = img.copyResize(
      input,
      width: (size * .9).round(),
      interpolation: img.Interpolation.average,
    );
    if (mono) {
      for (final p in mark) {
        p.r = 255;
        p.g = 255;
        p.b = 255;
      }
    }
    img.compositeImage(
      out,
      mark,
      dstX: (size - mark.width) ~/ 2,
      dstY: (size - mark.height) ~/ 2,
    );
    return out;
  }

  void save(String path, img.Image image) =>
      File(path).writeAsBytesSync(img.encodePng(image));
  save('assets/branding/hadoo-mark.png', icon(512, transparent: true));
  // Cover every alternate alias, so theme changes retain Hadoo's identity.
  for (final file in Directory(
    'android/app/src/main/res',
  ).listSync(recursive: true).whereType<File>()) {
    if (!file.path.endsWith('.png')) continue;
    final name = file.uri.pathSegments.last;
    if (name.startsWith('ic_lokal_') ||
        name.contains('launcher') ||
        name == 'ic_notification.png') {
      final old = img.decodePng(file.readAsBytesSync());
      if (old != null)
        save(
          file.path,
          icon(
            old.width,
            transparent:
                name.contains('foreground') ||
                name.contains('_fg_') ||
                name.contains('monochrome') ||
                name == 'ic_notification.png',
            mono:
                name.contains('_mono') ||
                name.contains('monochrome') ||
                name == 'ic_notification.png',
          ),
        );
    }
  }
  for (final file in Directory(
    'ios/Runner/Assets.xcassets',
  ).listSync(recursive: true).whereType<File>()) {
    if (!file.path.endsWith('.png') || !file.path.contains('.appiconset/'))
      continue;
    final old = img.decodePng(file.readAsBytesSync());
    if (old != null) save(file.path, icon(old.width).convert(numChannels: 3));
  }
}
