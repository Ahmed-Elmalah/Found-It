import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:found_it/core/config/env.dart';
import 'package:found_it/core/di/injection.dart';
import 'package:found_it/core/router/app_router.dart';
import 'package:found_it/core/services/notification_service.dart';
import 'package:found_it/features/auth/view/cubit/auth_cubit.dart';
import 'package:found_it/firebase_options.dart';
import 'package:found_it/found_it.dart';

Future<void> main() async {
  // 1) Lets us run async code (plugins) before runApp.
  WidgetsFlutterBinding.ensureInitialized();

  // 2) Firebase: required before any firebase_messaging call (push tokens).
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 3) Must be registered before runApp: messages received while the app is in
  //    the background / terminated are delivered to this top-level handler.
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // 4) Read the Supabase URL + key from .env
  await Env.load();

  // 5) Connect to Supabase (also restores the saved login session)
  await Supabase.initialize(
    url: Env.supabaseUrl,
    publishableKey: Env.supabasePublishableKey,
  );

  // 6) Register everything in get_it (needs Supabase to be ready)
  await configureDependencies();

  // 7) Notification taps (foreground / background) navigate through the same
  //    deep link, built from AppRoutes inside NotificationPayload.
  sl<NotificationService>().taps.listen((payload) {
    final route = payload.route;
    if (route != null) appRouter.go(route);
  });

  // 8) Start listening to login / logout and load the user's profile.
  //    Not awaited: the splash screen shows while the profile loads.
  unawaited(sl<AuthCubit>().start());

  runApp(const FoundIt());

  // 9) Push setup + the tap that launched the app (needs the router ready).
  unawaited(_startNotifications());
}

Future<void> _startNotifications() async {
  try {
    final notifications = sl<NotificationService>();
    await notifications.initialize();
    // A protected deep link only works once the restored session is loaded;
    // before that the router would redirect it to the login screen.
    await _waitForAuth();
    await notifications.handleInitialMessage();
  } catch (error) {
    // Push setup must never take the app down.
    debugPrint('[main] notifications setup failed: $error');
  }
}

Future<void> _waitForAuth() async {
  final auth = sl<AuthCubit>();
  if (auth.state.status != AuthStatus.unknown) return;
  await auth.stream
      .firstWhere((state) => state.status != AuthStatus.unknown)
      .timeout(const Duration(seconds: 10), onTimeout: () => auth.state);
}
