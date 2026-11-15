import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flick/widgets/lokal/lokal_toast.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flick/providers/providers.dart';
import 'package:flick/services/android_audio_device_service.dart';
import 'package:flick/services/bluetooth_service.dart';
import 'package:flick/services/uac2_preferences_service.dart';
import 'package:flick/l10n/l10n.dart';
import 'package:flick/core/theme/lokal_theme.dart';
import 'package:flick/core/theme/lokal_tokens.dart';
import 'package:flick/widgets/lokal/settings/lokal_settings_kit.dart';

class BluetoothSettingsScreen extends ConsumerStatefulWidget {
  const BluetoothSettingsScreen({super.key});

  @override
  ConsumerState<BluetoothSettingsScreen> createState() =>
      _BluetoothSettingsScreenState();
}

class _BluetoothSettingsScreenState
    extends ConsumerState<BluetoothSettingsScreen> {
  final _bt = BluetoothService.instance;
  final _uac2Prefs = Uac2PreferencesService();
  PermissionStatus _permStatus = PermissionStatus.denied;
  List<BluetoothDeviceDto> _devices = const [];
  final Map<String, BluetoothCodecStatusDto?> _codecs = {};
  final Map<String, int?> _batteries = {};
  StreamSubscription<Map<Object?, Object?>>? _btSub;
  bool _refreshing = false;

  @override
  void initState() {
    super.initState();
    _checkPermission();
    _btSub = _bt.deviceEvents.listen((_) => _refreshDevices());
  }

  @override
  void dispose() {
    _btSub?.cancel();
    super.dispose();
  }

  Future<void> _checkPermission() async {
    final status = await Permission.bluetoothConnect.status;
    if (!mounted) return;
    setState(() => _permStatus = status);
    if (status.isGranted) _refreshDevices();
  }

  Future<void> _requestPermission() async {
    final status = await Permission.bluetoothConnect.request();
    if (!mounted) return;
    setState(() => _permStatus = status);
    if (status.isGranted) _refreshDevices();
  }

  Future<void> _refreshDevices() async {
    if (_refreshing) return;
    _refreshing = true;
    final devices = await _bt.getBondedDevices();
    if (!mounted) {
      _refreshing = false;
      return;
    }
    setState(() {
      _devices = devices;
      _codecs.clear();
      _batteries.clear();
    });
    for (final d in devices) {
      if (d.isA2dp && d.isConnected) {
        final codec = await _bt.getCodecStatus(d.address);
        if (mounted) setState(() => _codecs[d.address] = codec);
      }
      final battery = await _bt.getBatteryLevel(d.address);
      if (mounted) setState(() => _batteries[d.address] = battery);
    }
    _refreshing = false;
  }

  BluetoothDeviceDto? get _targetDevice {
    final pref = ref.read(appPreferencesProvider).preferredBluetoothDevice;
    BluetoothDeviceDto? byAddress(bool Function(BluetoothDeviceDto) test) =>
        _devices.where(test).firstOrNull;
    // preferred + connected first, then any connected A2DP, then preferred, then first.
    return byAddress((d) => d.address == pref && d.isConnected && d.isA2dp) ??
        byAddress((d) => d.isConnected && d.isA2dp) ??
        byAddress((d) => d.address == pref) ??
        byAddress((d) => d.isA2dp) ??
        (_devices.isEmpty ? null : _devices.first);
  }

  String _deviceSubtitle(BluetoothDeviceDto d) {
    final parts = <String>[
      if (d.isConnected) l10n.connected else l10n.paired,
      if (d.isA2dp) 'A2DP',
    ];
    final codec = _codecs[d.address];
    if (codec != null) parts.add(codec.codecName);
    if (codec?.sampleRate != null) parts.add(l10n.hz6(codec!.sampleRate!));
    final battery = _batteries[d.address];
    if (battery != null) parts.add(l10n.battery(battery));
    return parts.join(' \u2022 ');
  }

  /// Push the full codec configuration to the target device.
  Future<void> _applyCurrentCodec({int? overrideCodec}) async {
    final target = _targetDevice;
    if (target == null) return;
    final prefs = ref.read(appPreferencesProvider);
    final codecType = overrideCodec ?? prefs.btPreferredCodec;
    if (codecType < 0) return;
    final isLdac = codecType == BluetoothCodecType.ldac;
    final result = await _bt.setCodecConfig(
      address: target.address,
      codecType: codecType,
      sampleRate: prefs.btSampleRate,
      bitsPerSample: isLdac ? prefs.btLdacBitsPerSample : 0,
      ldacBitrate: isLdac
          ? BtLdacBitrate.fromName(prefs.btLdacBitrate).kbps
          : 0,
    );
    if (!mounted) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    if (result.ok) {
      LokalToast.fromSnackBar(context, 
        SnackBar(
          content: Text(l10n.codecApplied(BluetoothCodecType.label(codecType))),
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      LokalToast.fromSnackBar(context, 
        SnackBar(
          content: Text(l10n.codecForcingUnavailableOnThisDevice),
          action: SnackBarAction(
            label: l10n.open,
            onPressed: () => _bt.openBluetoothCodecSettings(),
          ),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  Future<void> _openBluetoothCodecSettings() async {
    final ok = await _bt.openBluetoothCodecSettings();
    if (!mounted) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (!ok && messenger != null) {
      LokalToast.fromSnackBar(context, 
        SnackBar(
          content: Text(l10n.developerOptionsIsDisabledEnableIt),
          duration: Duration(seconds: 5),
        ),
      );
    }
  }

  Future<void> _onCodecControlEnabled(bool enabled) async {
    await ref
        .read(appPreferencesProvider.notifier)
        .setBtEnableCodecControl(enabled);
    if (enabled) await _applyCurrentCodec();
  }

  Future<void> _onCodecSelected(int codecType) async {
    await ref
        .read(appPreferencesProvider.notifier)
        .setBtPreferredCodec(codecType);
    await _applyCurrentCodec(overrideCodec: codecType);
  }

  Future<void> _onSampleRateSelected(int bitmask) async {
    await ref.read(appPreferencesProvider.notifier).setBtSampleRate(bitmask);
    await _applyCurrentCodec();
  }

  Future<void> _onLdacBitsSelected(int bitmask) async {
    await ref
        .read(appPreferencesProvider.notifier)
        .setBtLdacBitsPerSample(bitmask);
    await _applyCurrentCodec();
  }

  Future<void> _onLdacBitrateSelected(BtLdacBitrate bitrate) async {
    await ref
        .read(appPreferencesProvider.notifier)
        .setBtLdacBitrate(bitrate.name);
    await _applyCurrentCodec();
  }

  Future<void> _onAbsoluteVolumeChanged(bool enabled) async {
    ref.read(appPreferencesProvider.notifier).setBtAbsoluteVolumeSync(enabled);
    for (final d in _devices.where((d) => d.isConnected)) {
      await _bt.setAbsoluteVolumeEnabled(d.address, enabled);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appPrefs = ref.watch(appPreferencesProvider);
    final notifier = ref.read(appPreferencesProvider.notifier);
    final hasPermission = _permStatus.isGranted;
    final currentLdac = BtLdacBitrate.fromName(appPrefs.btLdacBitrate);
    final codecControlOn = appPrefs.btEnableCodecControl;
    final isLdac = appPrefs.btPreferredCodec == BluetoothCodecType.ldac;

    return LokalSettingsScaffold(
      title: l10n.bluetooth,
      subtitle: 'Headphones, speakers and how playback follows them.',
      children: [
        if (!hasPermission)
          LokalSettingsSection(
            title: l10n.permission,
            children: [
              LokalSettingRow(
                label: l10n.grantBluetoothAccess,
                description: l10n.requiredToDetectDevicesCodecsAnd,
                icon: Icons.verified_user_rounded,
                trailing: LokalSettingButton(
                  label: 'Allow',
                  onPressed: _requestPermission,
                ),
                onTap: _requestPermission,
              ),
            ],
          ),
        LokalSettingsSection(
          title: l10n.connectionBehavior,
          children: [
            LokalSettingRow.toggle(
              label: l10n.pauseOnDisconnect,
              description: appPrefs.pauseOnBluetoothDisconnect
                  ? l10n.playbackPausesWhenBluetoothOrHeadphones
                  : l10n.playbackContinuesWhenAudioOutput,
              value: appPrefs.pauseOnBluetoothDisconnect,
              onChanged: notifier.setPauseOnBluetoothDisconnect,
            ),
            LokalSettingRow.toggle(
              label: l10n.pauseOnBluetoothConnect,
              description: appPrefs.pauseOnBluetoothConnect
                  ? l10n.playbackPausesWhenABluetoothAudio
                  : l10n.playbackContinuesWhenABluetoothDevice,
              value: appPrefs.pauseOnBluetoothConnect,
              onChanged: notifier.setPauseOnBluetoothConnect,
            ),
            LokalSettingRow.toggle(
              label: l10n.resumeOnReconnect,
              description: appPrefs.resumeOnBluetoothReconnect
                  ? l10n.playbackResumesWhenADeviceReconnects
                  : l10n.keepPlaybackPausedWhenADevice,
              value: appPrefs.resumeOnBluetoothReconnect,
              onChanged: notifier.setResumeOnBluetoothReconnect,
            ),
            LokalSettingRow.toggle(
              label: l10n.pauseOnUsbDacAttach,
              description: appPrefs.pauseOnUsbDacConnect
                  ? l10n.playbackPausesWhenAUsbDac
                  : l10n.playbackContinuesWhenAUsbDac,
              value: appPrefs.pauseOnUsbDacConnect,
              onChanged: notifier.setPauseOnUsbDacConnect,
            ),
            LokalSettingRow.toggle(
              label: l10n.pauseOnUsbDacDetach,
              description: appPrefs.pauseOnUsbDacDisconnect
                  ? l10n.playbackPausesWhenAUsbDac2
                  : l10n.playbackContinuesWhenAUsbDac2,
              value: appPrefs.pauseOnUsbDacDisconnect,
              onChanged: notifier.setPauseOnUsbDacDisconnect,
            ),
          ],
        ),
        if (hasPermission && _devices.isNotEmpty)
          LokalSettingsSection(
            title: l10n.devices,
            children: [
              LokalSettingRow.option(
                label: l10n.automatic,
                description: l10n.letAndroidChooseTheOutputDevice,
                selected: appPrefs.preferredBluetoothDevice.isEmpty,
                onTap: () => notifier.setPreferredBluetoothDevice(''),
              ),
              for (final d in _devices)
                LokalSettingRow.option(
                  icon: d.isConnected
                      ? Icons.headphones_rounded
                      : Icons.bluetooth_rounded,
                  label: d.name,
                  description: _deviceSubtitle(d),
                  selected: appPrefs.preferredBluetoothDevice == d.address,
                  onTap: () => notifier.setPreferredBluetoothDevice(d.address),
                ),
            ],
          ),
        LokalSettingsSection(
          title: l10n.codecU0026Audio,
          heading: '${l10n.codecU0026Audio} · ${l10n.experimental}',
          children: [
            LokalSettingRow.toggle(
              label: l10n.codecControl,
              description: codecControlOn
                  ? l10n.flickWillForceYourChosenCodec
                  : l10n.letAndroidNegotiateTheCodecAutomatically,
              value: codecControlOn,
              onChanged: _onCodecControlEnabled,
            ),
            if (codecControlOn) ...[
              LokalSettingChoice<int>(
                label: 'Codec',
                description: _codecDescription(appPrefs.btPreferredCodec),
                value: appPrefs.btPreferredCodec,
                options: [
                  for (final ct in _codecOptions)
                    LokalSegment(
                      ct,
                      _codecLabel(ct),
                      description: _codecDescription(ct),
                    ),
                ],
                onChanged: _onCodecSelected,
              ),
              LokalSettingChoice<int>(
                label: l10n.sampleRate,
                value: appPrefs.btSampleRate,
                options: [
                  for (final e in BtSampleRate.entries)
                    LokalSegment(e.$1, e.$2),
                ],
                onChanged: _onSampleRateSelected,
              ),
              if (isLdac) ...[
                LokalSettingChoice<int>(
                  label: l10n.ldacBitsPerSample,
                  value: appPrefs.btLdacBitsPerSample,
                  options: [
                    for (final e in BtBitsPerSample.entries)
                      LokalSegment(e.$1, e.$2),
                  ],
                  onChanged: _onLdacBitsSelected,
                ),
                LokalSettingChoice<BtLdacBitrate>(
                  label: 'LDAC bitrate',
                  description: _ldacBitrateDescription(currentLdac),
                  value: currentLdac,
                  options: [
                    for (final b in BtLdacBitrate.values)
                      LokalSegment(
                        b,
                        _ldacBitrateLabel(b),
                        description: _ldacBitrateDescription(b),
                      ),
                  ],
                  onChanged: _onLdacBitrateSelected,
                ),
              ],
              LokalSettingLink(
                label: l10n.openBluetoothCodecSettings,
                description: l10n.androidDeveloperOptionsTheReliableWay,
                onTap: _openBluetoothCodecSettings,
              ),
            ],
            LokalSettingRow.toggle(
              label: l10n.absoluteVolumeSync,
              description: appPrefs.btAbsoluteVolumeSync
                  ? l10n.phoneAndHeadsetVolumeAreLinked
                  : l10n.phoneAndHeadsetVolumeAreIndependent,
              value: appPrefs.btAbsoluteVolumeSync,
              onChanged: _onAbsoluteVolumeChanged,
            ),
          ],
        ),
        LokalSettingsSection(
          title: l10n.outputMode,
          heading: '${l10n.outputMode} · ${l10n.experimental}',
          children: [
            LokalSettingCustom(
              label: l10n.hiResDirect,
              child: ValueListenableBuilder<bool>(
                valueListenable: Uac2PreferencesService.btHiResDirectNotifier,
                builder: (context, hiRes, _) => LokalSettingRow.toggle(
                  label: l10n.hiResDirect,
                  description: hiRes
                      ? l10n.routesBluetoothThroughTheHiRes
                      : l10n.standardBluetoothRoutingViaAndroid,
                  value: hiRes,
                  onChanged: (v) => _uac2Prefs.setBtHiResDirect(v),
                ),
              ),
            ),
            LokalSettingCustom(
              label: l10n.lowLatencyMode,
              child: ValueListenableBuilder<bool>(
                valueListenable:
                    Uac2PreferencesService.btLowLatencyModeNotifier,
                builder: (context, lowLatency, _) => LokalSettingRow.toggle(
                  label: l10n.lowLatencyMode,
                  description: lowLatency
                      ? l10n.routesBluetoothThroughTheRustEngine
                      : l10n.standardBluetoothRoutingViaAndroid,
                  value: lowLatency,
                  onChanged: (v) => _uac2Prefs.setBtLowLatencyMode(v),
                ),
              ),
            ),
          ],
        ),
        LokalSettingsSection(
          title: l10n.codecInfo,
          children: [
            ValueListenableBuilder<AndroidPlaybackDeviceInfo>(
              valueListenable:
                  AndroidAudioDeviceService.instance.deviceInfoNotifier,
              builder: (context, deviceInfo, _) {
                final target = _targetDevice;
                final negotiated = target == null
                    ? null
                    : _codecs[target.address];
                return _BluetoothCodecInfo(
                  deviceInfo: deviceInfo,
                  negotiated: negotiated,
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}

const _codecOptions = <int>[
  -1,
  BluetoothCodecType.sbc,
  BluetoothCodecType.aac,
  BluetoothCodecType.aptx,
  BluetoothCodecType.aptxHd,
  BluetoothCodecType.aptxAdaptive,
  BluetoothCodecType.ldac,
];

String _codecLabel(int ct) =>
    ct < 0 ? l10n.automatic : BluetoothCodecType.label(ct);

String _codecDescription(int ct) => switch (ct) {
  -1 => l10n.letAndroidChooseTheBestCodec,
  BluetoothCodecType.sbc => l10n.universalCompatibility,
  BluetoothCodecType.aac => l10n.highQualityWidelySupported,
  BluetoothCodecType.aptx => l10n.lowLatencyGoodQuality,
  BluetoothCodecType.aptxHd => l10n.highResolutionAptx,
  BluetoothCodecType.aptxAdaptive => l10n.variableBitrateLowLatency,
  BluetoothCodecType.ldac => l10n.highestBitrateUpTo990Kbps,
  _ => '',
};

String _ldacBitrateLabel(BtLdacBitrate b) => switch (b) {
  BtLdacBitrate.adaptive => l10n.ldacAdaptive,
  BtLdacBitrate.kbps330 => l10n.ldac330Kbps,
  BtLdacBitrate.kbps660 => l10n.ldac660Kbps,
  BtLdacBitrate.kbps990 => l10n.ldac990Kbps,
};

String _ldacBitrateDescription(BtLdacBitrate b) => switch (b) {
  BtLdacBitrate.adaptive => l10n.bitrateAdjustsToSignalQuality,
  BtLdacBitrate.kbps330 => l10n.prioritiseConnectionStability,
  BtLdacBitrate.kbps660 => l10n.balancedQualityAndStability,
  BtLdacBitrate.kbps990 => l10n.maximumAudioQuality,
};

class _BluetoothCodecInfo extends StatelessWidget {
  const _BluetoothCodecInfo({required this.deviceInfo, this.negotiated});

  final AndroidPlaybackDeviceInfo deviceInfo;
  final BluetoothCodecStatusDto? negotiated;

  @override
  Widget build(BuildContext context) {
    final t = context.lokal;
    final negotiatedLine = StringBuffer();
    if (negotiated != null) {
      negotiatedLine.write(l10n.negotiated(negotiated!.codecName));
      if (negotiated!.sampleRate != null) {
        negotiatedLine.write(' • ${_formatHz(negotiated!.sampleRate!)}');
      }
      if (negotiated!.bitsPerSample != null) {
        negotiatedLine.write(l10n.u2022Bit(negotiated!.bitsPerSample!));
      }
    }
    final currentRouteLabel = deviceInfo.isBluetoothRoute
        ? l10n.currentRoute(deviceInfo.routeSummary)
        : l10n.whenYouPlayOverBluetoothAndroid;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.bluetoothCodecInfo,
            style: TextStyle(
              fontFamily: LokalTheme.sans,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: t.text,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            currentRouteLabel,
            style: TextStyle(fontSize: 12.5, height: 1.35, color: t.muted),
          ),
          if (negotiatedLine.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              negotiatedLine.toString().toUpperCase(),
              style: LokalTheme.label(t, size: 11.5, color: t.accent),
            ),
          ],
          const SizedBox(height: 14),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final codec in [
                'SBC',
                'AAC',
                'aptX',
                l10n.aptxHd,
                l10n.aptxAdaptive,
                'LDAC',
                'LC3',
                'LHDC',
              ])
                LokalStatusPill(label: codec),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            l10n.flickCanAttemptToPreferA,
            style: TextStyle(fontSize: 13, height: 1.4, color: t.text),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.youCanAlsoChangeTheCodec,
            style: TextStyle(fontSize: 12, height: 1.4, color: t.muted),
          ),
        ],
      ),
    );
  }
}

String _formatHz(int hz) {
  if (hz >= 1000) {
    final khz = hz / 1000.0;
    return '${khz.toStringAsFixed(khz == khz.roundToDouble() ? 1 : 1)} kHz';
  }
  return l10n.hz3(hz);
}
