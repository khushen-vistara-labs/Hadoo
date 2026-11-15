import 'package:flick/providers/playlist_provider.dart';
import 'package:flick/services/playlist_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('newly created playlist appears in the watched list without re-entry', () async {
    SharedPreferences.setMockInitialValues({});
    final service = PlaylistService();
    final container = ProviderContainer(overrides: [
      playlistServiceProvider.overrideWithValue(service),
    ]);
    addTearDown(container.dispose);
    final subscription = container.listen(playlistsProvider, (_, _) {});
    addTearDown(subscription.close);
    await container.read(playlistsProvider.future);
    expect(container.read(playlistsProvider).requireValue.playlists, isEmpty);

    final playlist = await container.read(playlistsProvider.notifier)
        .createPlaylist('Immediate');
    expect(playlist, isNotNull);
    expect(
      container.read(playlistsProvider).requireValue.playlists
          .map((p) => p.name),
      ['Immediate'],
    );
  });

  test('linked playlist creation invalidation refreshes an active list', () async {
    SharedPreferences.setMockInitialValues({});
    final service = PlaylistService();
    final container = ProviderContainer(overrides: [
      playlistServiceProvider.overrideWithValue(service),
    ]);
    addTearDown(container.dispose);
    final subscription = container.listen(playlistsProvider, (_, _) {});
    addTearDown(subscription.close);
    await container.read(playlistsProvider.future);

    // Linked Playlist backend creates directly through the shared service.
    await service.createPlaylist('Linked');
    container.invalidate(playlistsProvider);
    await container.read(playlistsProvider.future);
    expect(container.read(playlistsProvider).requireValue.playlists
        .single.name, 'Linked');
  });
}
