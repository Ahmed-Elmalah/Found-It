import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:found_it/features/chat/domain/entities/chat_item_entity.dart';
import 'package:found_it/features/chat/domain/entities/chat_report_summary_entity.dart';
import 'package:found_it/features/chat/view/widgets/chat_app_bar.dart';
import '../../../../helpers/test_app.dart';

void main() {
  testWidgets('renders other user name and report title in header', (tester) async {
    const chatInfo = ChatItemEntity(
      matchId: 'match-1',
      status: 'chatting',
      otherUserName: 'Omar Khaled',
      iAmFinder: true,
      myReport: ChatReportSummaryEntity(
        id: 'r-1',
        refCode: 'RPT-1001',
        title: 'Found Keys at Park',
        type: 'found',
      ),
      otherReport: ChatReportSummaryEntity(
        id: 'r-2',
        refCode: 'RPT-1002',
        title: 'Lost Silver Keys',
        type: 'lost',
      ),
    );

    await pumpTestApp(
      tester,
      const ChatAppBar(chatInfo: chatInfo),
    );
    await tester.pumpAndSettle();

    expect(find.text('Omar Khaled'), findsOneWidget);
    expect(find.textContaining('Lost Silver Keys'), findsOneWidget);
    expect(find.byIcon(Icons.more_vert_rounded), findsOneWidget);
  });

  testWidgets('hides 3-dots options menu when chat is closed (rejected/recovered)', (tester) async {
    const closedChat = ChatItemEntity(
      matchId: 'match-closed',
      status: 'rejected',
      otherUserName: 'Sarah N.',
      iAmFinder: false,
    );

    await pumpTestApp(
      tester,
      const ChatAppBar(chatInfo: closedChat),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sarah N.'), findsOneWidget);
    expect(find.byIcon(Icons.more_vert_rounded), findsNothing);
  });

  testWidgets('tapping 3-dots options menu shows reject match option', (tester) async {
    bool rejectCallbackTriggered = false;

    const activeChat = ChatItemEntity(
      matchId: 'match-active',
      status: 'chatting',
      otherUserName: 'Ahmed Ali',
      iAmFinder: false,
    );

    await pumpTestApp(
      tester,
      ChatAppBar(
        chatInfo: activeChat,
        onRejectMatch: () => rejectCallbackTriggered = true,
      ),
    );
    await tester.pumpAndSettle();

    // Tap 3-dots icon
    await tester.tap(find.byIcon(Icons.more_vert_rounded));
    await tester.pumpAndSettle();

    // Bottom sheet with Reject Match should appear
    expect(find.text('Reject Match'), findsOneWidget);

    // Tap Reject Match
    await tester.tap(find.text('Reject Match'));
    await tester.pumpAndSettle();

    // Confirmation dialog should appear
    expect(find.text('Reject Match?'), findsOneWidget);
    expect(find.text('Are you sure you want to reject this match? This conversation will be closed permanently.'), findsOneWidget);

    // Tap confirm reject inside dialog
    await tester.tap(find.widgetWithText(GestureDetector, 'Reject'));
    await tester.pumpAndSettle();

    expect(rejectCallbackTriggered, isTrue);
  });

  testWidgets('renders Arabic texts and RTL layout', (tester) async {
    const chatInfo = ChatItemEntity(
      matchId: 'match-ar',
      status: 'chatting',
      otherUserName: 'سارة حسن',
      iAmFinder: true,
    );

    await pumpTestApp(
      tester,
      const ChatAppBar(chatInfo: chatInfo),
      rtl: true,
    );
    await tester.pumpAndSettle();

    expect(find.text('سارة حسن'), findsOneWidget);
    expect(find.text('نشط الآن'), findsOneWidget);
  });
}
