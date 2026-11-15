import 'package:flick/services/link/link_download_outbox.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('organization relocates existing pending copies without enqueueing other songs', () async {
    SharedPreferences.setMockInitialValues({
      'lokal.link.pc.download_outbox': ['/old/song.flac', '/other.flac'],
      'lokal.link.second.download_outbox': ['/untouched.flac'],
    });
    await LinkDownloadOutbox.relocate(
      '/old/song.flac',
      '/Artist/Album/song.flac',
    );
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList('lokal.link.pc.download_outbox'), [
      '/Artist/Album/song.flac',
      '/other.flac',
    ]);
    expect(prefs.getStringList('lokal.link.second.download_outbox'), [
      '/untouched.flac',
    ]);
  });
}
