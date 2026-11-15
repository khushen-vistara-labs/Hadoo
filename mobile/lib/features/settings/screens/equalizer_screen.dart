import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flick/widgets/lokal/lokal_toast.dart';
import 'package:flick/widgets/lokal/lokal_choice_sheet.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:path_provider/path_provider.dart';

import 'package:flick/core/constants/app_constants.dart';
import 'package:flick/core/theme/lokal_theme.dart';
import 'package:flick/core/theme/lokal_tokens.dart';
import 'package:flick/core/utils/responsive.dart';
import 'package:flick/providers/equalizer_provider.dart';
import 'package:flick/services/eq_preset_file_service.dart';
import 'package:flick/services/eq_preset_service.dart';
import 'package:flick/services/equalizer_service.dart';
import 'package:flick/features/settings/screens/widgets/autoeq_search_sheet.dart';
import 'package:flick/widgets/common/rotary_knob.dart';
import 'package:flick/widgets/lokal/settings/lokal_settings_kit.dart';

import 'package:flick/widgets/equalizer/parametric_eq_graph.dart';
import 'package:flick/widgets/equalizer/graphic_eq_graph.dart';
import 'package:flick/widgets/equalizer/interactive_eq_graph.dart';
import 'package:flick/l10n/l10n.dart';

enum _PresetFileFormat { json, txt }

/// Which part of the presets sheet is shown: the presets to apply, or
/// importing and exporting preset files.
enum _PresetsView { library, files }

/// The equalizer: on the page itself the band EQ, presets and AutoEQ; the
/// parametric EQ, tone, dynamics, FX, balance, convolver and preset files
/// under a collapsible Advanced section on the same page.
class EqualizerScreen extends ConsumerStatefulWidget {
  const EqualizerScreen({super.key});

  @override
  ConsumerState<EqualizerScreen> createState() => _EqualizerScreenState();
}

class _EqualizerScreenState extends ConsumerState<EqualizerScreen> {
  final _scrollController = ScrollController();
  final _graphicGraphKey = GlobalKey();
  final _parametricGraphKey = GlobalKey();
  final _advancedKey = GlobalKey();
  bool _advancedOpen = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showPresets([_PresetsView view = _PresetsView.library]) {
    showLokalSettingsSheet<void>(
      context: context,
      title: view == _PresetsView.library ? l10n.presets : 'Preset files',
      isScrollControlled: true,
      builder: (sheet) => ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(sheet).height * 0.75,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _PresetsSheet(view: view),
        ),
      ),
    );
  }

  Future<void> _openAutoEq() async {
    final entry = await showAutoEqSearchSheet(context);
    if (entry == null || !mounted) return;
    ref
        .read(equalizerProvider.notifier)
        .applyPreset(
          presetName: entry.displayName,
          enabled: true,
          mode: EqMode.parametric,
          preampDb: entry.preampDb,
          graphicGainsDb: List<double>.filled(10, 0.0, growable: false),
          parametricBands: entry.bands,
        );
    LokalToast.fromSnackBar(context, 
        SnackBar(
          content: Text(l10n.appliedAutoeqFor(entry.displayName)),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  /// Opens Advanced and brings it into view, e.g. to edit parametric bands.
  void _openAdvanced() {
    setState(() => _advancedOpen = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final target = _advancedKey.currentContext;
      if (target != null && target.mounted) {
        Scrollable.ensureVisible(
          target,
          duration: AppConstants.animationNormal,
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final activePresetName = ref.watch(eqActivePresetNameProvider);
    final enabled = ref.watch(eqEnabledProvider);
    final mode = ref.watch(eqModeProvider);

    return LokalSettingsScaffold(
      controller: _scrollController,
      title: l10n.equalizer,
      subtitle: activePresetName != null
          ? l10n.preset(activePresetName)
          : 'Shape the sound with the band EQ, a preset or your '
                "headphones' AutoEQ profile.",
      actions: [
        LokalSettingsHeaderAction(
          icon: Icons.library_music_rounded,
          tooltip: l10n.presets,
          onPressed: _showPresets,
        ),
      ],
      children: [
        LokalSettingsBlock(
          top: 16,
          child: _GlassCard(
            child: Column(
              children: [
                _TopControlsRow(enabled: enabled),
                _Divider(),
                _PreampRow(enabled: enabled),
              ],
            ),
          ),
        ),
        LokalSettingsSection(
          title: l10n.presets,
          children: [
            LokalSettingLink(
              label: 'Browse presets',
              description: 'Built-in curves, your own, and saving this one.',
              value: activePresetName,
              onTap: _showPresets,
            ),
            LokalSettingLink(
              label: l10n.autoeqHeadphones,
              description: l10n.matchEqToYourHeadphoneModel,
              onTap: _openAutoEq,
            ),
          ],
        ),
        LokalSettingsBlock(
          child: mode == EqMode.graphic
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _GraphicEqView(graphKey: _graphicGraphKey),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () =>
                            ref.read(equalizerProvider.notifier).resetGraphic(),
                        icon: const Icon(LucideIcons.rotateCcw, size: 16),
                        label: Text(l10n.reset),
                        style: TextButton.styleFrom(
                          foregroundColor: context.lokal.muted,
                        ),
                      ),
                    ),
                  ],
                )
              : _ParametricActiveCard(
                  onEdit: _openAdvanced,
                  onUseBandEq: () => ref
                      .read(equalizerProvider.notifier)
                      .setMode(EqMode.graphic),
                ),
        ),
        LokalSettingsBlock(
          key: _advancedKey,
          child: _AdvancedHeader(
            open: _advancedOpen,
            onTap: () => setState(() => _advancedOpen = !_advancedOpen),
          ),
        ),
        if (_advancedOpen) ...[
          LokalSettingsBlock(
            top: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SectionHeader(title: 'EQ type'),
                _GlassCard(child: _ModeAndActionsRow(mode: mode)),
                if (mode == EqMode.parametric) ...[
                  const SizedBox(height: AppConstants.spacingLg),
                  _ParametricEqView(graphKey: _parametricGraphKey),
                ],
              ],
            ),
          ),
          LokalSettingsBlock(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SectionHeader(title: 'Tone'),
                _BmtKnobsRow(enabled: enabled),
              ],
            ),
          ),
          const LokalSettingsBlock(child: _DynamicsSection()),
          const LokalSettingsBlock(child: _CreativeFxSection()),
          LokalSettingsSection(
            title: 'Preset files',
            children: [
              LokalSettingLink(
                label: 'Import or export',
                description:
                    '${l10n.loadAJsonOrTxtPreset} '
                    '${l10n.saveTheCurrentEqAsJson}',
                onTap: () => _showPresets(_PresetsView.files),
              ),
            ],
          ),
        ],
        const SizedBox(height: 96),
      ],
    );
  }
}

/// Shown where the band EQ goes while the parametric EQ is in use (after
/// AutoEQ or a parametric preset).
class _ParametricActiveCard extends ConsumerWidget {
  const _ParametricActiveCard({
    required this.onEdit,
    required this.onUseBandEq,
  });

