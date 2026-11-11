import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Values read from the `.env` file in the project root.
///
/// `.env` is not in git. To create it, copy `.env.example` to `.env` and
/// fill in the values (ask Ahmed for them).
///
/// [load] must run once in `main()` before anything reads these values.
abstract final class Env {
  static Future<void> load() => dotenv.load(fileName: '.env');

  static String get supabaseUrl => _required('SUPABASE_URL');

  static String get supabasePublishableKey =>
      _required('SUPABASE_PUBLISHABLE_KEY');

  /// Returns the value, or stops the app with a clear message if it's missing.
  static String _required(String key) {
    final value = dotenv.maybeGet(key)?.trim() ?? '';
    if (value.isEmpty) {
      throw StateError(
        '$key is missing in .env. '
        'Copy .env.example to .env and fill in the values.',
      );
    }
    return value;
  }
}
