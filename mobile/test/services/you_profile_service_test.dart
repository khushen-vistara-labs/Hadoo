import 'dart:io';
import 'dart:typed_data';

import 'package:flick/services/you_profile_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory avatars;
  late YouProfileService service;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    avatars = await Directory.systemTemp.createTemp('lokal-you-profile-');
    service = YouProfileService(avatarDirectory: avatars);
  });
  tearDown(() async {
    if (await avatars.exists()) await avatars.delete(recursive: true);
  });

  test('username survives a new service and clearing restores default', () async {
    expect((await service.load()).username, isNull);
    await service.save(username: '  Cheickna  ');
    expect((await YouProfileService(avatarDirectory: avatars).load()).username,
        'Cheickna');
    await service.save(username: '');
    expect((await service.load()).username, isNull);
  });

  test('invalid input is rejected without losing the current profile', () async {
    await service.save(username: 'Owner');
    await expectLater(
      service.save(username: List.filled(41, 'A').join()), throwsFormatException,
    );
    await expectLater(
      service.save(username: 'bad\u0000name'), throwsFormatException,
    );
    expect((await service.load()).username, 'Owner');
  });

  test('picked photo is cropped, bounded, copied and can be reset', () async {
    Uint8List testImage(int width, int height) {
      final source = img.Image(width: width, height: height);
      img.fill(source, color: img.ColorRgb8(128, 60, 180));
      return Uint8List.fromList(img.encodePng(source));
    }

    final first = await service.save(
      username: 'Owner',
      avatarBytes: testImage(720, 480),
    );
    final firstPath = first.avatarPath!;
    expect(await File(firstPath).exists(), isTrue);
    final firstJpeg = img.decodeJpg(await File(firstPath).readAsBytes())!;
    expect(firstJpeg.width, 320);
    expect(firstJpeg.height, 320);
    expect((await YouProfileService(avatarDirectory: avatars).load()).avatarPath,
        firstPath);

    final second = await service.save(
      username: 'Owner',
      avatarBytes: testImage(400, 600),
    );
    expect(second.avatarPath, isNot(firstPath));
    expect(await File(firstPath).exists(), isFalse);
    expect(await File(second.avatarPath!).exists(), isTrue);

    final reset = await service.save(username: '', removeAvatar: true);
    expect(reset.avatarPath, isNull);
    expect(await File(second.avatarPath!).exists(), isFalse);
    expect((await service.load()).username, isNull);
  });

  test('rejects non-images and excessive image files', () async {
    await expectLater(
      service.save(username: 'Owner', avatarBytes: Uint8List.fromList([1, 2, 3])),
      throwsFormatException,
    );
    await expectLater(
      service.save(username: 'Owner', avatarBytes: Uint8List(12 * 1024 * 1024 + 1)),
      throwsFormatException,
    );
    expect((await service.load()).avatarPath, isNull);
  });
}
