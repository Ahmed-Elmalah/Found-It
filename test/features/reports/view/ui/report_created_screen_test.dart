import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:found_it/core/router/app_routes.dart';
import 'package:found_it/features/reports/view/ui/report_created_screen.dart';

import '../../../../helpers/test_app.dart';

void main() {
  group('ReportCreatedScreen Widget Test', () {
    GoRouter buildRouter({String refCode = 'RPT-1001'}) {
      return GoRouter(
        initialLocation: AppRoutes.reportCreated,
        routes: [
          GoRoute(
            path: AppRoutes.reportCreated,
            builder: (_, _) => ReportCreatedScreen(referenceId: refCode),
          ),
          GoRoute(
            path: AppRoutes.myReports,
            builder: (_, _) => const Scaffold(body: Text('MY REPORTS SCREEN')),
          ),
          GoRoute(
            path: AppRoutes.home,
            builder: (_, _) => const Scaffold(body: Text('HOME SCREEN')),
          ),
        ],
      );
    }

    testWidgets('displays success UI and shows the reference code', (tester) async {
      final router = buildRouter(refCode: 'RPT-8092');
      await pumpTestRouterApp(tester, router);

      expect(find.text('Report Created Successfully!'), findsOneWidget);
      expect(find.textContaining('RPT-8092'), findsOneWidget);
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
      expect(find.text('View my report'), findsOneWidget);
      expect(find.text('Back to home'), findsOneWidget);
    });

    testWidgets('tapping "View my report" navigates to My Reports', (tester) async {
      final router = buildRouter();
      await pumpTestRouterApp(tester, router);

      await tester.tap(find.text('View my report'));
      await tester.pumpAndSettle();

      expect(find.text('MY REPORTS SCREEN'), findsOneWidget);
    });

    testWidgets('tapping "Back to home" navigates to Home', (tester) async {
      final router = buildRouter();
      await pumpTestRouterApp(tester, router);

      await tester.tap(find.text('Back to home'));
      await tester.pumpAndSettle();

      expect(find.text('HOME SCREEN'), findsOneWidget);
    });
  });
}
