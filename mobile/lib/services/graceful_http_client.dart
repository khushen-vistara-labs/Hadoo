import 'dart:io';

import 'package:http/io_client.dart';

/// Avoid force-clearing Dart's connection pool while a consumed response is
/// returning its socket. Active work has its own request/stream timeouts.
class GracefulHttpClient extends IOClient {
  GracefulHttpClient()
    : this._(HttpClient()..connectionTimeout = const Duration(seconds: 15));
  GracefulHttpClient._(this._transport) : super(_transport);
  final HttpClient _transport;
  @override
  void close() => _transport.close();
}
