import 'package:flutter/material.dart';

import 'package:found_it/core/di/injection.dart';
import 'package:found_it/found_it.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const FoundIt());
}