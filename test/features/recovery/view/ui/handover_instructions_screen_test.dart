import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:found_it/features/recovery/domain/entities/handover_contact_entity.dart';
import 'package:found_it/features/recovery/domain/repositories/recovery_repository.dart';
import 'package:found_it/features/recovery/domain/use_cases/get_match_contact_use_case.dart';
import 'package:found_it/features/recovery/domain/use_cases/mark_item_recovered_use_case.dart';
import 'package:found_it/features/recovery/view/cubit/recovery_cubit.dart';
import 'package:found_it/features/recovery/view/cubit/recovery_state.dart';
import 'package:found_it/features/recovery/view/ui/handover_instructions_screen.dart';
import 'package:found_it/features/recovery/view/widgets/mark_recovered_button.dart';
import 'package:found_it/features/recovery/view/widgets/recovery_confirmation_dialog.dart';
import 'package:found_it/features/recovery/view/widgets/safety_guideline_tile.dart';
import 'package:found_it/features/recovery/view/widgets/verified_contact_card.dart';

import '../../../../helpers/test_app.dart';

class _FakeRecoveryRepo implements RecoveryRepository {
  final HandoverContactEntity contact;
  _FakeRecoveryRepo(this.contact);

  @override
  Future<HandoverContactEntity> getMatchContact(String matchId) async => contact;

  @override
  Future<void> markItemRecovered(String matchId) async {}
}

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

    testWidgets('renders loaded state via RecoveryCubit', (tester) async {
      final fakeRepo = _FakeRecoveryRepo(mockContact);
      final cubit = RecoveryCubit(
        getMatchContact: GetMatchContactUseCase(fakeRepo),
        markItemRecovered: MarkItemRecoveredUseCase(fakeRepo),
      );

      await pumpTestApp(
        tester,
        BlocProvider<RecoveryCubit>.value(
          value: cubit,
          child: const HandoverInstructionsScreen(matchId: 'match_123'),
        ),
        padded: false,
      );

      cubit.emit(const HandoverContactLoaded(mockContact));
      await tester.pump();

      expect(find.text('Handover instructions'), findsWidgets);
      expect(find.text('Ahmed Hassan'), findsOneWidget);
    });
  });
}
