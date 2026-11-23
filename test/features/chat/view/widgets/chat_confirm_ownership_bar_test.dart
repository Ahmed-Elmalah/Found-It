import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:found_it/features/chat/view/widgets/chat_confirm_ownership_bar.dart';
import '../../../../helpers/test_app.dart';

void main() {
  testWidgets('renders nothing when canConfirm is false and not verified', (tester) async {
    await pumpTestApp(
      tester,
      ChatConfirmOwnershipBar(
        matchId: 'm-1',
        isVerified: false,
        isConfirming: false,
        canConfirm: false,
        onConfirm: () {},
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ChatConfirmOwnershipBar), findsOneWidget);
    expect(find.text('Confirm Ownership'), findsNothing);
    expect(find.text('Ownership Verified'), findsNothing);
  });

  testWidgets('renders confirm action bar when canConfirm is true (finder only)', (tester) async {
    bool confirmed = false;

    await pumpTestApp(
      tester,
      ChatConfirmOwnershipBar(
        matchId: 'm-1',
        isVerified: false,
        isConfirming: false,
        canConfirm: true,
        onConfirm: () => confirmed = true,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Confirm Ownership'), findsOneWidget);
    expect(find.text('Tap to verify this person is the rightful owner'), findsOneWidget);

    // Tap button to open confirm dialog
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    expect(find.text('Confirm Ownership Verification?'), findsOneWidget);

    // Tap confirm action inside dialog (second 'Confirm' text widget)
    await tester.tap(find.text('Confirm').last);
    await tester.pumpAndSettle();

    expect(confirmed, isTrue);
  });

  testWidgets('renders ownership verified pill when isVerified is true', (tester) async {
    await pumpTestApp(
      tester,
      ChatConfirmOwnershipBar(
        matchId: 'm-1',
        isVerified: true,
        isConfirming: false,
        canConfirm: false,
        onConfirm: () {},
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ownership Verified'), findsOneWidget);
    expect(find.text('Handover Instructions'), findsOneWidget);
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
  });

  testWidgets('renders properly in Arabic (RTL)', (tester) async {
    await pumpTestApp(
      tester,
      ChatConfirmOwnershipBar(
        matchId: 'm-1',
        isVerified: false,
        isConfirming: false,
        canConfirm: true,
        onConfirm: () {},
      ),
      rtl: true,
    );
    await tester.pumpAndSettle();

    expect(find.text('تأكيد ملكية الغرض'), findsOneWidget);
    expect(find.text('اضغط للتحقق من أن هذا الشخص هو المالك الحقيقي'), findsOneWidget);
  });
}
