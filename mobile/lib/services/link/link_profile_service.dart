import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/lokal_remote_state.dart';
import 'link_sync_coordinator.dart';

class LinkedProfile {
  const LinkedProfile({
    required this.username,
    required this.displayName,
    this.avatarPath,
  });
  final String username, displayName;
  final String? avatarPath;
}

/// The paired desktop account supplies the You identity after merge consent.
/// The avatar is copied locally so the profile also works when the PC is off.
class LinkProfileService {
  static String _key(LokalRemoteCredentials credentials) =>
      '${LinkSyncCoordinator.prefixFor(credentials)}.profile';

  static Future<LinkedProfile?> load(LokalRemoteCredentials credentials) async {
    final raw = (await SharedPreferences.getInstance()).getString(
      _key(credentials),
    );
    if (raw == null) return null;
    final profile = jsonDecode(raw) as Map;
    return LinkedProfile(
      username: profile['username'] as String? ?? '',
      displayName: profile['displayName'] as String? ?? '',
      avatarPath: profile['avatarPath'] as String?,
    );
  }

  static Future<void> sync(LokalRemoteCredentials credentials) async {
    final client = http.Client();
    final headers = {
      'x-remote-token': credentials.remoteToken,
      if (credentials.apiKey.isNotEmpty) 'x-api-key': credentials.apiKey,
    };
    try {
      final response = await client
          .get(
            credentials.origin.replace(path: '/api/remote/profile'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 10));
      // Older desktops can still merge history/library without this extension.
      if (response.statusCode == 404) return;
      if (response.statusCode != 200)
        throw const HttpException('Desktop profile is unavailable.');
      final value = jsonDecode(response.body) as Map;
      final prefs = await SharedPreferences.getInstance();
      final key = _key(credentials);
      if (value['profile'] == null) {
        await prefs.remove(key);
        return;
      }
      final profile = Map<String, dynamic>.from(value['profile'] as Map);
      final old = jsonDecode(prefs.getString(key) ?? '{}') as Map;
      String? avatarPath;
      if (profile['hasAvatar'] == true) {
        final previousPath = old['avatarPath'] as String?;
        if (old['avatarVersion'] == profile['avatarVersion'] &&
            previousPath != null &&
            await File(previousPath).exists()) {
          avatarPath = previousPath;
        } else {
          final request =
              http.Request(
                  'GET',
                  credentials.origin.replace(
                    path: '/api/remote/profile/avatar',
                  ),
                )
                ..headers.addAll(headers)
                ..followRedirects = false;
          final avatar = await client
              .send(request)
              .timeout(const Duration(seconds: 10));
          if (avatar.statusCode != 200)
            throw const HttpException(
              'Desktop profile picture is unavailable.',
            );
          final bytes = <int>[];
          await for (final chunk in avatar.stream.timeout(
            const Duration(seconds: 10),
          )) {
            bytes.addAll(chunk);
            if (bytes.length > 5 * 1024 * 1024)
              throw const FormatException(
                'Desktop profile picture is too large.',
              );
          }
          final directory = Directory(
            '${(await getApplicationSupportDirectory()).path}/link_profiles',
          );
          await directory.create(recursive: true);
          // Versioned filenames also invalidate Flutter's FileImage cache.
          final name = sha256
              .convert(utf8.encode('$key:${profile['avatarVersion']}'))
              .toString();
          final file = File('${directory.path}/$name');
          final part = File('${file.path}.part');
          try {
            await part.writeAsBytes(bytes, flush: true);
            await part.rename(file.path);
          } finally {
            if (await part.exists()) await part.delete();
          }
          avatarPath = file.path;
        }
      }
      await prefs.setString(
        key,
        jsonEncode({
          'username': profile['username'],
          'displayName': profile['displayName'],
          'avatarVersion': profile['avatarVersion'],
          'avatarPath': avatarPath,
        }),
      );
    } finally {
      client.close();
    }
  }
}
