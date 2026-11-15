import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

class PlaylistLinkCancellationToken {
  final Completer<void> _cancelled = Completer<void>();

  bool get isCancelled => _cancelled.isCompleted;
  Future<void> get future => _cancelled.future;

  void cancel() {
    if (!_cancelled.isCompleted) _cancelled.complete();
  }

  void throwIfCancelled() {
    if (isCancelled) throw const PlaylistLinkCancelledException();
  }
}

class PlaylistLinkCancelledException implements Exception {
  const PlaylistLinkCancelledException();

  @override
  String toString() => 'Playlist link operation cancelled.';
}

class PlaylistLinkHttpException implements Exception {
  final String message;

  const PlaylistLinkHttpException(this.message);

  @override
  String toString() => message;
}

class PlaylistLinkHttpResponse {
  final int statusCode;
  final String body;

  const PlaylistLinkHttpResponse({
    required this.statusCode,
    required this.body,
  });
}

abstract interface class PlaylistLinkTransport {
  Future<PlaylistLinkHttpResponse> request(
    String method,
    Uri url, {
    Map<String, String> headers,
    String? body,
    required int maxBytes,
    required Duration timeout,
    PlaylistLinkCancellationToken? cancellation,
  });

  void close() {}
}

/// Redirect-free, bounded transport for public playlist pages. The importer
/// never accepts a response beyond its cap, even when a server omits a length.
class BoundedPlaylistLinkTransport implements PlaylistLinkTransport {
  final http.Client client;
  final bool closeClient;

  BoundedPlaylistLinkTransport({http.Client? client, this.closeClient = true})
    : client = client ?? http.Client();

  @override
  Future<PlaylistLinkHttpResponse> request(
    String method,
    Uri url, {
    Map<String, String> headers = const {},
    String? body,
    required int maxBytes,
    required Duration timeout,
    PlaylistLinkCancellationToken? cancellation,
  }) async {
    if (url.scheme.toLowerCase() != 'https') {
      throw const PlaylistLinkHttpException('Playlist sources must use HTTPS.');
    }

    final abort = Completer<void>();
    var timedOut = false;
    var cancelled = false;
    final timer = Timer(timeout, () {
      timedOut = true;
      if (!abort.isCompleted) abort.complete();
    });
    if (cancellation != null) {
      unawaited(
        cancellation.future.then((_) {
          cancelled = true;
          if (!abort.isCompleted) abort.complete();
        }),
      );
    }

    final request = http.AbortableRequest(
      method,
      url,
      abortTrigger: abort.future,
    )..followRedirects = false;
    request.headers.addAll(headers);
    if (body != null) {
      request.headers['Content-Type'] = 'application/json';
      request.body = body;
    }

    StreamIterator<List<int>>? chunks;
    try {
      cancellation?.throwIfCancelled();
      final pending = client.send(request).then((response) {
        if (abort.isCompleted) {
          unawaited(response.stream.listen(null).cancel());
          throw const PlaylistLinkHttpException('Playlist request cancelled.');
        }
        return response;
      });
      final response = await Future.any([
        pending,
        abort.future.then<http.StreamedResponse>(
          (_) => throw const PlaylistLinkHttpException(
            'Playlist request cancelled.',
          ),
        ),
      ]);
      chunks = StreamIterator(response.stream);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw PlaylistLinkHttpException(
          response.statusCode == 404
              ? 'The public playlist was not found.'
              : 'The playlist source returned HTTP ${response.statusCode}.',
        );
      }
      if ((response.contentLength ?? 0) > maxBytes) {
        throw const PlaylistLinkHttpException(
          'The playlist response is too large.',
        );
      }

      final bytes = BytesBuilder(copy: false);
      var received = 0;
      while (await Future.any([
        chunks.moveNext(),
        abort.future.then<bool>(
          (_) => throw const PlaylistLinkHttpException(
            'Playlist request cancelled.',
          ),
        ),
      ])) {
        final chunk = chunks.current;
        received += chunk.length;
        if (received > maxBytes) {
          throw const PlaylistLinkHttpException(
            'The playlist response is too large.',
          );
        }
        bytes.add(chunk);
      }
      if (received == 0 ||
          (response.contentLength != null &&
              received != response.contentLength)) {
        throw const PlaylistLinkHttpException(
          'The playlist response was incomplete.',
        );
      }
      return PlaylistLinkHttpResponse(
        statusCode: response.statusCode,
        body: utf8.decode(bytes.takeBytes()),
      );
    } catch (error) {
      if (timedOut) {
        throw const PlaylistLinkHttpException('The playlist source timed out.');
      }
      if (cancelled || cancellation?.isCancelled == true) {
        throw const PlaylistLinkCancelledException();
      }
      if (error is PlaylistLinkCancelledException ||
          error is PlaylistLinkHttpException) {
        rethrow;
      }
      throw const PlaylistLinkHttpException(
        'Could not reach the playlist source.',
      );
    } finally {
      timer.cancel();
      if (!abort.isCompleted) abort.complete();
      await chunks?.cancel();
    }
  }

  @override
  void close() {
    if (closeClient) client.close();
  }
}

Map<String, dynamic> decodePlaylistJson(String body) {
  try {
    final value = jsonDecode(body);
    if (value is Map<String, dynamic>) return value;
  } on FormatException {
    // The importer exposes a stable, non-sensitive parse error below.
  }
  throw const PlaylistLinkHttpException(
    'The playlist source returned invalid JSON.',
  );
}
