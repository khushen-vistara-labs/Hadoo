import 'dart:async';

import 'package:flutter/foundation.dart';

import 'discovery_http.dart';
import 'discovery_models.dart';
import 'discovery_registry.dart';
import 'discovery_settings.dart';
import 'discovery_sources.dart';

class DiscoverySearchResults {
  const DiscoverySearchResults({
    this.tracks = const [],
    this.errors = const [],
  });

  final List<DiscoveryTrack> tracks;
  final List<String> errors;
}

Future<DiscoverySearchResults> searchDiscovery(
  DiscoveryHttp http,
  DiscoverySettings settings,
  String query,
) async {
  final registry = DiscoverySourceRegistry(http, settings);
  final jobs = <Future<DiscoverySearchResults>>[];
  Future<DiscoverySearchResults> run(
    String name,
    Future<List<DiscoveryTrack>> Function() search,
  ) async {
    try {
      return DiscoverySearchResults(tracks: await search());
    } catch (error) {
      return DiscoverySearchResults(
        errors: ['$name: ${discoveryError(error)}'],
      );
    }
  }

  for (final addon in registry.addons) {
    jobs.add(run(addon.displayName, () => addon.search(query)));
  }
  if (settings.youtubeEnabled) {
    jobs.add(
      run('YouTube Music', () => YoutubeMusicCatalog(http).search(query)),
    );
  }
  final results = await Future.wait(jobs);
  return DiscoverySearchResults(
    tracks: results.expand((r) => r.tracks).toList(growable: false),
    errors: results.expand((r) => r.errors).toList(growable: false),
  );
}

/// Retained as a transport seam for addon protocol tests and non-UI callers.
/// The app's user-facing search is [SearchScreen], not this controller.
class DiscoveryController extends ChangeNotifier {
  DiscoveryController({
    required this._search,
    this.debounce = const Duration(milliseconds: 400),
  });

  Future<DiscoverySearchResults> Function(String) _search;
  final Duration debounce;
  Timer? _timer;
  int _generation = 0;
  bool _disposed = false;
  String query = '';
  bool loading = false;
  DiscoverySearchResults results = const DiscoverySearchResults();

  void configure(Future<DiscoverySearchResults> Function(String) search) {
    _search = search;
    updateQuery(query);
  }

  void updateQuery(String value, {bool immediate = false}) {
    if (_disposed) return;
    query = value.trim();
    final generation = ++_generation;
    _timer?.cancel();
    results = const DiscoverySearchResults();
    loading = query.isNotEmpty;
    if (query.length > 200) {
      loading = false;
      results = const DiscoverySearchResults(
        errors: ['Search is limited to 200 characters.'],
      );
    } else if (loading) {
      if (immediate) {
        unawaited(_run(query, generation));
      } else {
        _timer = Timer(debounce, () => _run(query, generation));
      }
    }
    notifyListeners();
  }

  Future<void> _run(String value, int generation) async {
    DiscoverySearchResults next;
    try {
      next = await _search(value);
    } catch (error) {
      next = DiscoverySearchResults(errors: [discoveryError(error)]);
    }
    if (_disposed || generation != _generation) return;
    results = next;
    loading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _generation++;
    _timer?.cancel();
    super.dispose();
  }
}
