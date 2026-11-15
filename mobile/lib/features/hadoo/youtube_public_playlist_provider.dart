import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flick/features/discovery/discovery_http.dart';
import 'package:flick/features/discovery/discovery_sources.dart';
import 'package:flick/features/discovery/youtube_music_account.dart';
import 'package:flick/features/konnekted/konnekted_discovery.dart';
import 'package:flick/services/graceful_http_client.dart';

/// Search opens public playlists without creating a local list or requiring
/// sign-in. Signed-in browsing uses the same account as the YouTube library.
final youtubePublicPlaylistDetailsProvider = FutureProvider.autoDispose
    .family<YoutubeMusicPlaylistDetails, String>((ref, id) async {
      final account = ref.watch(konnektedYoutubeMusicAccountProvider);
      if (account != null) return account.libraryPlaylistDetails(id);
      final client = GracefulHttpClient();
      ref.onDispose(client.close);
      return PublicYoutubePlaylistReader(
        YoutubeMusicCatalog(DiscoveryHttp(client)),
      ).libraryPlaylistDetails(id);
    });

/// Reuses the scoped playlist parser and pagination without granting guest
/// access to account endpoints or exposing any playlist mutation in Search.
class PublicYoutubePlaylistReader extends YoutubeMusicAccount {
  PublicYoutubePlaylistReader(this.catalog)
    : super(catalog.http.client, const YoutubeMusicSession(cookies: {}));
  final YoutubeMusicCatalog catalog;

  @override
  Future<Map<String, dynamic>> browse(
    String browseId, {
    String? params,
    String? continuation,
    Duration? timeout,
    DateTime? deadline,
  }) => catalog
      .rawBrowse(browseId, params: params, continuation: continuation)
      .timeout(timeout ?? this.timeout);
}
