import 'package:flutter/material.dart';

import 'domain/flow_models.dart';

class FlowTunerSheet extends StatefulWidget {
  const FlowTunerSheet({
    super.key,
    required this.config,
    required this.genres,
    required this.onApply,
    this.initialMood,
  });

  final FlowConfig config;
  final Iterable<String> genres;
  final FlowMood? initialMood;
  final Future<void> Function(FlowConfig) onApply;

  @override
  State<FlowTunerSheet> createState() => _FlowTunerSheetState();
}

class _FlowTunerSheetState extends State<FlowTunerSheet> {
  late final FlowTunerDraft _draft;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _draft = FlowTunerDraft(widget.config);
    if (widget.initialMood != null) {
      _draft.value = _draft.value.copyWith(mood: widget.initialMood);
    }
  }

  Future<void> _apply() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.onApply(_draft.apply());
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = '$error';
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final genres = {...widget.genres, ..._draft.value.excludedGenres}.toList()
      ..sort();
    final config = _draft.value;
    return PopScope(
      canPop: !_saving,
      child: FractionallySizedBox(
        heightFactor: .92,
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tune your Flow',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'These are draft settings. Apply rebuilds your mix; '
                        'Cancel or dismiss keeps your current settings. Audio changes only when you press Play.',
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Mood',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Wrap(
                        spacing: 8,
                        children: [
                          for (final mood in FlowMood.values)
                            ChoiceChip(
                              label: Text(mood.label),
                              selected: config.mood == mood,
                              onSelected: _saving
                                  ? null
                                  : (_) => setState(() {
                                      _draft.value = config.copyWith(
                                        mood: mood,
                                      );
                                    }),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Discovery · ${(config.discovery * 100).round()}%',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Slider(
                        key: const Key('flow-discovery'),
                        value: config.discovery,
                        divisions: 100,
                        label: '${(config.discovery * 100).round()}%',
                        semanticFormatterCallback: (value) =>
                            '${(value * 100).round()} percent discovery',
                        onChanged: _saving
                            ? null
                            : (value) => setState(() {
                                _draft.value = config.copyWith(
                                  discovery: value,
                                );
                              }),
                      ),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [Text('Personal'), Text('Adventurous')],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Up to 15%: only likes and listening history. '
                        'From 85%: only unfamiliar tracks in your local library.',
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Memory · ${(config.memory * 100).round()}%',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Slider(
                        key: const Key('flow-memory'),
                        value: config.memory,
                        divisions: 100,
                        label: '${(config.memory * 100).round()}%',
                        semanticFormatterCallback: (value) =>
                            '${(value * 100).round()} percent recent memory',
                        onChanged: _saving
                            ? null
                            : (value) => setState(() {
                                _draft.value = config.copyWith(memory: value);
                              }),
                      ),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('All-time likes'),
                          Text('Recent plays'),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Included genres',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const Text(
                        'Turn a genre off to exclude it. Mood boosts use the genre tags in your files.',
                      ),
                      if (genres.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 12),
                          child: Text('No genre tags found in this library.'),
                        ),
                      Wrap(
                        spacing: 8,
                        children: [
                          for (final genre in genres)
                            FilterChip(
                              key: ValueKey('flow-genre-$genre'),
                              label: Text(genre),
                              selected: !config.excludedGenres.contains(genre),
                              onSelected: _saving
                                  ? null
                                  : (enabled) => setState(() {
                                      _draft.setGenreEnabled(genre, enabled);
                                    }),
                            ),
                        ],
                      ),
                      if (_error != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Text(
                            _error!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    TextButton(
                      onPressed: _saving
                          ? null
                          : () {
                              _draft.cancel();
                              Navigator.of(context).pop();
                            },
                      child: const Text('Cancel'),
                    ),
                    const Spacer(),
                    FilledButton(
                      key: const Key('flow-apply'),
                      onPressed: _saving || !_draft.isDirty ? null : _apply,
                      child: Text(_saving ? 'Applying…' : 'Apply'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
