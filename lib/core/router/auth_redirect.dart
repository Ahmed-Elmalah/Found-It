import 'package:found_it/core/router/app_routes.dart';

/// Decides where a user may go. Returns the path to redirect to, or null to
/// stay on [location].
///
/// Page kinds:
/// - always open: splash, onboarding, verifyEmail (never redirected)
/// - entry: login, signUp, forgotPassword
/// - protected: every other path (new pages are protected by default)
///
/// | isLoggedIn | hasCity | location          | result              |
/// |------------|---------|-------------------|---------------------|
/// | null       | any     | any               | null (wait)         |
/// | false      | any     | always open       | null                |
/// | false      | any     | entry             | null                |
/// | false      | any     | protected         | AppRoutes.login     |
/// | true       | false   | always open, city | null                |
/// | true       | false   | anything else     | AppRoutes.city      |
/// | true       | true/null | always open     | null                |
/// | true       | true/null | entry           | AppRoutes.home      |
/// | true       | true/null | protected       | null                |
///
/// The [location] is normalized: a query string and a trailing '/' (except
/// for the root) are ignored.
String? authRedirect({
  required bool? isLoggedIn,
  required bool? hasCity,
  required String location,
}) {
  if (isLoggedIn == null) return null;

  final path = _normalize(location);
  if (_alwaysOpen.contains(path)) return null;

  final isEntry = _entry.contains(path);

  if (!isLoggedIn) {
    return isEntry ? null : AppRoutes.login;
  }

  if (hasCity == false) {
    return path == AppRoutes.city ? null : AppRoutes.city;
  }

  return isEntry ? AppRoutes.home : null;
}

const _alwaysOpen = {
  AppRoutes.splash,
  AppRoutes.onboarding,
  AppRoutes.verifyEmail,
};

const _entry = {AppRoutes.login, AppRoutes.signUp, AppRoutes.forgotPassword};

String _normalize(String location) {
  final queryAt = location.indexOf('?');
  var path = queryAt == -1 ? location : location.substring(0, queryAt);
  while (path.length > 1 && path.endsWith('/')) {
    path = path.substring(0, path.length - 1);
  }
  return path;
}
