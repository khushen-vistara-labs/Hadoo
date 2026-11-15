import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flick/widgets/lokal/lokal_toast.dart';
import 'package:flick/services/permission_service.dart';
import 'package:flick/widgets/lokal/settings/lokal_settings_kit.dart';

/// Shared by Data and onboarding; permission stays optional and status updates
/// when returning from Android's battery settings.
class BatteryOptimizationSetting extends StatefulWidget {
  const BatteryOptimizationSetting({super.key});

  @override
  State<BatteryOptimizationSetting> createState() =>
      _BatteryOptimizationSettingState();
}

class _BatteryOptimizationSettingState extends State<BatteryOptimizationSetting>
    with WidgetsBindingObserver {
  bool? _allowed;
  bool _opening = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refresh();
  }

  Future<void> _refresh() async {
    try {
      final allowed = await PermissionService()
          .isIgnoringBatteryOptimizations();
      if (mounted) setState(() => _allowed = allowed);
    } catch (_) {
      if (mounted) setState(() => _allowed = null);
    }
  }

  Future<void> _open() async {
    setState(() => _opening = true);
    try {
      final opened = await PermissionService()
          .requestIgnoreBatteryOptimizations();
      if (!opened) throw StateError('Android did not open battery settings.');
      await _refresh();
    } catch (_) {
      if (mounted)
        LokalToast.fromSnackBar(context, 
          const SnackBar(
            content: Text(
              'Couldn’t open battery settings. Try Android Settings › Apps › Hadoo › Battery.',
            ),
          ),
        );
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!Platform.isAndroid) return const SizedBox.shrink();
    return LokalSettingRow(
      icon: Icons.battery_full_rounded,
      label: 'Battery optimization',
      description: _allowed == true
          ? 'Unrestricted. Android allows Hadoo to keep playing and copying files in the background.'
          : 'Allow background playback, scans and file transfers when the screen is off. Optional; some phones also have their own battery restrictions.',
      trailing: LokalSettingButton(
        label: _allowed == true ? 'Allowed' : 'Allow',
        onPressed: _opening || _allowed == true ? null : _open,
      ),
    );
  }
}
