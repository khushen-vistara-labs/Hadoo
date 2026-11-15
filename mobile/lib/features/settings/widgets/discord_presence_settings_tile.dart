import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flick/l10n/l10n.dart';
import 'package:flick/services/discord_presence_service.dart';
import 'package:flick/widgets/lokal/settings/lokal_settings_kit.dart';

class DiscordPresenceSettingsTile extends StatelessWidget {
  const DiscordPresenceSettingsTile({super.key});

  @override
  Widget build(BuildContext context) {
    final service = DiscordPresenceService.instance;
    return ListenableBuilder(
      listenable: service,
      builder: (context, _) => LokalSettingRow.toggle(
        label: lokalText('Discord Rich Presence'),
        description: lokalText(
          '${service.status} · ${service.artworkStatus} · Share what you’re listening to',
        ),
        value: service.enabled && service.configured,
        enabled: service.configured,
        onChanged: (value) => unawaited(service.setEnabled(value)),
      ),
    );
  }
}