  final VoidCallback onEdit;
  final VoidCallback onUseBandEq;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.lokal;
    final active = ref
        .watch(equalizerProvider.select((s) => s.parametricBands))
        .where((band) => band.enabled)
        .length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(title: l10n.parametricEq),
        LokalSettingsCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LokalStatusPill(label: l10n.activeBands(active), active: true),
              const SizedBox(height: 10),
              Text(
                'The parametric EQ is shaping the sound, from AutoEQ or a '
                'parametric preset. Edit its bands under Advanced, or go '
                'back to the band EQ.',
                style: TextStyle(
                  fontFamily: LokalTheme.sans,
                  fontSize: 13,
                  height: 1.4,
                  color: t.muted,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: LokalSettingsActionButton(
                      label: 'Edit bands',
                      onPressed: onEdit,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: LokalSettingsActionButton(
                      label: 'Use band EQ',
                      primary: false,
                      onPressed: onUseBandEq,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// The Advanced section's header: tap to show or hide everything below.
class _AdvancedHeader extends StatelessWidget {
  const _AdvancedHeader({required this.open, required this.onTap});

  final bool open;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.lokal;
    return Semantics(
      button: true,
      expanded: open,
      child: LokalSettingsCard(
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(Icons.tune_rounded, color: t.accent, size: 22),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.advanced,
                        style: TextStyle(
                          fontFamily: LokalTheme.sans,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: t.text,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Parametric EQ, tone, compressor, limiter, balance, '
                        'FX, convolver and preset files.',
                        style: TextStyle(
                          fontFamily: LokalTheme.sans,
                          fontSize: 12.5,
                          height: 1.35,
                          color: t.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedRotation(
                  turns: open ? .5 : 0,
                  duration: AppConstants.animationFast,
                  child: Icon(Icons.expand_more_rounded, color: t.muted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LabeledKnob extends StatelessWidget {
  final IconData icon;
  final String label;
  final String valueLabel;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double>? onChanged;
  final VoidCallback? onReset;

  const _LabeledKnob({
    required this.icon,
    required this.label,
    required this.valueLabel,
    required this.value,
    this.min = 0.0,
    this.max = 1.0,
    required this.onChanged,
    this.onReset,
  });

  static const double _knobSize = 80;

  @override
  Widget build(BuildContext context) {
    final enabled = onChanged != null;
    return SizedBox(
      width: _knobSize + 28,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: context.responsiveIcon(AppConstants.iconSizeSm),
                color: enabled ? context.lokal.muted : context.lokal.muted2,
              ),
              const SizedBox(width: AppConstants.spacingXs),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: enabled ? context.lokal.muted : context.lokal.muted2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingSm),
          Tooltip(
            message: enabled ? l10n.doubleTapToReset : l10n.enableEqToEdit,
            child: RotaryKnob(
              value: value,
              min: min,
              max: max,
              size: _knobSize,
              onChanged: onChanged,
              onDoubleTap: onReset,
              label: label,
              accentColor: enabled ? context.lokal.text : context.lokal.muted2,
            ),
          ),
          const SizedBox(height: AppConstants.spacingXs),
          _ValueBadge(value: valueLabel),
        ],
      ),
    );
  }
}

class _PresetsSheet extends ConsumerStatefulWidget {
  const _PresetsSheet({this.view = _PresetsView.library});

  final _PresetsView view;

  @override
  ConsumerState<_PresetsSheet> createState() => _PresetsSheetState();
}

class _PresetsSheetState extends ConsumerState<_PresetsSheet> {
  final EqPresetService _service = EqPresetService();
  final EqPresetFileService _fileService = const EqPresetFileService();
  bool _loading = true;
  List<EqPreset> _custom = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final presets = await _service.loadCustomPresets();
    if (!mounted) return;
    setState(() {
      _custom = presets;
      _loading = false;
    });
  }

  Future<String?> _askForName(BuildContext context, {String? initial}) {
    return showLokalInputSheet(
      context: context,
      title: initial == null ? l10n.savePreset : l10n.renamePreset,
      hint: l10n.presetName,
      initialValue: initial ?? '',
      confirmLabel: l10n.save,
    );
  }

  EqPreset _currentAsPreset({required String id, required String name}) {
    final s = ref.read(equalizerProvider);
    return EqPreset(
      id: id,
      name: name,
      enabled: s.enabled,
      mode: s.mode,
      preampDb: s.preampDb,
      graphicGainsDb: List<double>.of(s.graphicGainsDb, growable: false),
      parametricBands: List<ParametricBand>.of(
        s.parametricBands,
        growable: false,
      ),
      compressor: s.compressor,
      limiter: s.limiter,
      fx: s.fx,
    );
  }

  Future<void> _apply(EqPreset preset) async {
    ref
        .read(equalizerProvider.notifier)
        .applyPreset(
          presetName: preset.name,
          enabled: preset.enabled,
          mode: preset.mode,
          preampDb: preset.preampDb,
          graphicGainsDb: preset.graphicGainsDb,
          parametricBands: preset.parametricBands,
          bassDb: preset.bassDb,
          midDb: preset.midDb,
          trebleDb: preset.trebleDb,
          compressor: preset.compressor,
          limiter: preset.limiter,
          fx: preset.fx,
        );
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _openAutoEqSheet() async {
    final entry = await showAutoEqSearchSheet(context);
    if (entry == null) return;
    ref
        .read(equalizerProvider.notifier)
        .applyPreset(
          presetName: entry.displayName,
          enabled: true,
          mode: EqMode.parametric,
          preampDb: entry.preampDb,
          graphicGainsDb: List<double>.filled(10, 0.0, growable: false),
          parametricBands: entry.bands,
        );
    if (mounted) {
      Navigator.of(context).pop();
      _showMessage(l10n.appliedAutoeqFor(entry.displayName));
    }
  }

  Future<void> _saveNewPreset() async {
    final name = await _askForName(context);
    if (name == null) return;
    final id = 'custom_${DateTime.now().millisecondsSinceEpoch}';
    final preset = _currentAsPreset(id: id, name: name);
    await _service.upsertCustomPreset(preset);
    await _load();
  }

  void _showMessage(String message) {
    if (!mounted) return;
    LokalToast.fromSnackBar(context, 
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }

  Future<void> _importPresetFile() async {
    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: const ['json', 'txt'],
      );
      if (file == null) return;

      final contents = utf8.decode(await file.readAsBytes());
      final imported = _fileService.parseFileText(
        text: contents,
        fileName: file.name,
      );
      final preset = imported.preset.copyWith(
        id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      );

      await _service.upsertCustomPreset(preset);
      await _load();
      ref
          .read(equalizerProvider.notifier)
          .applyPreset(
            presetName: preset.name,
            enabled: preset.enabled,
            mode: preset.mode,
            preampDb: preset.preampDb,
            graphicGainsDb: preset.graphicGainsDb,
            parametricBands: preset.parametricBands,
            bassDb: preset.bassDb,
            midDb: preset.midDb,
            trebleDb: preset.trebleDb,
            compressor: preset.compressor,
            limiter: preset.limiter,
            fx: preset.fx,
          );
      if (imported.hasWarnings) {
        await _showImportWarnings(preset.name, imported.warnings);
      } else {
        _showMessage(l10n.imported(preset.name));
      }
    } on FormatException catch (error) {
      _showMessage(error.message);
    } catch (_) {
      _showMessage(l10n.failedToImportPresetFile);
    }
  }

  Future<void> _showImportWarnings(
    String presetName,
    List<String> warnings,
  ) async {
    if (!mounted) return;
    await showLokalSettingsSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheet) => SingleChildScrollView(
        child: LokalSheetBody(
          title: l10n.presetImportedWithAdjustments,
          message: l10n.containsValuesOutsideTheSupportedRanges(presetName),
          children: [
            for (final warning in warnings)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  '• $warning',
                  style: TextStyle(
                    fontFamily: LokalTheme.sans,
                    fontSize: 13,
                    color: sheet.lokal.text,
                  ),
                ),
              ),
            const SizedBox(height: 12),
            LokalSettingsActionButton(
              label: 'OK',
              expand: true,
              onPressed: () => Navigator.of(sheet).pop(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportCurrentPreset() async {
    final format = await _askForExportFormat();
    if (format == null) return;

    final state = ref.read(equalizerProvider);
    final preset = _currentAsPreset(
      id: 'export_${DateTime.now().millisecondsSinceEpoch}',
      name: state.activePresetName ?? 'equalizer_preset',
    );

    final extension = format == _PresetFileFormat.json ? 'json' : 'txt';
    final contents = format == _PresetFileFormat.json
        ? _fileService.toJsonText(preset)
        : _fileService.toTxtText(preset);
    final bytes = Uint8List.fromList(utf8.encode(contents));
    final suggestedName = '${_safeFileName(preset.name)}.$extension';

    try {
      final savedUri = await FilePicker.saveFile(
        dialogTitle: l10n.exportEqualizerPreset,
        fileName: suggestedName,
        mimeType: format == _PresetFileFormat.json
            ? 'application/json'
            : 'text/plain',
        type: FileType.custom,
        allowedExtensions: [extension],
        bytes: bytes,
      );
      if (savedUri == null) {
        if (kIsWeb) {
          _showMessage(l10n.startedPresetDownload);
        }
        return;
      }

      final displayPath = savedUri.scheme == 'file' || savedUri.scheme.isEmpty
          ? savedUri.toFilePath()
          : savedUri.toString();
      _showMessage(l10n.exportedPresetTo(displayPath));
    } catch (_) {
      final fallbackPath = await _savePresetFallback(
        fileName: suggestedName,
        contents: contents,
      );
      _showMessage(l10n.exportedPresetTo2(fallbackPath));
    }
  }

  Future<_PresetFileFormat?> _askForExportFormat() async {
    return showLokalSettingsSheet<_PresetFileFormat>(
      context: context,
      title: l10n.exportFormat,
      builder: (sheet) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LokalSheetOption(
            label: 'JSON',
            description: 'Hadoo preset format',
            onTap: () => Navigator.of(sheet).pop(_PresetFileFormat.json),
          ),
          LokalSheetOption(
            label: 'TXT',
            description: l10n.compatibleWithPowerampEq,
            onTap: () => Navigator.of(sheet).pop(_PresetFileFormat.txt),
          ),
        ],
      ),
    );
  }

  Future<String> _savePresetFallback({
    required String fileName,
    required String contents,
  }) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsString(contents);
    return file.path;
  }

  String _safeFileName(String value) {
    final normalized = value.trim().replaceAll(RegExp(r'\s+'), '_');
    final sanitized = normalized.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '');
    return sanitized.isEmpty ? 'equalizer_preset' : sanitized;
  }

  Future<void> _renamePreset(EqPreset preset) async {
    final name = await _askForName(context, initial: preset.name);
    if (name == null) return;
    await _service.upsertCustomPreset(preset.copyWith(name: name));
    await _load();
  }

  Future<void> _deletePreset(EqPreset preset) async {
    final confirmed = await showLokalConfirmSheet(
      context: context,
      title: l10n.deletePreset,
      message: l10n.deleteThisCannotBeUndone(preset.name),
      confirmLabel: l10n.delete,
      destructive: true,
    );
    if (!confirmed) return;
    await _service.deleteCustomPreset(preset.id);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Padding(
        padding: EdgeInsets.only(top: AppConstants.spacingMd),
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: context.lokal.text,
          ),
        ),
      );
    }

    if (widget.view == _PresetsView.files) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: AppConstants.spacingSm),
          _GlassCard(
            child: Column(
              children: [
                _PresetActionRow(
                  icon: LucideIcons.fileUp,
                  title: l10n.importPresetFile,
                  subtitle: l10n.loadAJsonOrTxtPreset,
                  onTap: _importPresetFile,
                ),
                _Divider(),
                _PresetActionRow(
                  icon: LucideIcons.fileDown,
                  title: l10n.exportCurrentPreset,
                  subtitle: l10n.saveTheCurrentEqAsJson,
                  onTap: _exportCurrentPreset,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.spacingMd),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: AppConstants.spacingSm),
        _GlassCard(
          child: Column(
            children: [
              _PresetActionRow(
                icon: LucideIcons.plus,
                title: l10n.saveCurrentAsPreset,
                subtitle: l10n.createACustomPreset,
                onTap: _saveNewPreset,
              ),
              _Divider(),
              _PresetActionRow(
                icon: LucideIcons.headphones,
                title: l10n.autoeqHeadphones,
                subtitle: l10n.matchEqToYourHeadphoneModel,
                onTap: _openAutoEqSheet,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppConstants.spacingLg),
        _SectionHeader(title: l10n.builtIn),
        _GlassCard(
          child: Column(
            children: [
              for (final p in BuiltInEqPresets.presets) ...[
                _PresetRow(
                  title: p.name,
                  subtitle: p.mode == EqMode.graphic
                      ? l10n.graphic
                      : l10n.parametric,
                  onTap: () => _apply(p),
                ),
                if (p != BuiltInEqPresets.presets.last) _Divider(),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppConstants.spacingLg),
        _SectionHeader(title: l10n.custom),
        _GlassCard(
          child: _custom.isEmpty
              ? Padding(
                  padding: EdgeInsets.all(AppConstants.spacingMd),
                  child: Text(
                    l10n.noCustomPresetsYet,
                    style: TextStyle(
                      fontFamily: LokalTheme.sans,
                      color: context.lokal.muted,
                    ),
                  ),
                )
              : Column(
                  children: [
                    for (final p in _custom) ...[
                      _CustomPresetRow(
                        preset: p,
                        onApply: () => _apply(p),
                        onRename: () => _renamePreset(p),
                        onDelete: () => _deletePreset(p),
                      ),
                      if (p != _custom.last) _Divider(),
                    ],
                  ],
                ),
        ),
        const SizedBox(height: AppConstants.spacingMd),
      ],
    );
  }
}

class _PresetActionRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _PresetActionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingMd),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: context.lokal.surface3,
                  borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                ),
                child: Icon(icon, color: context.lokal.muted, size: 20),
              ),
              const SizedBox(width: AppConstants.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall
                          ?.copyWith(color: context.lokal.text),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: context.lokal.muted2),
                    ),
                  ],
                ),
              ),
              Icon(
                LucideIcons.chevronRight,
                color: context.lokal.muted2,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PresetRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _PresetRow({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingMd),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: context.lokal.surface3,
                  borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                ),
                child: Icon(
                  LucideIcons.bookmark,
                  color: context.lokal.muted,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppConstants.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall
                          ?.copyWith(color: context.lokal.text),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: context.lokal.muted2),
                    ),
                  ],
                ),
              ),
              Icon(LucideIcons.check, color: context.lokal.muted2, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomPresetRow extends StatelessWidget {
  final EqPreset preset;
  final VoidCallback onApply;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  const _CustomPresetRow({
    required this.preset,
    required this.onApply,
    required this.onRename,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: context.lokal.surface3,
                borderRadius: BorderRadius.circular(AppConstants.radiusSm),
              ),
              child: Icon(
                LucideIcons.star,
                color: context.lokal.muted,
                size: 20,
              ),
            ),
            const SizedBox(width: AppConstants.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    preset.name,
                    style: Theme.of(context).textTheme.titleSmall
                        ?.copyWith(color: context.lokal.text),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    preset.mode == EqMode.graphic
                        ? l10n.graphic
                        : l10n.parametric,
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: context.lokal.muted2),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: l10n.apply,
              onPressed: onApply,
              icon: Icon(
                LucideIcons.check,
                color: context.lokal.text,
                size: 18,
              ),
            ),
            IconButton(
              tooltip: l10n.rename,
              onPressed: onRename,
              icon: Icon(
                LucideIcons.pencil,
                color: context.lokal.muted,
                size: 18,
              ),
            ),
            IconButton(
              tooltip: l10n.delete,
              onPressed: onDelete,
              icon: const Icon(
                LucideIcons.trash2,
                color: Colors.redAccent,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopControlsRow extends ConsumerWidget {
  final bool enabled;
  const _TopControlsRow({required this.enabled});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        child: Row(
          children: [
            _IconTile(icon: LucideIcons.power, enabled: enabled),
            const SizedBox(width: AppConstants.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.equalizer,
                    style: Theme.of(context).textTheme.titleSmall
                        ?.copyWith(color: context.lokal.text),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    enabled ? l10n.enabled : l10n.disabled,
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: context.lokal.muted2),
                  ),
                ],
              ),
            ),
            _PillSwitch(
              value: enabled,
              onChanged: (v) =>
                  ref.read(equalizerProvider.notifier).setEnabled(v),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreampRow extends ConsumerWidget {
  final bool enabled;
  const _PreampRow({required this.enabled});

  Color _interpolateTextColor(double preampDb, BuildContext context) {
    const blue = Color(0xFF7AB6D9);
    const neutral = Color(0xFFB0B0B0);
    const gold = Color(0xFFE0B66B);
    final normalized = preampDb / EqualizerNotifier.preampMaxDb;

    if (normalized.abs() < 0.01) {
      return Theme.of(context).textTheme.bodySmall?.color ?? neutral;
    } else if (normalized < 0) {
      return Color.lerp(blue, neutral, (normalized + 1.0))!;
    } else {
      return Color.lerp(neutral, gold, normalized)!;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preampDb = ref.watch(eqPreampDbProvider);
    final isNonZero = preampDb.abs() > 0.01;
    final textColor = _interpolateTextColor(preampDb, context);

    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        child: Row(
          children: [
            _IconTile(icon: LucideIcons.gauge, enabled: enabled && isNonZero),
            const SizedBox(width: AppConstants.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        l10n.preamp,
                        style: Theme.of(context).textTheme.titleSmall
                            ?.copyWith(color: context.lokal.text),
                      ),
                      const Spacer(),
                      Text(
                        '${preampDb >= 0 ? '+' : ''}${preampDb.toStringAsFixed(1)} dB',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (isNonZero) ...[
                        const SizedBox(width: 8),
                        _ResetButton(
                          onTap: () => ref
                              .read(equalizerProvider.notifier)
                              .setPreamp(0.0),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Opacity(
                    opacity: enabled ? 1.0 : 0.5,
                    child: _PreampSlider(
                      preampDb: preampDb,
                      enabled: enabled,
                      onChanged: enabled
                          ? (v) => ref
                                .read(equalizerProvider.notifier)
                                .setPreamp(v)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _PreampScaleLabels(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResetButton extends StatelessWidget {
  final VoidCallback onTap;
  const _ResetButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusRound),
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: context.lokal.surface3,
            borderRadius: BorderRadius.circular(AppConstants.radiusRound),
            border: Border.all(color: context.lokal.border),
          ),
          child: Icon(
            LucideIcons.rotateCcw,
            size: 14,
            color: context.lokal.muted,
          ),
        ),
      ),
    );
  }
}

class _PreampSlider extends StatelessWidget {
  final double preampDb;
  final bool enabled;
  final ValueChanged<double>? onChanged;

  const _PreampSlider({
    required this.preampDb,
    required this.enabled,
    required this.onChanged,
  });

  Color _interpolateColor() {
    const blue = Color(0xFF7AB6D9);
    const neutral = Color(0xFFB0B0B0);
    const gold = Color(0xFFE0B66B);
    final normalized = preampDb / EqualizerNotifier.preampMaxDb;

    if (normalized < 0) {
      return Color.lerp(blue, neutral, (normalized + 1.0))!;
    } else {
      return Color.lerp(neutral, gold, normalized)!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final toneColor = _interpolateColor();

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          height: 24,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: enabled && preampDb.abs() > 0.01
                ? [
                    BoxShadow(
                      color: toneColor.withValues(alpha: 0.15),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 6,
            activeTrackColor: toneColor,
            inactiveTrackColor: context.lokal.border2,
            thumbColor: Colors.white,
            overlayColor: toneColor.withValues(alpha: 0.2),
            thumbShape: const _PreampThumbShape(),
            trackShape: const _PreampTrackShape(),
          ),
          child: Slider(
            value: preampDb,
            min: EqualizerNotifier.preampMinDb,
            max: EqualizerNotifier.preampMaxDb,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class _PreampTrackShape extends SliderTrackShape {
  const _PreampTrackShape();

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    Offset? offset,
    bool isDiscrete = false,
    bool isEnabled = false,
  }) {
    final trackHeight = 6.0;
    final left = offset?.dx ?? 0.0;
    final right = left + parentBox.size.width;
    return Rect.fromLTRB(
      left,
      (parentBox.size.height - trackHeight) / 2,
      right,
      (parentBox.size.height + trackHeight) / 2,
    );
  }

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Offset thumbCenter,
    required TextDirection textDirection,
    required Animation<double> enableAnimation,
    bool isDiscrete = false,
    bool isEnabled = false,
    Offset? secondaryOffset,
  }) {
    final trackRect = getPreferredRect(
      parentBox: parentBox,
      sliderTheme: sliderTheme,
      offset: offset,
    );

    final paint = Paint()
      ..color = sliderTheme.inactiveTrackColor ?? Colors.grey
      ..style = PaintingStyle.fill;

    context.canvas.drawRRect(
      RRect.fromRectAndRadius(trackRect, const Radius.circular(3)),
      paint,
    );

    final activeRect = Rect.fromLTRB(
      trackRect.left,
      trackRect.top,
      thumbCenter.dx,
      trackRect.bottom,
    );

    final gradientPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF7AB6D9).withValues(alpha: 0.6),
          sliderTheme.activeTrackColor ?? Colors.white,
        ],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(activeRect)
      ..style = PaintingStyle.fill;

    context.canvas.drawRRect(
      RRect.fromRectAndRadius(activeRect, const Radius.circular(3)),
      gradientPaint,
    );
  }
}

class _PreampThumbShape extends SliderComponentShape {
  const _PreampThumbShape();

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return const Size(20, 20);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final radius = 8.0;
    final paint = Paint()
      ..color = sliderTheme.thumbColor ?? Colors.white
      ..style = PaintingStyle.fill;

    context.canvas.drawCircle(center, radius, paint);

    final borderPaint = Paint()
      ..color = (sliderTheme.activeTrackColor ?? Colors.white).withValues(
        alpha: 0.3,
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    context.canvas.drawCircle(center, radius + 1, borderPaint);
  }
}

class _PreampScaleLabels extends StatelessWidget {
  const _PreampScaleLabels();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _ScaleLabel(value: '-24'),
        _ScaleLabel(value: '-12'),
        _ScaleLabel(value: '0', isCenter: true),
        _ScaleLabel(value: '+12'),
        _ScaleLabel(value: '+24'),
      ],
    );
  }
}

class _ScaleLabel extends StatelessWidget {
  final String value;
  final bool isCenter;

  const _ScaleLabel({required this.value, this.isCenter = false});

  @override
  Widget build(BuildContext context) {
    return Text(
      l10n.db2(value),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: isCenter ? context.lokal.muted : context.lokal.muted2,
        fontWeight: isCenter ? FontWeight.w600 : FontWeight.normal,
        fontSize: 10,
      ),
    );
  }
}

class _ModeAndActionsRow extends ConsumerWidget {
  final EqMode mode;
  const _ModeAndActionsRow({required this.mode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        child: Row(
          children: [
            Expanded(
              child: _ModeToggle(
                mode: mode,
                onChanged: (m) =>
                    ref.read(equalizerProvider.notifier).setMode(m),
              ),
            ),
            const SizedBox(width: AppConstants.spacingMd),
            _ActionButton(
              icon: LucideIcons.rotateCcw,
              label: l10n.reset,
              onTap: () {
                final notifier = ref.read(equalizerProvider.notifier);
                if (mode == EqMode.graphic) {
                  notifier.resetGraphic();
                } else {
                  notifier.resetParametric();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _BmtKnobsRow extends ConsumerWidget {
  final bool enabled;
  const _BmtKnobsRow({required this.enabled});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bassDb = ref.watch(eqBassDbProvider);
    final midDb = ref.watch(eqMidDbProvider);
    final trebleDb = ref.watch(eqTrebleDbProvider);

    return _GlassCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingMd),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacingMd,
              ),
              child: Row(
                children: [
                  _IconTile(icon: LucideIcons.audioWaveform, enabled: enabled),
                  const SizedBox(width: AppConstants.spacingMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.toneControls,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(color: context.lokal.text),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n.bassMidTreble,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: context.lokal.muted2),
                        ),
                      ],
                    ),
                  ),
                  if ((bassDb + midDb + trebleDb).abs() > 0.01)
                    _ResetButton(
                      onTap: () {
                        final notifier = ref.read(equalizerProvider.notifier);
                        notifier.setBassDb(0.0);
                        notifier.setMidDb(0.0);
                        notifier.setTrebleDb(0.0);
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.spacingMd),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _LabeledKnob(
                  icon: LucideIcons.arrowDown,
                  label: l10n.bass,
                  valueLabel:
                      '${bassDb >= 0 ? '+' : ''}${bassDb.toStringAsFixed(1)} dB',
                  value: bassDb,
                  min: EqualizerNotifier.gainMinDb,
                  max: EqualizerNotifier.gainMaxDb,
                  onChanged: enabled
                      ? (v) => ref.read(equalizerProvider.notifier).setBassDb(v)
                      : null,
                  onReset: () =>
                      ref.read(equalizerProvider.notifier).setBassDb(0.0),
                ),
                _LabeledKnob(
                  icon: LucideIcons.minus,
                  label: l10n.mid,
                  valueLabel:
                      '${midDb >= 0 ? '+' : ''}${midDb.toStringAsFixed(1)} dB',
                  value: midDb,
                  min: EqualizerNotifier.gainMinDb,
                  max: EqualizerNotifier.gainMaxDb,
                  onChanged: enabled
                      ? (v) => ref.read(equalizerProvider.notifier).setMidDb(v)
                      : null,
                  onReset: () =>
                      ref.read(equalizerProvider.notifier).setMidDb(0.0),
                ),
                _LabeledKnob(
                  icon: LucideIcons.arrowUp,
                  label: l10n.treble,
                  valueLabel:
                      '${trebleDb >= 0 ? '+' : ''}${trebleDb.toStringAsFixed(1)} dB',
                  value: trebleDb,
                  min: EqualizerNotifier.gainMinDb,
                  max: EqualizerNotifier.gainMaxDb,
                  onChanged: enabled
                      ? (v) =>
                            ref.read(equalizerProvider.notifier).setTrebleDb(v)
                      : null,
                  onReset: () =>
                      ref.read(equalizerProvider.notifier).setTrebleDb(0.0),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GraphicEqView extends ConsumerWidget {
  final GlobalKey? graphKey;
  const _GraphicEqView({this.graphKey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(eqEnabledProvider);
    final gains = ref.watch(
      equalizerProvider.select((s) => List<double>.of(s.graphicGainsDb)),
    );
    final adjustedBands = gains.where((gain) => gain.abs() >= 0.1).length;
    final maxGain = gains.fold<double>(0.0, (peak, gain) {
      return math.max(peak, gain.abs());
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: l10n.graphicEq),
        const SizedBox(height: AppConstants.spacingSm),
        _ModeSummaryRow(
          children: [
            _StatPill(
              icon: LucideIcons.slidersVertical,
              label: l10n.fixedBands,
            ),
            _StatPill(
              icon: adjustedBands == 0
                  ? LucideIcons.minus
                  : LucideIcons.sparkles,
              label: adjustedBands == 0
                  ? l10n.flatResponse
                  : l10n.bandsAdjusted(adjustedBands),
            ),
            _StatPill(
              icon: LucideIcons.refreshCcw,
              label: l10n.doubleTapABandToReset,
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spacingMd),
        _GlassCard(
          key: graphKey,
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      const InteractiveEqGraphScreen(mode: EqMode.graphic),
                ),
              );
            },
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CardHeader(
                    icon: LucideIcons.audioLines,
                    title: l10n.curvePreview,
                    subtitle: l10n.fixedCenterFrequenciesWithADb(
                      EqualizerNotifier.gainMaxDb.toStringAsFixed(0),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _ValueBadge(
                          value: maxGain == 0
                              ? '0.0 dB'
                              : l10n.dbMax(maxGain.toStringAsFixed(1)),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          LucideIcons.maximize2,
                          size: 16,
                          color: context.lokal.muted2,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingMd),
                  RepaintBoundary(
                    child: Opacity(
                      opacity: enabled ? 1.0 : 0.5,
                      child: const SizedBox(
                        height: 220,
                        child: GraphicEqGraph(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: AppConstants.spacingMd),
        _GlassCard(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spacingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CardHeader(
                  icon: LucideIcons.slidersVertical,
                  title: l10n.bandControls,
                  subtitle: l10n.swipeHorizontallyToFineTuneEach,
                ),
                const SizedBox(height: AppConstants.spacingMd),
                SizedBox(
                  height: 332,
                  child: RepaintBoundary(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: List<Widget>.generate(
                          EqualizerState.defaultGraphicFrequenciesHz.length,
                          (i) => Padding(
                            padding: EdgeInsets.only(
                              right:
                                  i ==
                                      EqualizerState
                                              .defaultGraphicFrequenciesHz
                                              .length -
                                          1
                                  ? 0
                                  : AppConstants.spacingMd,
                            ),
                            child: _GraphicBandSlider(
                              index: i,
                              frequencyHz:
                                  EqualizerState.defaultGraphicFrequenciesHz[i],
                              enabled: enabled,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _GraphicBandSlider extends ConsumerWidget {
  final int index;
  final double frequencyHz;
  final bool enabled;

  const _GraphicBandSlider({
    required this.index,
    required this.frequencyHz,
    required this.enabled,
  });

  String _freqLabel() {
    if (frequencyHz >= 1000) {
      final k = frequencyHz / 1000.0;
      return '${k.toStringAsFixed(k >= 10 ? 0 : 1)}k';
    }
    return frequencyHz.toStringAsFixed(0);
  }

  String _bandFamilyLabel() {
    if (frequencyHz < 125) return l10n.sub;
    if (frequencyHz < 500) return l10n.bass;
    if (frequencyHz < 2000) return l10n.mid;
    if (frequencyHz < 8000) return l10n.presence;
    return l10n.air;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gainDb = ref.watch(eqGraphicGainDbProvider(index));
    final toneColor = gainDb > 0
        ? const Color(0xFFE0B66B)
        : (gainDb < 0 ? const Color(0xFF7AB6D9) : context.lokal.muted2);

    return RepaintBoundary(
      child: Tooltip(
        message: enabled ? l10n.doubleTapToResetThisBand : l10n.enableEqToEdit,
        child: GestureDetector(
          onDoubleTap: enabled
              ? () => ref
                    .read(equalizerProvider.notifier)
                    .setGraphicGainDb(index, 0.0)
              : null,
          child: AnimatedContainer(
            duration: AppConstants.animationFast,
            width: 88,
            padding: const EdgeInsets.all(AppConstants.spacingSm),
            decoration: BoxDecoration(
              color: context.lokal.surface,
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              border: Border.all(
                color: gainDb.abs() >= 0.1
                    ? toneColor.withValues(alpha: 0.45)
                    : context.lokal.border,
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spacingSm,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: context.lokal.surface,
                    borderRadius: BorderRadius.circular(
                      AppConstants.radiusRound,
                    ),
                  ),
                  child: Text(
                    _freqLabel(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: enabled
                          ? context.lokal.text
                          : context.lokal.muted2,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.spacingSm),
                Text(
                  '${gainDb >= 0 ? '+' : ''}${gainDb.toStringAsFixed(1)}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: enabled ? toneColor : context.lokal.muted2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'dB',
                  style: Theme.of(context).textTheme.labelSmall
                      ?.copyWith(color: context.lokal.muted2),
                ),
                const SizedBox(height: AppConstants.spacingSm),
                Expanded(
                  child: Opacity(
                    opacity: enabled ? 1.0 : 0.5,
                    child: RotatedBox(
                      quarterTurns: -1,
                      child: _AnimatedSlider(
                        value: gainDb,
                        min: EqualizerNotifier.gainMinDb,
                        max: EqualizerNotifier.gainMaxDb,
                        activeTrackColor: toneColor,
                        inactiveTrackColor: context.lokal.border2,
                        thumbColor: toneColor,
                        overlayColor: toneColor.withValues(alpha: 0.12),
                        onChanged: enabled
                            ? (v) => ref
                                  .read(equalizerProvider.notifier)
                                  .setGraphicGainDb(index, v)
                            : null,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.spacingSm),
                Text(
                  _bandFamilyLabel(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: context.lokal.muted2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedSlider extends StatefulWidget {
  final double value;
  final double min;
  final double max;
  final ValueChanged<double>? onChanged;
  final Color? activeTrackColor;
  final Color? inactiveTrackColor;
  final Color? thumbColor;
  final Color? overlayColor;

  const _AnimatedSlider({
    required this.value,
    required this.min,
    required this.max,
    this.onChanged,
    this.activeTrackColor,
    this.inactiveTrackColor,
    this.thumbColor,
    this.overlayColor,
  });

  @override
  State<_AnimatedSlider> createState() => _AnimatedSliderState();
}

class _AnimatedSliderState extends State<_AnimatedSlider>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _currentValue = 0.0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _controller.addListener(() {
      if (mounted) {
        setState(() => _currentValue = _controller.value);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _animateTo(double target) {
    _controller
      ..stop()
      ..value = _currentValue;
    _controller.animateTo(
      target,
      curve: Curves.easeOutBack,
      duration: const Duration(milliseconds: 350),
    );
  }

  @override
  void didUpdateWidget(covariant _AnimatedSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newValue = widget.value;
    if ((newValue - _currentValue).abs() > 0.001 && !_isDragging) {
      _animateTo(newValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: 4,
        activeTrackColor: widget.activeTrackColor,
        inactiveTrackColor: widget.inactiveTrackColor,
        thumbColor: widget.thumbColor,
        overlayColor: widget.overlayColor,
      ),
      child: Slider(
        value: _currentValue,
        min: widget.min,
        max: widget.max,
        onChangeStart: (_) {
          _controller.stop();
          _isDragging = true;
        },
        onChangeEnd: (_) => _isDragging = false,
        onChanged: widget.onChanged != null
            ? (v) {
                setState(() => _currentValue = v);
                widget.onChanged!(v);
              }
            : null,
      ),
    );
  }
}

class _ParametricEqView extends ConsumerStatefulWidget {
  final GlobalKey? graphKey;
  const _ParametricEqView({this.graphKey});

  @override
  ConsumerState<_ParametricEqView> createState() => _ParametricEqViewState();
}

class _ParametricEqViewState extends ConsumerState<_ParametricEqView> {
  int? _selectedIndex;
  int? _justAddedIndex;
  final _bandScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _bandScrollController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _bandScrollController.dispose();
    super.dispose();
  }

  void _addBand() {
    final before = ref.read(equalizerProvider).parametricBands.length;
    ref.read(equalizerProvider.notifier).addParametricBand();
    final after = ref.read(equalizerProvider).parametricBands.length;
    if (after == before) return;
    setState(() => _justAddedIndex = after - 1);
    Future.delayed(AppConstants.animationSlow, () {
      if (!mounted || !_bandScrollController.hasClients) return;
      _bandScrollController.animateTo(
        _bandScrollController.position.maxScrollExtent,
        duration: AppConstants.animationFast,
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final enabled = ref.watch(eqEnabledProvider);
    final bands = ref.watch(
      equalizerProvider.select(
        (s) => List<ParametricBand>.of(s.parametricBands),
      ),
    );
    final activeCount = bands.where((band) => band.enabled).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: l10n.parametricEq),
        const SizedBox(height: AppConstants.spacingSm),
        _ModeSummaryRow(
          children: [
            _StatPill(
              icon: LucideIcons.circleDot,
              label: l10n.activeBands(activeCount),
            ),
            _StatPill(
              icon: LucideIcons.scanSearch,
              label: l10n.logFrequencyControl,
            ),
            _StatPill(icon: LucideIcons.funnel, label: l10n.multiFilterBands),
            _StatPill(
              icon: LucideIcons.slidersHorizontal,
              label: l10n.bands(bands.length),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spacingMd),
        _GlassCard(
          key: widget.graphKey,
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      const InteractiveEqGraphScreen(mode: EqMode.parametric),
                ),
              );
            },
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CardHeader(
                    icon: LucideIcons.gitBranchPlus,
                    title: l10n.curvePreview,
                    subtitle: l10n.parametricBandsWithIndependentFrequency(
                      bands.length,
                    ),
                    trailing: Icon(
                      LucideIcons.maximize2,
                      size: 16,
                      color: context.lokal.muted2,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingMd),
                  _ParametricBandSummary(bands: bands, enabled: enabled),
                  const SizedBox(height: AppConstants.spacingMd),
                  RepaintBoundary(
                    child: Opacity(
                      opacity: enabled ? 1.0 : 0.5,
                      child: const SizedBox(
                        height: 220,
                        child: ParametricEqGraph(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: AppConstants.spacingLg),
        _GlassCard(
          child: RepaintBoundary(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.spacingMd),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CardHeader(
                    icon: LucideIcons.slidersHorizontal,
                    title: l10n.bandEditors,
                    subtitle: l10n.tapABandToExpandDrag,
                  ),
                  const SizedBox(height: AppConstants.spacingMd),
                  SizedBox(
                    height: 300,
                    child: ListView.separated(
                      controller: _bandScrollController,
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: bands.length + 1,
                      separatorBuilder: (_, _) =>
                          const SizedBox(width: AppConstants.spacingMd),
                      itemBuilder: (context, i) {
                        if (i == bands.length) {
                          return _AddBandCard(
                            enabled: enabled,
                            onAdd: _addBand,
                          );
                        }
                        final card = _ParametricBandEditor(
                          index: i,
                          enabled: enabled,
                          isSelected: _selectedIndex == i,
                          onTap: () => setState(() {
                            _selectedIndex = _selectedIndex == i ? null : i;
                          }),
                          onRemove: bands.length > 1
                              ? () {
                                  final removed = i;
                                  ref
                                      .read(equalizerProvider.notifier)
                                      .removeParametricBand(removed);
                                  setState(() {
                                    if (_selectedIndex != null) {
                                      if (removed == _selectedIndex) {
                                        _selectedIndex = null;
                                      } else if (removed < _selectedIndex!) {
                                        _selectedIndex = _selectedIndex! - 1;
                                      }
                                    }
                                  });
                                }
                              : null,
                        );
                        if (_justAddedIndex != i) return card;
                        return TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: AppConstants.animationSlow,
                          curve: Curves.easeOutCubic,
                          onEnd: () {
                            if (!mounted || _justAddedIndex != i) return;
                            setState(() => _justAddedIndex = null);
                          },
                          builder: (context, t, child) => Opacity(
                            opacity: t,
                            child: Transform.scale(
                              scale: 0.85 + 0.15 * t,
                              child: child,
                            ),
                          ),
                          child: card,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingSm),
                  _ScrollProgressBar(controller: _bandScrollController),
                  AnimatedSize(
                    duration: AppConstants.animationNormal,
                    curve: Curves.easeInOutCubic,
                    alignment: Alignment.topCenter,
                    child:
                        (_selectedIndex != null &&
                            _selectedIndex! < bands.length)
                        ? Padding(
                            padding: const EdgeInsets.only(
                              top: AppConstants.spacingMd,
                            ),
                            child: TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration: AppConstants.animationNormal,
                              curve: Curves.easeOutCubic,
                              builder: (context, t, child) => Opacity(
                                opacity: t,
                                child: Transform.translate(
                                  offset: Offset(0, 8 * (1 - t)),
                                  child: child,
                                ),
                              ),
                              child: _BandDetailPanel(
                                index: _selectedIndex!,
                                enabled: enabled,
                              ),
                            ),
                          )
                        : const SizedBox(width: double.infinity),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ParametricBandSummary extends StatelessWidget {
  final List<ParametricBand> bands;
  final bool enabled;

  const _ParametricBandSummary({required this.bands, required this.enabled});

  String _hzLabel(double hz) {
    if (hz >= 1000) {
      final k = hz / 1000.0;
      return '${k.toStringAsFixed(k >= 10 ? 0 : 1)}k';
    }
    return hz.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: bands.length,
        itemBuilder: (context, index) {
          final band = bands[index];
          final active = enabled && band.enabled;
          final gainLabel = band.type == ParametricBandType.notch
              ? l10n.dbCut(band.gainDb.abs().toStringAsFixed(1))
              : '${band.gainDb >= 0 ? '+' : ''}${band.gainDb.toStringAsFixed(1)} dB';
          final valueLabel = band.type.supportsGain
              ? l10n.u20223(band.type.displayName, gainLabel)
              : band.type.displayName;
          return Padding(
            padding: const EdgeInsets.only(right: AppConstants.spacingSm),
            child: AnimatedContainer(
              duration: AppConstants.animationFast,
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacingSm,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: active ? context.lokal.surface3 : context.lokal.surface2,
                borderRadius: BorderRadius.circular(AppConstants.radiusRound),
                border: Border.all(
                  color: active ? context.lokal.border2 : context.lokal.border,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.b(index + 1),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: active ? context.lokal.text : context.lokal.muted2,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    l10n.u2022(_hzLabel(band.frequencyHz), valueLabel),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: active
                          ? context.lokal.muted
                          : context.lokal.muted2,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ScrollProgressBar extends StatelessWidget {
  final ScrollController controller;

  const _ScrollProgressBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        double progress = 0.0;
        try {
          if (controller.hasClients && controller.positions.isNotEmpty) {
            final max = controller.position.maxScrollExtent;
            if (max > 0) {
              progress = controller.offset / max;
            }
          }
        } catch (_) {}
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.radiusRound),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 3,
              backgroundColor: context.lokal.border,
              valueColor: AlwaysStoppedAnimation<Color>(context.lokal.border2),
            ),
          ),
        );
      },
    );
  }
}

class _BandDetailPanel extends ConsumerStatefulWidget {
  final int index;
  final bool enabled;

  const _BandDetailPanel({required this.index, required this.enabled});

  @override
  ConsumerState<_BandDetailPanel> createState() => _BandDetailPanelState();
}

class _BandDetailPanelState extends ConsumerState<_BandDetailPanel> {
  static const double _minHz = 20.0;
  static const double _maxHz = 20000.0;

  double _hzToT(double hz) {
    final clamped = hz.clamp(_minHz, _maxHz).toDouble();
    final logMin = math.log(_minHz);
    final logMax = math.log(_maxHz);
    return (math.log(clamped) - logMin) / (logMax - logMin);
  }

  double _tToHz(double t) {
    final logMin = math.log(_minHz);
    final logMax = math.log(_maxHz);
    final v = logMin + (logMax - logMin) * t.clamp(0.0, 1.0);
    return math.exp(v);
  }

  String _hzLabel(double hz) {
    if (hz >= 1000) {
      final k = hz / 1000.0;
      return '${k.toStringAsFixed(k >= 10 ? 0 : 1)} kHz';
    }
    return l10n.hz6(hz.toStringAsFixed(0));
  }

  void _showEditor({
    required BuildContext context,
    required double value,
    required String unit,
    required String label,
    required double min,
    required double max,
    required ValueChanged<double> onSubmitted,
  }) {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: l10n.dismiss,
      barrierColor: Colors.black.withValues(alpha: 0.3),
      builder: (_) => _InlineValueEditor(
        initialValue: value,
        unit: unit,
        label: label,
        min: min,
        max: max,
        onSubmitted: onSubmitted,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final band = ref.watch(eqParamBandProvider(widget.index));
    final editable = widget.enabled && band.enabled;
    final toneColor = band.gainDb > 0.1
        ? const Color(0xFFE0B66B)
        : (band.gainDb < -0.1 ? const Color(0xFF7AB6D9) : context.lokal.muted2);

    return AnimatedContainer(
      duration: AppConstants.animationNormal,
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: context.lokal.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: toneColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: context.lokal.surface2,
                  borderRadius: BorderRadius.circular(6),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${widget.index + 1}',
                  style: TextStyle(
                    fontFamily: LokalTheme.sans,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: context.lokal.text,
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.spacingSm),
              Expanded(
                child: Text(
                  l10n.bandU2022(widget.index + 1, band.type.displayName),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.lokal.text,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              _BandTypeDropdown(
                value: band.type,
                compact: false,
                onChanged: editable
                    ? (type) => ref
                          .read(equalizerProvider.notifier)
                          .setParamBandType(widget.index, type)
                    : null,
              ),
              const SizedBox(width: AppConstants.spacingSm),
              _PillSwitch(
                value: band.enabled,
                onChanged: widget.enabled
                    ? (v) => ref
                          .read(equalizerProvider.notifier)
                          .setParamBandEnabled(widget.index, v)
                    : (_) {},
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingLg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DetailKnob(
                label: l10n.frequency,
                value: _hzLabel(band.frequencyHz),
                knob: RotaryKnob(
                  value: _hzToT(band.frequencyHz),
                  min: 0.0,
                  max: 1.0,
                  size: 100,
                  onChanged: editable
                      ? (t) => ref
                            .read(equalizerProvider.notifier)
                            .setParamBandFreqHz(widget.index, _tToHz(t))
                      : null,
                  label: l10n.freq,
                ),
                onTapValue: editable
                    ? () => _showEditor(
                        context: context,
                        value: band.frequencyHz,
                        unit: l10n.hz5,
                        label: l10n.frequency,
                        min: 20.0,
                        max: 20000.0,
                        onSubmitted: (v) => ref
                            .read(equalizerProvider.notifier)
                            .setParamBandFreqHz(widget.index, v),
                      )
                    : null,
              ),
              if (band.type.supportsGain)
                _DetailKnob(
                  label: band.type == ParametricBandType.notch
                      ? l10n.notchDepth
                      : l10n.gain,
                  value: band.type == ParametricBandType.notch
                      ? l10n.db9(band.gainDb.abs().toStringAsFixed(1))
                      : '${band.gainDb >= 0 ? '+' : ''}${band.gainDb.toStringAsFixed(1)} dB',
                  knob: RotaryKnob(
                    value: band.type == ParametricBandType.notch
                        ? band.gainDb.abs()
                        : band.gainDb,
                    min: band.type == ParametricBandType.notch
                        ? 0.0
                        : EqualizerNotifier.gainMinDb,
                    max: EqualizerNotifier.gainMaxDb,
                    size: 100,
                    onChanged: editable
                        ? (v) => ref
                              .read(equalizerProvider.notifier)
                              .setParamBandGainDb(
                                widget.index,
                                band.type == ParametricBandType.notch
                                    ? -v.abs()
                                    : v,
                              )
                        : null,
                    label: l10n.gain,
                    accentColor: toneColor,
                  ),
                  onTapValue: editable
                      ? () => _showEditor(
                          context: context,
                          value: band.type == ParametricBandType.notch
                              ? band.gainDb.abs()
                              : band.gainDb,
                          unit: 'dB',
                          label: band.type == ParametricBandType.notch
                              ? l10n.notchDepth
                              : l10n.gain,
                          min: band.type == ParametricBandType.notch
                              ? 0.0
                              : EqualizerNotifier.gainMinDb,
                          max: EqualizerNotifier.gainMaxDb,
                          onSubmitted: (v) => ref
                              .read(equalizerProvider.notifier)
                              .setParamBandGainDb(
                                widget.index,
                                band.type == ParametricBandType.notch
                                    ? -v.abs()
                                    : v,
                              ),
                        )
                      : null,
                  accentColor: toneColor,
                ),
              _DetailKnob(
                label: band.type.qLabel,
                value: band.q.toStringAsFixed(2),
                knob: RotaryKnob(
                  value: band.q,
                  min: EqualizerNotifier.qMin,
                  max: EqualizerNotifier.qMax,
                  size: 100,
                  onChanged: editable
                      ? (v) => ref
                            .read(equalizerProvider.notifier)
                            .setParamBandQ(widget.index, v)
                      : null,
                  label: band.type.qLabel,
                ),
                onTapValue: editable
                    ? () => _showEditor(
                        context: context,
                        value: band.q,
                        unit: 'Q',
                        label: band.type.qLabel,
                        min: EqualizerNotifier.qMin,
                        max: EqualizerNotifier.qMax,
                        onSubmitted: (v) => ref
                            .read(equalizerProvider.notifier)
                            .setParamBandQ(widget.index, v),
                      )
                    : null,
              ),
            ],
          ),
          if (editable) ...[
            const SizedBox(height: AppConstants.spacingSm),
            Center(
              child: GestureDetector(
                onTap: () => ref
                    .read(equalizerProvider.notifier)
                    .setParamBandGainDb(widget.index, 0.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spacingMd,
                    vertical: AppConstants.spacingXs,
                  ),
                  decoration: BoxDecoration(
                    color: context.lokal.surface2,
                    borderRadius: BorderRadius.circular(
                      AppConstants.radiusRound,
                    ),
                    border: Border.all(color: context.lokal.border),
                  ),
                  child: Text(
                    l10n.resetTo0Db,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: context.lokal.muted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailKnob extends StatelessWidget {
  final String label;
  final String value;
  final Widget knob;
  final VoidCallback? onTapValue;
  final Color? accentColor;

  const _DetailKnob({
    required this.label,
    required this.value,
    required this.knob,
    this.onTapValue,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: context.lokal.muted2,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppConstants.spacingXs),
        knob,
        const SizedBox(height: AppConstants.spacingXs),
        GestureDetector(
          onTap: onTapValue,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacingSm,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: context.lokal.surface2,
              borderRadius: BorderRadius.circular(AppConstants.radiusRound),
            ),
            child: Text(
              value,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: accentColor ?? context.lokal.text,
                fontWeight: FontWeight.w700,
                fontFamily: LokalTheme.sans,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _InlineValueEditor extends StatefulWidget {
  final double initialValue;
  final String unit;
  final String label;
  final ValueChanged<double> onSubmitted;
  final double min;
  final double max;

  const _InlineValueEditor({
    required this.initialValue,
    required this.unit,
    required this.label,
    required this.onSubmitted,
    this.min = 0.0,
    this.max = double.infinity,
  });

  @override
  State<_InlineValueEditor> createState() => _InlineValueEditorState();
}

class _InlineValueEditorState extends State<_InlineValueEditor> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initialValue.toStringAsFixed(
        widget.unit == 'dB' || widget.unit == 'Q' ? 2 : 0,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final parsed = double.tryParse(_controller.text.trim());
    if (parsed != null) {
      widget.onSubmitted(parsed.clamp(widget.min, widget.max).toDouble());
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      behavior: HitTestBehavior.translucent,
      child: Container(
        color: Colors.transparent,
        alignment: Alignment.center,
        child: GestureDetector(
          onTap: () {},
          child: Container(
            width: 240,
            padding: const EdgeInsets.all(AppConstants.spacingMd),
            decoration: BoxDecoration(
              color: context.lokal.surface2,
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              border: Border.all(color: context.lokal.border2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.label,
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: context.lokal.muted),
                ),
                const SizedBox(height: AppConstants.spacingSm),
                TextField(
                  controller: _controller,
                  autofocus: true,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: true,
                  ),
                  textInputAction: TextInputAction.done,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: context.lokal.text,
                    fontFamily: LokalTheme.sans,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    suffixText: widget.unit,
                    suffixStyle: Theme.of(context).textTheme.labelSmall
                        ?.copyWith(color: context.lokal.muted2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppConstants.radiusSm,
                      ),
                      borderSide: BorderSide(color: context.lokal.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppConstants.radiusSm,
                      ),
                      borderSide: BorderSide(color: context.lokal.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppConstants.radiusSm,
                      ),
                      borderSide: BorderSide(color: context.lokal.text),
                    ),
                  ),
                  onSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: AppConstants.spacingMd),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _submit,
                    child: Text(
                      l10n.done,
                      style: TextStyle(
                        fontFamily: LokalTheme.sans,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AddBandCard extends ConsumerWidget {
  final bool enabled;
  final VoidCallback? onAdd;

  const _AddBandCard({required this.enabled, this.onAdd});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bands = ref.watch(equalizerProvider.select((s) => s.parametricBands));
    final atLimit = bands.length >= EqualizerNotifier.maxParametricBands;

    return SizedBox(
      width: 140,
      child: GestureDetector(
        onTap: atLimit || !enabled || onAdd == null ? null : onAdd,
        child: AnimatedContainer(
          duration: AppConstants.animationFast,
          decoration: BoxDecoration(
            color: context.lokal.surface,
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            border: Border.all(
              color: enabled && !atLimit
                  ? context.lokal.border2
                  : context.lokal.border,
            ),
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                LucideIcons.plus,
                size: 32,
                color: enabled && !atLimit
                    ? context.lokal.muted
                    : context.lokal.muted2,
              ),
              const SizedBox(height: AppConstants.spacingSm),
              Text(
                atLimit ? l10n.limit : l10n.add,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: enabled && !atLimit
                      ? context.lokal.muted
                      : context.lokal.muted2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ParametricBandEditor extends ConsumerWidget {
  final int index;
  final bool enabled;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  const _ParametricBandEditor({
    required this.index,
    required this.enabled,
    this.isSelected = false,
    this.onTap,
    this.onRemove,
  });

  String _hzLabel(double hz) {
    if (hz >= 1000) {
      final k = hz / 1000.0;
      return '${k.toStringAsFixed(k >= 10 ? 0 : 1)}k';
    }
    return hz.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final band = ref.watch(eqParamBandProvider(index));
    final editable = enabled && band.enabled;
    final toneColor = band.gainDb > 0.1
        ? const Color(0xFFE0B66B)
        : (band.gainDb < -0.1 ? const Color(0xFF7AB6D9) : context.lokal.muted2);

    return SizedBox(
      width: 160,
      child: GestureDetector(
        onTap: onTap,
        onDoubleTap: editable
            ? () => ref
                  .read(equalizerProvider.notifier)
                  .setParamBandGainDb(index, 0.0)
            : null,
        child: AnimatedContainer(
          duration: AppConstants.animationFast,
          decoration: BoxDecoration(
            color: context.lokal.surface,
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            border: Border.all(
              color: isSelected
                  ? toneColor.withValues(alpha: 0.6)
                  : band.gainDb.abs() >= 0.1 && editable
                  ? toneColor.withValues(alpha: 0.35)
                  : context.lokal.border,
              width: isSelected ? 2.0 : 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: toneColor.withValues(alpha: 0.12),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacingMd,
              vertical: AppConstants.spacingSm,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: context.lokal.surface2,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontFamily: LokalTheme.sans,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                          color: context.lokal.text,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: onRemove,
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: Icon(
                          LucideIcons.x,
                          size: 16,
                          color: onRemove == null
                              ? context.lokal.border
                              : context.lokal.muted2,
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: context.lokal.surface2,
                    borderRadius: BorderRadius.circular(
                      AppConstants.radiusRound,
                    ),
                  ),
                  child: Text(
                    _hzLabel(band.frequencyHz),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: editable
                          ? context.lokal.text
                          : context.lokal.muted2,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ),
                if (band.type.supportsGain) ...[
                  RotaryKnob(
                    value: band.type == ParametricBandType.notch
                        ? band.gainDb.abs()
                        : band.gainDb,
                    min: band.type == ParametricBandType.notch
                        ? 0.0
                        : EqualizerNotifier.gainMinDb,
                    max: EqualizerNotifier.gainMaxDb,
                    size: 110,
                    onChanged: editable
                        ? (v) => ref
                              .read(equalizerProvider.notifier)
                              .setParamBandGainDb(
                                index,
                                band.type == ParametricBandType.notch
                                    ? -v.abs()
                                    : v,
                              )
                        : null,
                    label: l10n.gain,
                    accentColor: toneColor,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: context.lokal.surface2,
                      borderRadius: BorderRadius.circular(
                        AppConstants.radiusRound,
                      ),
                    ),
                    child: Text(
                      band.type == ParametricBandType.notch
                          ? l10n.db9(band.gainDb.abs().toStringAsFixed(1))
                          : '${band.gainDb >= 0 ? '+' : ''}${band.gainDb.toStringAsFixed(1)} dB',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: editable ? toneColor : context.lokal.muted2,
                        fontWeight: FontWeight.w700,
                        fontFamily: LokalTheme.sans,
                      ),
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 110, width: 110),
                  Text(
                    band.type.displayName,
                    style: Theme.of(context).textTheme.labelSmall
                        ?.copyWith(color: context.lokal.muted2, fontSize: 11),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                Icon(
                  isSelected ? LucideIcons.chevronUp : LucideIcons.chevronDown,
                  size: 14,
                  color: context.lokal.muted2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DynamicsSection extends ConsumerWidget {
  const _DynamicsSection();

  bool get _showAndroidNote =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(eqEnabledProvider);
    final compressor = ref.watch(eqCompressorProvider);
    final limiter = ref.watch(eqLimiterProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: l10n.dynamics),
        const SizedBox(height: AppConstants.spacingSm),
        _ModeSummaryRow(
          children: [
            _StatPill(
              icon: compressor.enabled
                  ? LucideIcons.badgeCheck
                  : LucideIcons.circleOff,
              label: compressor.enabled
                  ? l10n.compressorOn
                  : l10n.compressorOff,
            ),
            _StatPill(
              icon: limiter.enabled
                  ? LucideIcons.shieldCheck
                  : LucideIcons.shieldOff,
              label: limiter.enabled ? l10n.limiterOn : l10n.limiterOff,
            ),
            _StatPill(
              icon: enabled ? LucideIcons.audioLines : LucideIcons.powerOff,
              label: enabled ? l10n.processingLive : l10n.masterBypassed,
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spacingSm),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () =>
                ref.read(equalizerProvider.notifier).resetDynamics(),
            icon: const Icon(LucideIcons.rotateCcw, size: 18),
            label: Text(
              l10n.resetDynamics,
              style: TextStyle(
                fontFamily: LokalTheme.sans,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: TextButton.styleFrom(foregroundColor: context.lokal.text),
          ),
        ),
        if (_showAndroidNote) ...[
          const SizedBox(height: AppConstants.spacingMd),
          const _ProcessingSupportNote(),
        ],
        const SizedBox(height: AppConstants.spacingMd),
        _DynamicsCard(
          icon: LucideIcons.activity,
          title: l10n.compressor,
          subtitle: l10n.smoothsPeaksAndRaisesBodyBefore,
          active: enabled && compressor.enabled,
          toggleValue: compressor.enabled,
          onToggleChanged: (value) =>
              ref.read(equalizerProvider.notifier).setCompressorEnabled(value),
          children: [
            Wrap(
              spacing: AppConstants.spacingMd,
              runSpacing: AppConstants.spacingLg,
              alignment: WrapAlignment.center,
              children: [
                _LabeledKnob(
                  icon: LucideIcons.arrowDownWideNarrow,
                  label: l10n.threshold,
                  valueLabel: l10n.db10(
                    compressor.thresholdDb.toStringAsFixed(1),
                  ),
                  value: compressor.thresholdDb,
                  min: EqualizerNotifier.compressorThresholdMinDb,
                  max: EqualizerNotifier.compressorThresholdMaxDb,
                  onChanged: enabled && compressor.enabled
                      ? (value) => ref
                            .read(equalizerProvider.notifier)
                            .setCompressorThresholdDb(value)
                      : null,
                ),
                _LabeledKnob(
                  icon: LucideIcons.ratio,
                  label: l10n.ratio,
                  valueLabel: '${compressor.ratio.toStringAsFixed(1)}:1',
                  value: compressor.ratio,
                  min: EqualizerNotifier.compressorRatioMin,
                  max: EqualizerNotifier.compressorRatioMax,
                  onChanged: enabled && compressor.enabled
                      ? (value) => ref
                            .read(equalizerProvider.notifier)
                            .setCompressorRatio(value)
                      : null,
                ),
                _LabeledKnob(
                  icon: LucideIcons.timer,
                  label: l10n.attack,
                  valueLabel: l10n.ms2(compressor.attackMs.toStringAsFixed(0)),
                  value: compressor.attackMs,
                  min: EqualizerNotifier.compressorAttackMinMs,
                  max: EqualizerNotifier.compressorAttackMaxMs,
                  onChanged: enabled && compressor.enabled
                      ? (value) => ref
                            .read(equalizerProvider.notifier)
                            .setCompressorAttackMs(value)
                      : null,
                ),
                _LabeledKnob(
                  icon: LucideIcons.timerReset,
                  label: l10n.release,
                  valueLabel: l10n.ms3(compressor.releaseMs.toStringAsFixed(0)),
                  value: compressor.releaseMs,
                  min: EqualizerNotifier.compressorReleaseMinMs,
                  max: EqualizerNotifier.compressorReleaseMaxMs,
                  onChanged: enabled && compressor.enabled
                      ? (value) => ref
                            .read(equalizerProvider.notifier)
                            .setCompressorReleaseMs(value)
                      : null,
                ),
                _LabeledKnob(
                  icon: LucideIcons.volume2,
                  label: l10n.makeup,
                  valueLabel:
                      '${compressor.makeupGainDb >= 0 ? '+' : ''}${compressor.makeupGainDb.toStringAsFixed(1)} dB',
                  value: compressor.makeupGainDb,
                  min: EqualizerNotifier.gainMinDb,
                  max: EqualizerNotifier.gainMaxDb,
                  onChanged: enabled && compressor.enabled
                      ? (value) => ref
                            .read(equalizerProvider.notifier)
                            .setCompressorMakeupGainDb(value)
                      : null,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spacingMd),
        _DynamicsCard(
          icon: LucideIcons.shieldCheck,
          title: l10n.limiter,
          subtitle: l10n.addsPreDriveAndCatchesPeaks,
          active: enabled && limiter.enabled,
          toggleValue: limiter.enabled,
          onToggleChanged: (value) =>
              ref.read(equalizerProvider.notifier).setLimiterEnabled(value),
          children: [
            Wrap(
              spacing: AppConstants.spacingMd,
              runSpacing: AppConstants.spacingLg,
              alignment: WrapAlignment.center,
              children: [
                _LabeledKnob(
                  icon: LucideIcons.gauge,
                  label: l10n.inputGain,
                  valueLabel:
                      '${limiter.inputGainDb >= 0 ? '+' : ''}${limiter.inputGainDb.toStringAsFixed(1)} dB',
                  value: limiter.inputGainDb,
                  min: EqualizerNotifier.limiterInputGainMinDb,
                  max: EqualizerNotifier.limiterInputGainMaxDb,
                  onChanged: enabled && limiter.enabled
                      ? (value) => ref
                            .read(equalizerProvider.notifier)
                            .setLimiterInputGainDb(value)
                      : null,
                ),
                _LabeledKnob(
                  icon: LucideIcons.alignEndVertical,
                  label: l10n.ceiling,
                  valueLabel: l10n.db13(limiter.ceilingDb.toStringAsFixed(1)),
                  value: limiter.ceilingDb,
                  min: EqualizerNotifier.limiterCeilingMinDb,
                  max: EqualizerNotifier.limiterCeilingMaxDb,
                  onChanged: enabled && limiter.enabled
                      ? (value) => ref
                            .read(equalizerProvider.notifier)
                            .setLimiterCeilingDb(value)
                      : null,
                ),
                _LabeledKnob(
                  icon: LucideIcons.timerReset,
                  label: l10n.release,
                  valueLabel: l10n.ms4(limiter.releaseMs.toStringAsFixed(0)),
                  value: limiter.releaseMs,
                  min: EqualizerNotifier.limiterReleaseMinMs,
                  max: EqualizerNotifier.limiterReleaseMaxMs,
                  onChanged: enabled && limiter.enabled
                      ? (value) => ref
                            .read(equalizerProvider.notifier)
                            .setLimiterReleaseMs(value)
                      : null,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _CreativeFxSection extends ConsumerWidget {
  const _CreativeFxSection();

  static const double _filterMinHz = EqualizerNotifier.fxFilterMinHz;
  static const double _filterMaxHz = EqualizerNotifier.fxFilterMaxHz;

  double _hzToT(double hz) {
    final clamped = hz.clamp(_filterMinHz, _filterMaxHz).toDouble();
    final logMin = math.log(_filterMinHz);
    final logMax = math.log(_filterMaxHz);
    return (math.log(clamped) - logMin) / (logMax - logMin);
  }

  double _tToHz(double t) {
    final logMin = math.log(_filterMinHz);
    final logMax = math.log(_filterMaxHz);
    final value = logMin + (logMax - logMin) * t.clamp(0.0, 1.0);
    return math.exp(value);
  }

  String _hzLabel(double hz) {
    if (hz >= 1000.0) {
      final k = hz / 1000.0;
      return '${k.toStringAsFixed(k >= 10 ? 0 : 1)} kHz';
    }
    return l10n.hz6(hz.toStringAsFixed(0));
  }

  String _percentLabel(double value) => '${(value * 100).round()}%';

  String _balanceLabel(double balance) {
    if (balance.abs() < 0.01) return l10n.center;
    final side = balance > 0 ? 'R' : 'L';
    final amount = (balance.abs() * 100).round();
    return '$side $amount%';
  }

  String _widthLabel(double width) {
    final amount = (width * 100).round();
    if ((width - 1.0).abs() < 0.01) return l10n.neutral(amount);
    return width > 1.0 ? l10n.wide(amount) : l10n.narrow(amount);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(eqEnabledProvider);
    final fx = ref.watch(eqFxProvider);
    final editable = enabled && fx.enabled;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: l10n.creativeFx),
        const SizedBox(height: AppConstants.spacingSm),
        _ModeSummaryRow(
          children: [
            _StatPill(
              icon: fx.enabled ? LucideIcons.sparkles : LucideIcons.circleOff,
              label: fx.enabled ? l10n.fxOn : l10n.fxOff,
            ),
            _StatPill(
              icon: LucideIcons.slidersHorizontal,
              label: l10n.balance2(_balanceLabel(fx.balance)),
            ),
            _StatPill(
              icon: LucideIcons.timer,
              label: l10n.tempoX(fx.tempo.toStringAsFixed(2)),
            ),
            _StatPill(
              icon: LucideIcons.audioLines,
              label: l10n.mix2(_percentLabel(fx.mix)),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spacingSm),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () => ref.read(equalizerProvider.notifier).resetFx(),
            icon: const Icon(LucideIcons.rotateCcw, size: 18),
            label: Text(
              l10n.resetFx,
              style: TextStyle(
                fontFamily: LokalTheme.sans,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: TextButton.styleFrom(foregroundColor: context.lokal.text),
          ),
        ),
        const SizedBox(height: AppConstants.spacingMd),
        _DynamicsCard(
          icon: LucideIcons.sparkles,
          title: l10n.spatialTime,
          subtitle: l10n.balanceTempoDampFilterDelaysSize,
          active: enabled && fx.enabled,
          toggleValue: fx.enabled,
          onToggleChanged: (value) =>
              ref.read(equalizerProvider.notifier).setFxEnabled(value),
          children: [
            Wrap(
              spacing: AppConstants.spacingMd,
              runSpacing: AppConstants.spacingLg,
              alignment: WrapAlignment.center,
              children: [
                _LabeledKnob(
                  icon: LucideIcons.slidersHorizontal,
                  label: l10n.balance,
                  valueLabel: _balanceLabel(fx.balance),
                  value: fx.balance,
                  min: EqualizerNotifier.fxBalanceMin,
                  max: EqualizerNotifier.fxBalanceMax,
                  onChanged: editable
                      ? (value) => ref
                            .read(equalizerProvider.notifier)
                            .setFxBalance(value)
                      : null,
                ),
                _LabeledKnob(
                  icon: LucideIcons.timer,
                  label: l10n.tempo,
                  valueLabel: '${fx.tempo.toStringAsFixed(2)}x',
                  value: fx.tempo,
                  min: EqualizerNotifier.fxTempoMin,
                  max: EqualizerNotifier.fxTempoMax,
                  onChanged: editable
                      ? (value) => ref
                            .read(equalizerProvider.notifier)
                            .setFxTempo(value)
                      : null,
                ),
                _LabeledKnob(
                  icon: LucideIcons.activity,
                  label: l10n.damp,
                  valueLabel: _percentLabel(fx.damp),
                  value: fx.damp,
                  min: EqualizerNotifier.fxDampMin,
                  max: EqualizerNotifier.fxDampMax,
                  onChanged: editable
                      ? (value) => ref
                            .read(equalizerProvider.notifier)
                            .setFxDamp(value)
                      : null,
                ),
                _LabeledKnob(
                  icon: LucideIcons.funnel,
                  label: l10n.filter,
                  valueLabel: _hzLabel(fx.filterHz),
                  value: _hzToT(fx.filterHz),
                  min: 0.0,
                  max: 1.0,
                  onChanged: editable
                      ? (value) => ref
                            .read(equalizerProvider.notifier)
                            .setFxFilterHz(_tToHz(value))
                      : null,
                ),
                _LabeledKnob(
                  icon: LucideIcons.timerReset,
                  label: l10n.delays,
                  valueLabel: l10n.ms5(fx.delayMs.toStringAsFixed(0)),
                  value: fx.delayMs,
                  min: EqualizerNotifier.fxDelayMinMs,
                  max: EqualizerNotifier.fxDelayMaxMs,
                  onChanged: editable
                      ? (value) => ref
                            .read(equalizerProvider.notifier)
                            .setFxDelayMs(value)
                      : null,
                ),
                _LabeledKnob(
                  icon: LucideIcons.scanSearch,
                  label: l10n.size,
                  valueLabel: _percentLabel(fx.size),
                  value: fx.size,
                  min: EqualizerNotifier.fxSizeMin,
                  max: EqualizerNotifier.fxSizeMax,
                  onChanged: editable
                      ? (value) => ref
                            .read(equalizerProvider.notifier)
                            .setFxSize(value)
                      : null,
                ),
                _LabeledKnob(
                  icon: LucideIcons.audioLines,
                  label: l10n.mix,
                  valueLabel: _percentLabel(fx.mix),
                  value: fx.mix,
                  min: EqualizerNotifier.fxMixMin,
                  max: EqualizerNotifier.fxMixMax,
                  onChanged: editable
                      ? (value) =>
                            ref.read(equalizerProvider.notifier).setFxMix(value)
                      : null,
                ),
                _LabeledKnob(
                  icon: LucideIcons.rotateCcw,
                  label: l10n.feedback,
                  valueLabel: _percentLabel(fx.feedback),
                  value: fx.feedback,
                  min: EqualizerNotifier.fxFeedbackMin,
                  max: EqualizerNotifier.fxFeedbackMax,
                  onChanged: editable
                      ? (value) => ref
                            .read(equalizerProvider.notifier)
                            .setFxFeedback(value)
                      : null,
                ),
                _LabeledKnob(
                  icon: LucideIcons.gitBranchPlus,
                  label: l10n.width,
                  valueLabel: _widthLabel(fx.width),
                  value: fx.width,
                  min: EqualizerNotifier.fxWidthMin,
                  max: EqualizerNotifier.fxWidthMax,
                  onChanged: editable
                      ? (value) => ref
                            .read(equalizerProvider.notifier)
                            .setFxWidth(value)
                      : null,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spacingLg),
        const _ConvolverSection(),
      ],
    );
  }
}

class _ConvolverSection extends ConsumerWidget {
  const _ConvolverSection();

  Future<void> _pickIr(BuildContext context, WidgetRef ref) async {
    final picked = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: const ['wav', 'flac', 'aiff', 'mp3', 'ogg'],
    );
    if (picked == null) return;
    final srcPath = picked.path;
    final displayName = picked.name;
    if (srcPath == null) return;
    try {
      final docs = await getApplicationDocumentsDirectory();
      final dir = Directory('${docs.path}/irs');
      if (!dir.existsSync()) dir.createSync(recursive: true);
      final stamp = DateTime.now().millisecondsSinceEpoch;
      final ext = displayName.contains('.') ? '' : '.wav';
      final storedName = '${stamp}_$displayName$ext';
      final storedPath = '${dir.path}/$storedName';
      await File(srcPath).copy(storedPath);
      ref
          .read(equalizerProvider.notifier)
          .setConvolverIr(storedPath, displayName);
      await loadConvolverIr(storedPath);
      if (context.mounted) {
        LokalToast.fromSnackBar(context, SnackBar(content: Text(l10n.loadedIr(displayName))));
      }
    } catch (e) {
      if (context.mounted) {
        LokalToast.fromSnackBar(context, SnackBar(content: Text(l10n.couldNotLoadIr(e))));
      }
    }
  }

  Future<void> _clearIr(BuildContext context, WidgetRef ref) async {
    ref.read(equalizerProvider.notifier).clearConvolverIr();
    try {
      await clearConvolverIr();
    } catch (_) {}
  }

  String _percentLabel(double value) => '${(value * 100).round()}%';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(eqEnabledProvider);
    final convolver = ref.watch(eqConvolverProvider);
    final editable = enabled && convolver.enabled;
    final hasIr = convolver.irPath != null && convolver.irPath!.isNotEmpty;

    return _DynamicsCard(
      icon: LucideIcons.audioWaveform,
      title: l10n.convolverImpulseResponse,
      subtitle: l10n.loadAnImpulseResponseForRoom,
      active: editable,
      toggleValue: convolver.enabled,
      onToggleChanged: (value) =>
          ref.read(equalizerProvider.notifier).setConvolverEnabled(value),
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.impulseResponse,
                    style: Theme.of(context).textTheme.labelSmall
                        ?.copyWith(color: context.lokal.muted2),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    convolver.irDisplayName ?? l10n.none,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: hasIr ? context.lokal.text : context.lokal.muted2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppConstants.spacingSm),
            TextButton.icon(
              onPressed: enabled ? () => _pickIr(context, ref) : null,
              icon: const Icon(LucideIcons.folderOpen, size: 18),
              label: Text(l10n.loadIr),
              style: TextButton.styleFrom(foregroundColor: context.lokal.text),
            ),
            if (hasIr)
              TextButton.icon(
                onPressed: () => _clearIr(context, ref),
                icon: const Icon(LucideIcons.trash2, size: 18),
                label: Text(l10n.clear),
                style: TextButton.styleFrom(
                  foregroundColor: context.lokal.text,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppConstants.spacingLg),
        Center(
          child: _LabeledKnob(
            icon: LucideIcons.audioLines,
            label: l10n.mix,
            valueLabel: _percentLabel(convolver.mix),
            value: convolver.mix,
            min: EqualizerNotifier.convolverMixMin,
            max: EqualizerNotifier.convolverMixMax,
            onChanged: editable
                ? (value) => ref
                      .read(equalizerProvider.notifier)
                      .setConvolverMix(value)
                : null,
          ),
        ),
      ],
    );
  }
}

class _DynamicsCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool active;
  final bool toggleValue;
  final ValueChanged<bool> onToggleChanged;
  final List<Widget> children;

  const _DynamicsCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.active,
    required this.toggleValue,
    required this.onToggleChanged,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _IconTile(icon: icon, enabled: active),
                const SizedBox(width: AppConstants.spacingMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: context.lokal.text,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(color: context.lokal.muted2),
                      ),
                    ],
                  ),
                ),
                _PillSwitch(value: toggleValue, onChanged: onToggleChanged),
              ],
            ),
            const SizedBox(height: AppConstants.spacingMd),
            const SizedBox(height: AppConstants.spacingMd),
            for (final child in children) Center(child: child),
          ],
        ),
      ),
    );
  }
}

class _ProcessingSupportNote extends StatelessWidget {
  const _ProcessingSupportNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: context.lokal.surface3,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: context.lokal.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(LucideIcons.info, size: 18, color: context.lokal.muted),
          const SizedBox(width: AppConstants.spacingSm),
          Expanded(
            child: Text(
              l10n.onAndroidTheStandardJustAudio,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: context.lokal.muted),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeSummaryRow extends StatelessWidget {
  final List<Widget> children;

  const _ModeSummaryRow({required this.children});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppConstants.spacingSm,
      runSpacing: AppConstants.spacingSm,
      children: children,
    );
  }
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingSm,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: context.lokal.surface3,
        borderRadius: BorderRadius.circular(AppConstants.radiusRound),
        border: Border.all(color: context.lokal.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: context.lokal.muted),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: context.lokal.muted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _CardHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;

  const _CardHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _IconTile(icon: icon, enabled: true),
        const SizedBox(width: AppConstants.spacingMd),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: context.lokal.text,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: context.lokal.muted2),
              ),
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: AppConstants.spacingSm),
          trailing!,
        ],
      ],
    );
  }
}

class _ValueBadge extends StatelessWidget {
  final String value;

  const _ValueBadge({required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingSm,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: context.lokal.surface2,
        borderRadius: BorderRadius.circular(AppConstants.radiusRound),
        border: Border.all(color: context.lokal.border),
      ),
      child: Text(
        value,
        style: Theme.of(context).textTheme.labelSmall
            ?.copyWith(color: context.lokal.text, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _BandTypeDropdown extends StatelessWidget {
  final ParametricBandType value;
  final ValueChanged<ParametricBandType>? onChanged;
  final bool compact;

  const _BandTypeDropdown({
    required this.value,
    required this.onChanged,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onChanged != null;
    return Container(
      constraints: BoxConstraints(
        minWidth: compact ? 0 : 152,
        maxWidth: compact ? 80 : double.infinity,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: context.lokal.surface2,
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
        border: Border.all(color: context.lokal.border),
      ),
      child: InkWell(
        onTap: !enabled ? null : () async {
          final selected = await showLokalChoiceSheet<ParametricBandType>(
            context: context,
            title: 'Filter type',
            selected: value,
            choices: [
              for (final type in ParametricBandType.values)
                LokalChoice(value: type, label: type.displayName,
                  icon: Icons.graphic_eq_rounded),
            ],
          );
          if (selected != null && context.mounted) onChanged!(selected);
        },
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Text(
                  value.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: enabled ? context.lokal.text : context.lokal.muted2,
                    fontFamily: LokalTheme.sans,
                    fontWeight: FontWeight.w600,
                    fontSize: compact ? 10 : null,
                  ),
                ),
              ),
              Icon(Icons.keyboard_arrow_down_rounded, size: compact ? 14 : 18,
                color: enabled ? context.lokal.muted : context.lokal.muted2),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeToggle extends StatelessWidget {
  final EqMode mode;
  final ValueChanged<EqMode> onChanged;

  const _ModeToggle({required this.mode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: context.lokal.surface3,
        borderRadius: BorderRadius.circular(AppConstants.radiusRound),
        border: Border.all(color: context.lokal.border),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: AppConstants.animationNormal,
            curve: Curves.easeOutCubic,
            alignment: mode == EqMode.graphic
                ? Alignment.centerLeft
                : Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Container(
                  decoration: BoxDecoration(
                    color: context.lokal.surface2,
                    borderRadius: BorderRadius.circular(
                      AppConstants.radiusRound,
                    ),
                    border: Border.all(color: context.lokal.border2),
                  ),
                ),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _ModeToggleButton(
                  label: l10n.graphic,
                  selected: mode == EqMode.graphic,
                  onTap: () => onChanged(EqMode.graphic),
                ),
              ),
              Expanded(
                child: _ModeToggleButton(
                  label: l10n.parametric,
                  selected: mode == EqMode.parametric,
                  onTap: () => onChanged(EqMode.parametric),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ModeToggleButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ModeToggleButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppConstants.radiusRound),
        onTap: onTap,
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: AppConstants.animationFast,
            style: TextStyle(
              fontFamily: LokalTheme.sans,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected ? context.lokal.text : context.lokal.muted2,
            ),
            child: Text(label),
          ),
        ),
      ),
    );
  }
}

class _PillSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _PillSwitch({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: AppConstants.animationFast,
        width: 48,
        height: 28,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: value ? context.lokal.accent : context.lokal.surface3,
          border: Border.all(
            color: value ? Colors.transparent : context.lokal.border2,
            width: 1,
          ),
        ),
        child: AnimatedAlign(
          duration: AppConstants.animationFast,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: value ? context.lokal.onAccent : context.lokal.muted2,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingMd,
            vertical: AppConstants.spacingSm,
          ),
          decoration: BoxDecoration(
            color: context.lokal.surface2,
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            border: Border.all(color: context.lokal.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: context.responsiveIcon(AppConstants.iconSizeSm),
                color: context.lokal.text,
              ),
              const SizedBox(width: AppConstants.spacingSm),
              Text(
                label,
                style: TextStyle(
                  fontFamily: LokalTheme.sans,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: context.lokal.text,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconTile extends StatelessWidget {
  final IconData icon;
  final bool enabled;

  const _IconTile({required this.icon, required this.enabled});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.scaleSize(AppConstants.containerSizeSm),
      height: context.scaleSize(AppConstants.containerSizeSm),
      decoration: BoxDecoration(
        color: enabled ? context.lokal.surface3 : context.lokal.surface2,
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
      ),
      child: Icon(
        icon,
        color: enabled ? context.lokal.muted : context.lokal.muted2,
        size: context.responsiveIcon(AppConstants.iconSizeMd),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 10),
      child: Semantics(
        header: true,
        child: Text(
          title.toUpperCase(),
          style: LokalTheme.label(context.lokal),
        ),
      ),
    );
  }
}

/// A section card: the theme's solid surface and border, never a blur.
class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(child: LokalSettingsCard(child: child));
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        height: 1,
        margin: EdgeInsets.only(left: 56 + AppConstants.spacingMd),
        color: context.lokal.border,
      ),
    );
  }
}
