import 'package:flick/features/discovery/youtube_music_sign_in.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('uses BitChord’s first-party YouTube Music ServiceLogin URL', () {
    final uri = youtubeMusicSignInUri();

    expect(uri.scheme, 'https');
    expect(uri.host, 'accounts.google.com');
    expect(uri.path, '/ServiceLogin');
    expect(uri.queryParameters, {
      'ltmpl': 'music',
      'service': 'youtube',
      'passive': 'true',
      'continue': 'https://music.youtube.com/',
    });
  });
}
