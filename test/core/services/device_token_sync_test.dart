import 'package:flutter_test/flutter_test.dart';

import 'package:found_it/core/services/device_token_sync.dart';

typedef _Save = ({String token, String platform, String lang});

class _Backend {
  _Backend({this.token = 'token-1', this.signedIn = true});

  String? token;
  bool signedIn;
  String lang = 'ar';

  Object? fetchError;
  Object? saveError;
  Object? deleteError;

  int fetchCalls = 0;
  final List<_Save> saves = [];
  final List<String> deletes = [];
}

DeviceTokenSync _sync(_Backend backend) => DeviceTokenSync(
  fetchToken: () async {
    backend.fetchCalls++;
    final error = backend.fetchError;
    if (error != null) throw error;
    return backend.token;
  },
  saveDeviceToken: ({required token, required platform, required lang}) async {
    final error = backend.saveError;
    if (error != null) throw error;
    backend.saves.add((token: token, platform: platform, lang: lang));
  },
  deleteDeviceToken: ({required token}) async {
    final error = backend.deleteError;
    if (error != null) throw error;
    backend.deletes.add(token);
  },
  platform: 'android',
  languageCode: () => backend.lang,
  isSignedIn: () => backend.signedIn,
);

void main() {
  group('updateToken (app start / onTokenRefresh)', () {
    test('saves the token when a session exists', () async {
      final backend = _Backend();
      final sync = _sync(backend);

      await sync.updateToken(' token-1 ');

      expect(sync.token, 'token-1');
      expect(backend.saves, hasLength(1));
      expect(backend.saves.single.token, 'token-1');
      expect(backend.saves.single.platform, 'android');
      expect(backend.saves.single.lang, 'ar');
      expect(backend.fetchCalls, 0);
    });

    test('uses the current language on every save', () async {
      final backend = _Backend()..lang = 'en';
      final sync = _sync(backend);

      await sync.updateToken('token-1');
      backend.lang = 'ar';
      await sync.updateToken('token-2');

      expect(backend.saves.map((save) => save.lang), ['en', 'ar']);
    });

    test('keeps the token without calling the RPC when signed out', () async {
      final backend = _Backend(signedIn: false);
      final sync = _sync(backend);

      await sync.updateToken('token-1');

      expect(sync.token, 'token-1');
      expect(backend.saves, isEmpty);
    });

    test('ignores null and blank tokens', () async {
      final backend = _Backend();
      final sync = _sync(backend);

      await sync.updateToken(null);
      await sync.updateToken('   ');

      expect(sync.token, isNull);
      expect(backend.saves, isEmpty);
    });

    test('a save failure is swallowed', () async {
      final backend = _Backend()..saveError = Exception('network down');
      final sync = _sync(backend);

      await expectLater(sync.updateToken('token-1'), completes);
      expect(sync.token, 'token-1');
    });
  });

  group('onSignedIn (login / restored session)', () {
    test('saves the cached token without fetching it again', () async {
      final backend = _Backend(signedIn: false);
      final sync = _sync(backend);
      await sync.updateToken('token-1');

      backend.signedIn = true;
      await sync.onSignedIn();

      expect(backend.saves, hasLength(1));
      expect(backend.saves.single.token, 'token-1');
      expect(backend.fetchCalls, 0);
    });

    test('fetches the token when none was seen yet', () async {
      final backend = _Backend(token: 'token-9');
      final sync = _sync(backend);

      await sync.onSignedIn();

      expect(backend.fetchCalls, 1);
      expect(backend.saves.single.token, 'token-9');
    });

    test('a fetch failure is swallowed', () async {
      final backend = _Backend()..fetchError = Exception('no firebase');
      final sync = _sync(backend);

      await expectLater(sync.onSignedIn(), completes);
      expect(backend.saves, isEmpty);
    });
  });

  group('beforeLogout (delete before signOut)', () {
    test('deletes the token that was saved', () async {
      final backend = _Backend();
      final sync = _sync(backend);
      await sync.updateToken('token-1');

      await sync.beforeLogout();

      expect(backend.deletes, ['token-1']);
    });

    test('fetches the token when none was seen yet', () async {
      final backend = _Backend(token: 'token-9');
      final sync = _sync(backend);

      await sync.beforeLogout();

      expect(backend.fetchCalls, 1);
      expect(backend.deletes, ['token-9']);
    });

    test('a delete failure is swallowed', () async {
      final backend = _Backend()..deleteError = Exception('session gone');
      final sync = _sync(backend);
      await sync.updateToken('token-1');

      await expectLater(sync.beforeLogout(), completes);
    });

    test('does nothing when there is no token at all', () async {
      final backend = _Backend(token: null);
      final sync = _sync(backend);

      await sync.beforeLogout();

      expect(backend.deletes, isEmpty);
    });
  });
}
