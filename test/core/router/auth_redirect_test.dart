import 'package:flutter_test/flutter_test.dart';
import 'package:found_it/core/router/app_routes.dart';
import 'package:found_it/core/router/auth_redirect.dart';

void main() {
  const alwaysOpen = [
    AppRoutes.splash,
    AppRoutes.onboarding,
    AppRoutes.verifyEmail,
  ];
  const entry = [AppRoutes.login, AppRoutes.signUp, AppRoutes.forgotPassword];
  const protectedPages = [AppRoutes.home, AppRoutes.city, '/create-report'];
  const all = [...alwaysOpen, ...entry, ...protectedPages];

  String? run(bool? loggedIn, bool? hasCity, String location) =>
      authRedirect(isLoggedIn: loggedIn, hasCity: hasCity, location: location);

  group('rule 1: login state unknown', () {
    for (final hasCity in [null, false, true]) {
      for (final loc in all) {
        test('isLoggedIn null, hasCity $hasCity, $loc -> stay', () {
          expect(run(null, hasCity, loc), isNull);
        });
      }
    }
  });

  group('rule 2: not logged in', () {
    for (final hasCity in [null, false, true]) {
      for (final loc in [...alwaysOpen, ...entry]) {
        test('hasCity $hasCity, $loc -> stay', () {
          expect(run(false, hasCity, loc), isNull);
        });
      }
      for (final loc in protectedPages) {
        test('hasCity $hasCity, $loc -> login', () {
          expect(run(false, hasCity, loc), AppRoutes.login);
        });
      }
    }
  });

  group('rule 3: logged in without city', () {
    for (final loc in [...alwaysOpen, AppRoutes.city]) {
      test('$loc -> stay', () {
        expect(run(true, false, loc), isNull);
      });
    }
    for (final loc in [...entry, AppRoutes.home, '/create-report']) {
      test('$loc -> city', () {
        expect(run(true, false, loc), AppRoutes.city);
      });
    }
  });

  group('rule 4: logged in, city set or unknown', () {
    for (final hasCity in [null, true]) {
      for (final loc in [...alwaysOpen, ...protectedPages]) {
        test('hasCity $hasCity, $loc -> stay', () {
          expect(run(true, hasCity, loc), isNull);
        });
      }
      for (final loc in entry) {
        test('hasCity $hasCity, $loc -> home', () {
          expect(run(true, hasCity, loc), AppRoutes.home);
        });
      }
    }
  });

  group('normalization', () {
    test('trailing slash is ignored', () {
      expect(run(false, null, '/home/'), AppRoutes.login);
      expect(run(true, true, '/home/'), isNull);
    });
    test('query string is ignored', () {
      expect(run(true, true, '/login?x=1'), AppRoutes.home);
      expect(run(false, null, '/login?x=1'), isNull);
    });
    test('root stays root', () {
      expect(run(false, null, '/'), isNull);
    });
    test('trailing slash and query together', () {
      expect(run(true, false, '/city/?a=b'), isNull);
    });
  });
}
