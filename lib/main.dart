import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:found_it/core/config/env.dart';
import 'package:found_it/core/di/injection.dart';
import 'package:found_it/found_it.dart';

Future<void> main() async {
  // 1) Lets us run async code (plugins) before runApp.
  WidgetsFlutterBinding.ensureInitialized();

  // 2) Read the Supabase URL + key from .env
  await Env.load();

  // 3) Connect to Supabase (also restores the saved login session)
  await Supabase.initialize(
    url: Env.supabaseUrl,
    publishableKey: Env.supabasePublishableKey,
  );

  // 4) Register everything in get_it (needs Supabase to be ready)
  await configureDependencies();

  runApp(const FoundIt());
}
