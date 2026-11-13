import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:found_it/features/reports/view/widgets/delete_report_dialog.dart';

import '../../../../helpers/test_app.dart';

void main() {
  group('DeleteReportDialog Widget Test', () {
    testWidgets('renders title, description, and action buttons', (tester) async {
      await pumpTestApp(
        tester,
        DeleteReportDialog(
          onConfirm: () {},
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(DeleteReportDialog), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline_rounded), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('tapping confirm calls onConfirm callback', (tester) async {
      var confirmed = false;

      await pumpTestApp(
        tester,
        DeleteReportDialog(
          onConfirm: () {
            confirmed = true;
          },
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete'));
      await tester.pump();

      expect(confirmed, isTrue);
    });

    testWidgets('shows loading indicator when isLoading is true', (tester) async {
      await pumpTestApp(
        tester,
        DeleteReportDialog(
          onConfirm: () {},
          isLoading: true,
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
