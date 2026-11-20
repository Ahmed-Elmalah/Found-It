import 'package:flutter_test/flutter_test.dart';

import 'package:found_it/features/recovery/domain/entities/handover_contact_entity.dart';
import 'package:found_it/features/recovery/view/ui/handover_instructions_screen.dart';
import 'package:found_it/features/recovery/view/widgets/mark_recovered_button.dart';
import 'package:found_it/features/recovery/view/widgets/recovery_confirmation_dialog.dart';
import 'package:found_it/features/recovery/view/widgets/safety_guideline_tile.dart';
import 'package:found_it/features/recovery/view/widgets/verified_contact_card.dart';

import '../../../../helpers/test_app.dart';

void main() {
  group('HandoverInstructionsScreen Widget Tests', () {
    const mockContact = HandoverContactEntity(
      fullName: 'Ahmed Hassan',
      phone: '+20 12 3456 7890',
      email: 'ahmed@foundit.com',
    );

    testWidgets('renders safety guidelines, contact card and recover button',
        (tester) async {
      await pumpTestApp(
        tester,
        const HandoverInstructionsScreen(contact: mockContact),
        padded: false,
      );

      expect(find.text('Handover instructions'), findsWidgets);
      expect(find.text('Safety guidelines'), findsOneWidget);
      expect(find.byType(SafetyGuidelineTile), findsWidgets);
      expect(find.byType(VerifiedContactCard), findsOneWidget);
      expect(find.text('Ahmed Hassan'), findsOneWidget);
      expect(find.text('+20 12 3456 7890'), findsOneWidget);
      expect(find.byType(MarkRecoveredButton), findsOneWidget);
    });

    testWidgets('tapping Mark as Item Recovered opens confirmation dialog',
        (tester) async {
      var recoveredCalled = false;

      await pumpTestApp(
        tester,
        HandoverInstructionsScreen(
          contact: mockContact,
          onRecovered: () => recoveredCalled = true,
        ),
        padded: false,
      );

      // Tap Mark as Item Recovered
      await tester.tap(find.text('Mark as Item Recovered'));
      await tester.pumpAndSettle();

      // Dialog is shown
      expect(find.byType(RecoveryConfirmationDialog), findsOneWidget);
      expect(find.text('Confirm Item Recovered'), findsOneWidget);

      // Confirm in dialog
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      expect(recoveredCalled, isTrue);
    });
  });
}
