import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flick/core/theme/lokal_theme.dart';
import 'package:flick/core/theme/lokal_tokens.dart';
import 'package:flick/features/konnekted/konnekted_destination.dart';
import 'package:flick/features/search/widgets/online_search_section.dart';
import 'package:flick/features/settings/lokal/lokal_settings_group.dart';
import 'package:flick/features/konnekted/konnekted_discovery_view.dart';
import 'package:flick/models/song.dart';

import 'hadoo_header.dart';

/// Hadoo's primary experience: query the online music source and play its
/// actual results. Local-file import and desktop pairing live in Settings.
class HadooStreamingHome extends StatefulWidget {
  const HadooStreamingHome({
    super.key,
    required this.onNavigate,
    this.focusRequests,
    this.resultsBuilder,
    required this.onPlay,
  });

  final ValueChanged<KonnektedDestination> onNavigate;
  final void Function(Song song, List<Song> queue) onPlay;
  final ValueListenable<int>? focusRequests;
  @visibleForTesting
  final Widget Function(String query)? resultsBuilder;

  @override
  State<HadooStreamingHome> createState() => _HadooStreamingHomeState();
}

class _HadooStreamingHomeState extends State<HadooStreamingHome> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  Timer? _debounce;
  String _query = '';

  @override
  void initState() {
    super.initState();
    widget.focusRequests?.addListener(_requestFocus);
    if (widget.focusRequests != null) _requestFocus();
  }

  void _requestFocus() => WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!mounted) return;
    _focus.requestFocus();
    _focus.context
        ?.findAncestorStateOfType<EditableTextState>()
        ?.requestKeyboard();
  });

  @override
  void didUpdateWidget(covariant HadooStreamingHome oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusRequests != widget.focusRequests) {
      oldWidget.focusRequests?.removeListener(_requestFocus);
      widget.focusRequests?.addListener(_requestFocus);
    }
  }

  void _search(String value) {
    _debounce?.cancel();
    final query = value.trim();
    if (_query != query) setState(() => _query = query);
  }

  @override
  void dispose() {
    widget.focusRequests?.removeListener(_requestFocus);
    _debounce?.cancel();
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.lokal;
    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: [
          SliverToBoxAdapter(
            child: HadooHeader(
              onSearch: _requestFocus,
              onDownloads: () =>
                  widget.onNavigate(KonnektedDestination.downloads),
              onSettings: () =>
                  widget.onNavigate(KonnektedDestination.settings),
              onAppearance: () => widget.onNavigate(
                const KonnektedDestination.settingsAt(
                  LokalSettingsGroup.themeAccent,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'STREAM // YOUTUBE MUSIC',
                    style: LokalTheme.label(t, color: t.accent),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    key: const ValueKey('hadoo-stream-search'),
                    controller: _controller,
                    focusNode: _focus,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Search YouTube Music',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        tooltip: 'Clear search',
                        onPressed: () {
                          _controller.clear();
                          _search('');
                        },
                        icon: const Icon(Icons.close),
                      ),
                      filled: true,
                      fillColor: t.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    onChanged: (value) {
                      _debounce?.cancel();
                      _debounce = Timer(
                        const Duration(milliseconds: 350),
                        () => _search(value),
                      );
                    },
                    onSubmitted: _search,
                  ),
                  if (_query.isEmpty && widget.focusRequests != null) ...[
                    const SizedBox(height: 24),
                    Text(
                      'Find something worth replaying.',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Search songs, videos and playlists, stream from YouTube Music, or save a track for offline listening.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final query in [
                          'Lo-fi',
                          'Electronic',
                          'Indie',
                          'Workout',
                        ])
                          OutlinedButton(
                            onPressed: () {
                              _controller.text = query;
                              _search(query);
                              _focus.unfocus();
                            },
                            child: Text(query),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (_query.isEmpty && widget.focusRequests == null) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: OutlinedButton.icon(
                  onPressed: () =>
                      widget.onNavigate(KonnektedDestination.playlists),
                  icon: const Icon(Icons.queue_music),
                  label: const Text('Your YouTube playlists'),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: KonnektedDiscoveryView(
                youtubeOnly: true,
                onNavigate: widget.onNavigate,
                onPlay: widget.onPlay,
              ),
            ),
          ],
          if (_query.isNotEmpty)
            widget.resultsBuilder?.call(_query) ??
                OnlineSearchSection(query: _query),
          const SliverToBoxAdapter(child: SizedBox(height: 200)),
        ],
      ),
    );
  }
}
