import 'package:flutter/foundation.dart';

/// Reads the current FCM token (Firebase is the only source in production).
typedef FetchDeviceToken = Future<String?> Function();

/// `save_device_token(p_token, p_platform, p_lang)` — Section 8.
typedef SaveDeviceToken = Future<void> Function({
  required String token,
  required String platform,
  required String lang,
});

/// `delete_device_token(p_token)` — Section 8.
typedef DeleteDeviceToken = Future<void> Function({required String token});

/// Keeps the signed-in user's FCM token registered in `device_tokens`.
///
/// Contract (`docs/api_sprint2.md` Section 8):
/// - save after login / restored session, on token refresh and on language
///   change,
/// - delete on logout **before** `signOut()` (the RPC needs the session).
///
/// Every network failure is swallowed: push registration must never block or
/// crash login, app start or logout.
class DeviceTokenSync {
  DeviceTokenSync({
    required this.fetchToken,
    required this.saveDeviceToken,
    required this.deleteDeviceToken,
    required this.platform,
    required this.languageCode,
    bool Function()? isSignedIn,
  }) : isSignedIn = isSignedIn ?? _alwaysSignedIn;

  final FetchDeviceToken fetchToken;
  final SaveDeviceToken saveDeviceToken;
  final DeleteDeviceToken deleteDeviceToken;

  /// `'android' | 'ios' | 'web'`.
  final String platform;
  final String Function() languageCode;
  final bool Function() isSignedIn;

  String? _token;

  /// The token most recently seen (exposed for debugging / re-sync).
  String? get token => _token;

  /// App start and `onTokenRefresh`: remember the token, and save it when a
  /// session already exists. Without a session it is saved on [onSignedIn].
  Future<void> updateToken(String? token) async {
    final value = _clean(token);
    if (value == null) return;
    _token = value;
    if (!isSignedIn()) return;
    await _save(value);
  }

  /// Login or restored session: the token is upserted for this user.
  Future<void> onSignedIn() async {
    final value = _token ?? _clean(await _fetchSafely());
    if (value == null) return;
    _token = value;
    await _save(value);
  }

  /// Logout: remove the token while the session is still valid.
  ///
  /// The caller must invoke this before `signOut()`.
  Future<void> beforeLogout() async {
    final value = _token ?? _clean(await _fetchSafely());
    if (value == null) return;
    try {
      await deleteDeviceToken(token: value);
    } catch (error) {
      _log('delete_device_token', error);
    }
  }

  Future<void> _save(String token) async {
    try {
      await saveDeviceToken(
        token: token,
        platform: platform,
        lang: languageCode(),
      );
    } catch (error) {
      _log('save_device_token', error);
    }
  }

  Future<String?> _fetchSafely() async {
    try {
      return await fetchToken();
    } catch (error) {
      _log('getToken', error);
      return null;
    }
  }

  static String? _clean(String? token) {
    final value = token?.trim();
    return (value == null || value.isEmpty) ? null : value;
  }

  static bool _alwaysSignedIn() => true;

  static void _log(String action, Object error) {
    debugPrint('[DeviceTokenSync] $action failed: $error');
  }
}
