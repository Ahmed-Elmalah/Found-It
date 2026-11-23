import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:found_it/core/services/device_token_sync.dart';
import 'package:found_it/core/services/notification_payload.dart';
import 'package:found_it/firebase_options.dart';

/// `mark_notifications_read(p_ids: [id])` — Section 8.
typedef MarkNotificationRead = Future<void> Function(String notificationId);

/// Top-level handler required by FCM: it must not be a closure or a method.
///
/// The backend sends a `notification` block, so Android draws the tray
/// notification by itself while the app is in the background / terminated.
/// This handler only makes sure Firebase is ready in the background isolate.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

/// Owns everything push-related (story #5):
/// - local notifications (`found_it_default` channel) + Android 13 permission,
/// - foreground messages -> local notification,
/// - FCM token registration / refresh (through [DeviceTokenSync]),
/// - taps from all three app states, exposed as [taps].
class NotificationService {
  NotificationService({
    required this.tokenSync,
    this.markRead,
    FlutterLocalNotificationsPlugin? localNotifications,
  }) : _localNotifications =
           localNotifications ?? FlutterLocalNotificationsPlugin();

  /// Must match `AndroidManifest.xml` and Section 8.
  static const String channelId = 'found_it_default';
  static const String channelName = 'Found It';
  static const String channelDescription =
      'Matches, messages and recovery updates';

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    channelId,
    channelName,
    description: channelDescription,
    importance: Importance.high,
  );

  static const AndroidNotificationDetails _androidDetails =
      AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDescription,
        importance: Importance.high,
        priority: Priority.high,
      );

  final DeviceTokenSync tokenSync;
  final MarkNotificationRead? markRead;
  final FlutterLocalNotificationsPlugin _localNotifications;

  final StreamController<NotificationPayload> _taps =
      StreamController<NotificationPayload>.broadcast();

  /// One event per notification tap (foreground, background or terminated).
  Stream<NotificationPayload> get taps => _taps.stream;

  StreamSubscription<RemoteMessage>? _onMessage;
  StreamSubscription<RemoteMessage>? _onMessageOpened;
  StreamSubscription<String>? _onTokenRefresh;
  bool _initialized = false;
  int _nextNotificationId = 0;

  /// Call once, after `runApp` (the listeners need the plugins registered).
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    // Subscribe before awaiting plugin setup so no early message is missed.
    _onMessage = FirebaseMessaging.onMessage.listen(_showForeground);
    _onMessageOpened = FirebaseMessaging.onMessageOpenedApp.listen(
      _handleRemoteMessage,
    );
    // The backend stores an FCM registration token; `onRegistered` emits an
    // installation id instead, so the deprecated stream is still the contract.
    // ignore: deprecated_member_use
    final tokenRefresh = FirebaseMessaging.instance.onTokenRefresh;
    _onTokenRefresh = tokenRefresh.listen(tokenSync.updateToken);

    await _safely(_initLocalNotifications, 'local notifications');
    await _safely(_requestPermission, 'notification permission');
    await _syncToken();
  }

  /// Handles a tap that launched the app from a terminated state.
  ///
  /// Call after the router and the auth state are ready, otherwise the
  /// redirect would send a protected deep link to the login screen.
  Future<void> handleInitialMessage() async {
    await _safely(() async {
      // A local notification shown in the foreground can outlive the app.
      final launch = await _localNotifications
          .getNotificationAppLaunchDetails();
      if (launch != null && launch.didNotificationLaunchApp) {
        final payload = NotificationPayload.tryParseJson(
          launch.notificationResponse?.payload,
        );
        if (payload != null) {
          _emit(payload);
          return;
        }
      }
      final message = await FirebaseMessaging.instance.getInitialMessage();
      if (message != null) _handleRemoteMessage(message);
    }, 'initial message');
  }

  Future<void> dispose() async {
    await _onMessage?.cancel();
    await _onMessageOpened?.cancel();
    await _onTokenRefresh?.cancel();
    await _taps.close();
  }

  Future<void> _initLocalNotifications() async {
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await _localNotifications.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: _onLocalNotificationResponse,
    );
    await _androidPlugin?.createNotificationChannel(_channel);
  }

  Future<void> _requestPermission() async {
    // On Android 13+ this triggers the POST_NOTIFICATIONS runtime dialog.
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> _syncToken() async {
    try {
      // ignore: deprecated_member_use
      final token = await FirebaseMessaging.instance.getToken();
      await tokenSync.updateToken(token);
    } catch (error) {
      _log('getToken', error);
    }
  }

  /// Foreground: FCM does not draw anything, so show a local notification with
  /// the same JSON payload that a tray tap would deliver.
  Future<void> _showForeground(RemoteMessage message) async {
    final notification = message.notification;
    final title = notification?.title ?? message.data['title']?.toString();
    final body = notification?.body ?? message.data['body']?.toString();
    if (title == null && body == null) return;
    try {
      await _localNotifications.show(
        id: _nextNotificationId++,
        title: title,
        body: body,
        notificationDetails: const NotificationDetails(
          android: _androidDetails,
        ),
        payload: jsonEncode(message.data),
      );
    } catch (error) {
      _log('show notification', error);
    }
  }

  void _onLocalNotificationResponse(NotificationResponse response) {
    final payload = NotificationPayload.tryParseJson(response.payload);
    if (payload != null) _emit(payload);
  }

  void _handleRemoteMessage(RemoteMessage message) {
    final payload = NotificationPayload.tryParse(message.data);
    if (payload != null) _emit(payload);
  }

  void _emit(NotificationPayload payload) {
    if (_taps.isClosed) return;
    _taps.add(payload);
    final id = payload.notificationId;
    if (id != null) unawaited(_markRead(id));
  }

  Future<void> _markRead(String notificationId) async {
    final markRead = this.markRead;
    if (markRead == null) return;
    try {
      await markRead(notificationId);
    } catch (error) {
      _log('mark_notifications_read', error);
    }
  }

  Future<void> _safely(Future<void> Function() action, String label) async {
    try {
      await action();
    } catch (error) {
      _log(label, error);
    }
  }

  AndroidFlutterLocalNotificationsPlugin? get _androidPlugin =>
      _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

  static void _log(String action, Object error) {
    debugPrint('[NotificationService] $action failed: $error');
  }
}
