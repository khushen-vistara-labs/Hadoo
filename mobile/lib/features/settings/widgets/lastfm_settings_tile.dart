import 'package:flutter/material.dart';
import 'package:flick/widgets/lokal/lokal_toast.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flick/providers/lastfm_provider.dart';
import 'package:flick/core/utils/dev_log.dart';
import 'package:flick/core/theme/lokal_tokens.dart';
import 'package:flick/widgets/lokal/settings/lokal_settings_kit.dart';
import 'package:flick/l10n/l10n.dart';

/// Self-contained Last.fm connect/disconnect tile.
class LastFmSettingsTile extends ConsumerStatefulWidget {
  const LastFmSettingsTile({super.key});

  @override
  ConsumerState<LastFmSettingsTile> createState() => _LastFmSettingsTileState();
}

class _LastFmSettingsTileState extends ConsumerState<LastFmSettingsTile>
    with WidgetsBindingObserver {
  bool _awaitingCallback = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    devLog(
      '[LastFm] App lifecycle changed: $state, _awaitingCallback=$_awaitingCallback',
    );
    if (state == AppLifecycleState.resumed && _awaitingCallback) {
      devLog('[LastFm] App resumed after auth, completing authentication');
      _awaitingCallback = false;
      _completeAuth();
    }
  }

  Future<void> _startAuth() async {
    devLog('[LastFm] _startAuth: Starting authentication flow');
    final auth = ref.read(lastFmAuthServiceProvider);

    // Check if API credentials are configured
    devLog('[LastFm] _startAuth: Checking API credentials');
    final hasCredentials = await auth.hasValidApiCredentials();
    devLog('[LastFm] _startAuth: Has valid credentials: $hasCredentials');

    if (!hasCredentials) {
      devLog('[LastFm] _startAuth: Missing credentials, showing error');
      _showError(
        'Please configure your Last.fm API key and shared secret first.',
      );
      return;
    }

    try {
      devLog('[LastFm] _startAuth: Calling getTokenAndLaunchAuth');
      await auth.getTokenAndLaunchAuth();
      devLog(
        '[LastFm] _startAuth: Successfully launched auth, mounted=$mounted',
      );

      if (mounted) {
        setState(() => _awaitingCallback = true);
        devLog('[LastFm] _startAuth: Set _awaitingCallback=true');
      }
    } catch (e, stackTrace) {
      devLog('[LastFm] _startAuth: ERROR - $e');
      devLog('[LastFm] _startAuth: Stack trace: $stackTrace');

      if (mounted) {
        // Provide more specific error message for network issues
        final errorMessage =
            e.toString().contains('SocketException') ||
                e.toString().contains('Failed host lookup')
            ? l10n.noInternetConnectionPleaseCheckYour
            : l10n.couldNotConnectToLastFm;

        _showError(errorMessage);
      } else {
        devLog(
          '[LastFm] _startAuth: Widget not mounted, skipping error display',
        );
      }
    }
  }

  Future<void> _completeAuth() async {
    devLog('[LastFm] _completeAuth: Starting token exchange');
    final auth = ref.read(lastFmAuthServiceProvider);
    try {
      await auth.exchangeTokenForSession();
      devLog('[LastFm] _completeAuth: Token exchange successful');
      ref.invalidate(lastFmSessionProvider);
      _showSuccess(l10n.lastFmConnected2);
    } catch (e, stackTrace) {
      devLog('[LastFm] _completeAuth: ERROR - $e');
      devLog('[LastFm] _completeAuth: Stack trace: $stackTrace');
      _showError(
        'Authorization failed. Make sure you approved access on Last.fm.',
      );
    }
  }

  Future<void> _disconnect() async {
    final confirmed = await showLokalConfirmSheet(
      context: context,
      useRootNavigator: true,
      title: l10n.disconnectLastFm,
      message: l10n.yourScrobblingHistoryWillRemainOn,
      confirmLabel: l10n.disconnect,
      cancelLabel: l10n.cancel,
      destructive: true,
    );

    if (!confirmed) {
      return;
    }

    final auth = ref.read(lastFmAuthServiceProvider);
    await auth.disconnect();
    ref.invalidate(lastFmSessionProvider);
  }

  Future<void> _showApiKeyDialog({bool autoConnectAfterSave = false}) async {
    final auth = ref.read(lastFmAuthServiceProvider);
    final creds = await auth.getApiCredentials();

    final apiKeyController = TextEditingController(text: creds.apiKey ?? '');
    final sharedSecretController = TextEditingController(
      text: creds.sharedSecret ?? '',
    );
    bool obscureSecret = true;

    if (!mounted) return;

    try {
      await showLokalSettingsSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (ctx) => StatefulBuilder(
          builder: (ctx, setState) {
            final t = ctx.lokal;
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                child: LokalSheetBody(
                  title: l10n.lastFmConfiguration,
                  message: l10n.connectToScrobbleYourMusic,
                  children: [
                    LokalSettingsCard(
                      color: t.surface2,
                      child: LokalSettingRow(
                        label: l10n.getYourApiCredentials,
                        description: 'last.fm/api/account/create',
                        trailing: Icon(
                          Icons.open_in_new_rounded,
                          size: 18,
                          color: t.muted,
                        ),
                        onTap: () {
                          launchUrl(
                            Uri.parse('https://www.last.fm/api/account/create'),
                            mode: LaunchMode.externalApplication,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: apiKeyController,
                      style: TextStyle(color: t.text),
                      decoration: lokalInputDecoration(
                        ctx,
                        label: l10n.apiKey,
                        hint: l10n.enterYourApiKey,
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: sharedSecretController,
                      obscureText: obscureSecret,
                      style: TextStyle(color: t.text),
                      decoration: lokalInputDecoration(
                        ctx,
                        label: l10n.sharedSecret,
                        hint: l10n.enterYourSharedSecret,
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureSecret
                                ? Icons.visibility_rounded
                                : Icons.visibility_off_rounded,
                            color: t.muted,
                          ),
                          onPressed: () {
                            setState(() => obscureSecret = !obscureSecret);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: LokalSettingsActionButton(
                            label: l10n.cancel,
                            primary: false,
                            expand: true,
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: LokalSettingsActionButton(
                            label: l10n.saveConnect,
                            expand: true,
                            onPressed: () async {
                              devLog('[LastFm] Save & Connect button pressed');

                              if (apiKeyController.text.isEmpty ||
                                  sharedSecretController.text.isEmpty) {
                                devLog('[LastFm] Empty credentials provided');
                                _showError(
                                  'Please enter both API key and shared secret',
                                );
                                return;
                              }

                              devLog('[LastFm] Saving credentials...');
                              await auth.setApiCredentials(
                                apiKeyController.text,
                                sharedSecretController.text,
                              );
                              devLog(
                                '[LastFm] Credentials saved, mounted=$mounted',
                              );

                              if (mounted) {
                                if (ctx.mounted) Navigator.pop(ctx);
                                devLog('[LastFm] Dialog closed');

                                _showSuccess(l10n.credentialsSavedSuccessfully);

                                if (autoConnectAfterSave && mounted) {
                                  devLog(
                                    '[LastFm] Auto-connect enabled, waiting 300ms...',
                                  );
                                  // Small delay to ensure dialog is fully closed
                                  await Future.delayed(
                                    const Duration(milliseconds: 300),
                                  );
                                  devLog(
                                    '[LastFm] Delay complete, mounted=$mounted',
                                  );

                                  if (mounted) {
                                    devLog('[LastFm] Calling _startAuth()');
                                    await _startAuth();
                                  } else {
                                    devLog(
                                      '[LastFm] Widget unmounted, skipping auth',
                                    );
                                  }
                                }
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    } finally {
      apiKeyController.dispose();
      sharedSecretController.dispose();
    }
  }

  void _showError(String message) {
    if (!mounted) {
      return;
    }
    LokalToast.fromSnackBar(context, SnackBar(content: Text(message)));
  }

  void _showSuccess(String message) {
    if (!mounted) {
      return;
    }
    LokalToast.fromSnackBar(context, SnackBar(content: Text(message)));
  }

  Future<void> _showConnectedBottomSheet(String username) async {
    await showLokalSettingsSheet<void>(
      context: context,
      builder: (ctx) => LokalSheetBody(
        title: l10n.lastFmConnected,
        message: l10n.yourMusicIsBeingScrobbled,
        children: [
          LokalSettingsCard(
            color: ctx.lokal.surface2,
            child: LokalSettingRow(
              label: username,
              description: l10n.connectedAccount,
              trailing: const LokalStatusPill(label: 'Connected', active: true),
            ),
          ),
          const SizedBox(height: 16),
          LokalSettingsActionButton(
            label: l10n.editCredentials,
            icon: Icons.edit_rounded,
            primary: false,
            expand: true,
            onPressed: () {
              Navigator.pop(ctx);
              _showApiKeyDialog();
            },
          ),
          const SizedBox(height: 10),
          LokalSettingsActionButton(
            label: l10n.disconnect,
            icon: Icons.logout_rounded,
            destructive: true,
            expand: true,
            onPressed: () {
              Navigator.pop(ctx);
              _disconnect();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sessionAsync = ref.watch(lastFmSessionProvider);
    final t = context.lokal;

    return sessionAsync.when(
      loading: () =>
          LokalSettingRow(label: l10n.lastFm, description: l10n.loadingSession),
      error: (error, stackTrace) => LokalSettingRow(
        label: l10n.lastFm,
        description: l10n.couldNotLoadSession,
        onTap: _startAuth,
        trailing: Icon(Icons.chevron_right_rounded, size: 22, color: t.muted),
      ),
      data: (session) {
        if (session != null) {
          return LokalSettingRow(
            label: l10n.lastFm,
            description: l10n.connectedAs(session.username),
            onTap: () => _showConnectedBottomSheet(session.username),
            trailing: const LokalStatusPill(label: 'Connected', active: true),
          );
        }
        return LokalSettingRow(
          label: l10n.lastFm,
          description: _awaitingCallback
              ? l10n.waitingForBrowserAuthorization
              : l10n.connectToScrobbleYourListeningHistory,
          onTap: _awaitingCallback
              ? null
              : () {
                  _showApiKeyDialog(autoConnectAfterSave: true);
                },
          trailing: _awaitingCallback
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: t.accent,
                  ),
                )
              : LokalSettingButton(
                  label: l10n.connect,
                  onPressed: () =>
                      _showApiKeyDialog(autoConnectAfterSave: true),
                ),
        );
      },
    );
  }
}
