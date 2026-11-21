import 'package:flutter_test/flutter_test.dart';

import 'package:found_it/features/recovery/view/widgets/mark_recovered_button.dart';
import 'package:found_it/features/recovery/view/widgets/recovery_confirmation_dialog.dart';

import '../../../../helpers/test_app.dart';

void main() {
  group('MarkRecoveredButton Widget Tests', () {
    testWidgets('renders fullWidth variant and handles tap confirmation',
        (tester) async {
      var confirmed = false;

      await pumpTestApp(
        tester,
        MarkRecoveredButton(
          onConfirmed: () => confirmed = true,
        ),
      );

      expect(find.text('Mark as Item Recovered'), findsOneWidget);

      await tester.tap(find.text('Mark as Item Recovered'));
      await tester.pumpAndSettle();

      expect(find.byType(RecoveryConfirmationDialog), findsOneWidget);

      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      expect(confirmed, isTrue);
    });

    testWidgets('renders compact variant for chat header', (tester) async {
      var confirmed = false;

      await pumpTestApp(
        tester,
        MarkRecoveredButton(
          variant: MarkRecoveredButtonVariant.compact,
          onConfirmed: () => confirmed = true,
        ),
      );

      expect(find.text('Confirm recovery'), findsOneWidget);

      await tester.tap(find.text('Confirm recovery'));
      await tester.pumpAndSettle();

      expect(find.byType(RecoveryConfirmationDialog), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(confirmed, isFalse);
    });
  });
}
