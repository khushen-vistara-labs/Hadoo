import 'package:flutter/material.dart';
import 'package:flick/core/theme/lokal_tokens.dart';
import 'package:flick/widgets/lokal/lokal_choice_sheet.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flick/core/theme/app_colors.dart';
import 'package:flick/core/theme/adaptive_color_provider.dart';
import 'package:flick/core/constants/app_constants.dart';
import 'package:flick/providers/providers.dart';
import 'package:flick/services/uac2_service.dart';
import 'package:flick/l10n/l10n.dart';

class Uac2StreamConfig extends ConsumerStatefulWidget {
  final Uac2DeviceInfo device;

  const Uac2StreamConfig({
    required this.device,
    super.key,
  });

  @override
  ConsumerState<Uac2StreamConfig> createState() => _Uac2StreamConfigState();
}

class _Uac2StreamConfigState extends ConsumerState<Uac2StreamConfig> {
  int _selectedSampleRate = 48000;
  int _selectedBitDepth = 24;
  int _selectedChannels = 2;

  @override
  Widget build(BuildContext context) {
    final capabilitiesAsync = ref.watch(
      uac2DeviceCapabilitiesProvider(widget.device),
    );
    final deviceStatus = ref.watch(uac2DeviceStatusProvider);
    final isStreaming = deviceStatus?.state == Uac2State.streaming ||
        deviceStatus?.state == Uac2State.prewarming;

    return capabilitiesAsync.when(
      data: (capabilities) {
        if (capabilities == null) {
          return _buildUnavailable(context);
        }
        return _buildConfigContent(context, capabilities, isStreaming);
      },
      loading: () => _buildLoading(context),
      error: (error, _) => _buildError(context, error),
    );
  }

  Widget _buildUnavailable(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Text(
        l10n.streamConfigurationNotAvailable,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: context.adaptiveTextTertiary,
            ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildLoading(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildError(BuildContext context, Object error) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Text(
        l10n.error(error),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.red.shade400,
            ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildConfigContent(
    BuildContext context,
    Uac2DeviceCapabilities capabilities,
    bool isStreaming,
  ) {
    final sampleRates = capabilities.supportedSampleRates.toList()..sort();
    final bitDepths = capabilities.supportedBitDepths.toList()..sort();
    final channels = capabilities.supportedChannels.toList()..sort();

    if (sampleRates.isNotEmpty && !sampleRates.contains(_selectedSampleRate)) {
      _selectedSampleRate = sampleRates.last;
    }
    if (bitDepths.isNotEmpty && !bitDepths.contains(_selectedBitDepth)) {
      _selectedBitDepth = bitDepths.last;
    }
    if (channels.isNotEmpty && !channels.contains(_selectedChannels)) {
      _selectedChannels = channels.last;
    }

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildConfigRow(
            context,
            l10n.sampleRate2,
            LucideIcons.activity,
            _choiceControl<int>(
              title: l10n.sampleRate2,
              current: _selectedSampleRate,
              values: sampleRates,
              label: (rate) => l10n.khz(rate ~/ 1000),
              enabled: !isStreaming,
              onChanged: (value) => setState(() => _selectedSampleRate = value),
            ),
          ),
          Divider(height: 1, color: AppColors.glassBorder),
          _buildConfigRow(
            context,
            l10n.bitDepth2,
            LucideIcons.layers,
            _choiceControl<int>(
              title: l10n.bitDepth2,
              current: _selectedBitDepth,
              values: bitDepths,
              label: (depth) => l10n.bit(depth),
              enabled: !isStreaming,
              onChanged: (value) => setState(() => _selectedBitDepth = value),
            ),
          ),
          Divider(height: 1, color: AppColors.glassBorder),
          _buildConfigRow(
            context,
            l10n.channels,
            LucideIcons.radio,
            _choiceControl<int>(
              title: l10n.channels,
              current: _selectedChannels,
              values: channels,
              label: (ch) => ch == 1 ? l10n.mono : ch == 2 ? l10n.stereo : l10n.channels3(ch),
              enabled: !isStreaming,
              onChanged: (value) => setState(() => _selectedChannels = value),
            ),
          ),
          const SizedBox(height: AppConstants.spacingMd),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isStreaming ? _stopStreaming : _startStreaming,
              icon: Icon(
                isStreaming ? LucideIcons.square : LucideIcons.play,
                size: 18,
              ),
              label: Text(isStreaming ? l10n.stopStreaming : l10n.startStreaming),
              style: ElevatedButton.styleFrom(
                backgroundColor: isStreaming
                    ? Colors.red.shade400
                    : AppColors.accent,
                foregroundColor: isStreaming ? Colors.white : Colors.black,
                padding: const EdgeInsets.symmetric(
                  vertical: AppConstants.spacingMd,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _choiceControl<T>({
    required String title,
    required T current,
    required List<T> values,
    required String Function(T) label,
    required bool enabled,
    required ValueChanged<T> onChanged,
  }) {
    final t = context.lokal;
    return InkWell(
      onTap: !enabled ? null : () async {
        final selected = await showLokalChoiceSheet<T>(
          context: context,
          title: title,
          selected: current,
          choices: [
            for (final value in values)
              LokalChoice(value: value, label: label(value),
                icon: Icons.graphic_eq_rounded),
          ],
        );
        if (selected != null && mounted) onChanged(selected);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: t.surface2,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: t.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label(current),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: enabled ? t.text : t.muted,
                  fontSize: 14),
              ),
            ),
            Icon(Icons.keyboard_arrow_down_rounded,
              color: enabled ? t.accent : t.muted2),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigRow(
    BuildContext context,
    String label,
    IconData icon,
    Widget control,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingSm),
      child: Row(
        children: [
          Icon(
            icon,
            color: context.adaptiveTextSecondary,
            size: 20,
          ),
          const SizedBox(width: AppConstants.spacingMd),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.adaptiveTextPrimary,
                  ),
            ),
          ),
          Expanded(
            flex: 3,
            child: control,
          ),
        ],
      ),
    );
  }

  Future<void> _startStreaming() async {
    final deviceStatusNotifier = ref.read(uac2DeviceStatusProvider.notifier);
    final format = Uac2AudioFormat(
      sampleRate: _selectedSampleRate,
      bitDepth: _selectedBitDepth,
      channels: _selectedChannels,
    );

    final success = await deviceStatusNotifier.startStreaming(format);
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.failedToStartStreaming),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _stopStreaming() async {
    final deviceStatusNotifier = ref.read(uac2DeviceStatusProvider.notifier);
    final success = await deviceStatusNotifier.stopStreaming();
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.failedToStopStreaming),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
