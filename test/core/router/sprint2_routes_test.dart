import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:found_it/core/di/injection.dart';
import 'package:found_it/core/router/app_router.dart';
import 'package:found_it/core/router/app_routes.dart';
import 'package:found_it/features/auth/view/cubit/auth_cubit.dart';

class _FakeAuthCubit extends Cubit<AuthState> implements AuthCubit {
  _FakeAuthCubit() : super(const AuthState());

  @override
  Future<void> start() async {}

  @override
  void cityChanged(String cityId) {}

  @override
  Future<void> logout() async {}
}

void main() {
  setUpAll(() {
    if (!sl.isRegistered<AuthCubit>()) {
      sl.registerLazySingleton<AuthCubit>(() => _FakeAuthCubit());
    }
  });

  group('Sprint 2 AppRoutes helpers', () {
    test('reportDetailsPath builds correct path with id', () {
      expect(AppRoutes.reportDetailsPath('rep-123'), '/reports/rep-123');
    });

    test('matchComparePath builds correct path with id', () {
      expect(AppRoutes.matchComparePath('match-456'), '/matches/match-456');
    });

    test('chatPath builds correct path with matchId', () {
      expect(AppRoutes.chatPath('match-789'), '/chat/match-789');
    });

    test('handoverPath builds correct path with matchId', () {
      expect(
        AppRoutes.handoverPath('match-789'),
        '/chat/match-789/handover',
      );
    });

    test('static constants have expected route paths', () {
      expect(AppRoutes.reportDetails, '/reports/:id');
      expect(AppRoutes.matches, '/matches');
      expect(AppRoutes.matchCompare, '/matches/:id');
      expect(AppRoutes.chat, '/chat/:matchId');
      expect(AppRoutes.handover, '/chat/:matchId/handover');
      expect(AppRoutes.notifications, '/notifications');
    });
  });

  group('Sprint 2 Router configuration', () {
    test('appRouter contains all 6 Sprint 2 routes', () {
      final routes = appRouter.configuration.routes
          .whereType<GoRoute>()
          .map((r) => r.path)
          .toSet();

      expect(routes.contains(AppRoutes.reportDetails), isTrue);
      expect(routes.contains(AppRoutes.matches), isTrue);
      expect(routes.contains(AppRoutes.matchCompare), isTrue);
      expect(routes.contains(AppRoutes.chat), isTrue);
      expect(routes.contains(AppRoutes.handover), isTrue);
      expect(routes.contains(AppRoutes.notifications), isTrue);
    });
  });
}
