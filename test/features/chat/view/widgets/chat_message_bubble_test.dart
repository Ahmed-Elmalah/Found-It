import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:found_it/features/chat/domain/entities/chat_message_entity.dart';
import 'package:found_it/features/chat/view/widgets/chat_message_bubble.dart';
import '../../../../helpers/test_app.dart';

void main() {
  testWidgets('renders my outgoing text message with timestamp', (tester) async {
    final message = ChatMessageEntity(
      id: 'msg-1',
      matchId: 'match-1',
      senderId: 'me',
      body: 'I found your black wallet near the cafe',
      createdAt: DateTime(2026, 11, 23, 14, 30),
      isMine: true,
      readAt: DateTime(2026, 11, 23, 14, 35),
    );

    await pumpTestApp(
      tester,
      ChatMessageBubble(message: message),
    );
    await tester.pumpAndSettle();

    expect(find.text('I found your black wallet near the cafe'), findsOneWidget);
    expect(find.text('2:30 PM'), findsOneWidget);
    expect(find.byIcon(Icons.done_all_rounded), findsOneWidget);
  });

  testWidgets('renders incoming text message from other user', (tester) async {
    final message = ChatMessageEntity(
      id: 'msg-2',
      matchId: 'match-1',
      senderId: 'other',
      body: 'Thank you so much! Where can we meet?',
      createdAt: DateTime(2026, 11, 23, 9, 15),
      isMine: false,
    );

    await pumpTestApp(
      tester,
      ChatMessageBubble(message: message),
    );
    await tester.pumpAndSettle();

    expect(find.text('Thank you so much! Where can we meet?'), findsOneWidget);
    expect(find.text('9:15 AM'), findsOneWidget);
    // Double check mark should not appear for incoming message
    expect(find.byIcon(Icons.done_all_rounded), findsNothing);
  });

  testWidgets('renders date header when showDateHeader is true', (tester) async {
    final message = ChatMessageEntity(
      id: 'msg-3',
      matchId: 'match-1',
      senderId: 'me',
      body: 'Hello',
      createdAt: DateTime(2026, 11, 23, 10, 0),
      isMine: true,
    );

    await pumpTestApp(
      tester,
      ChatMessageBubble(
        message: message,
        showDateHeader: true,
        dateHeaderLabel: 'Today',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Hello'), findsOneWidget);
  });

  testWidgets('renders failed message with retry button and calls onRetry', (tester) async {
    final message = ChatMessageEntity(
      id: 'failed-123',
      matchId: 'match-1',
      senderId: 'me',
      body: 'Connection failed message',
      createdAt: DateTime(2026, 11, 23, 11, 0),
      isMine: true,
      hasFailed: true,
    );

    String? retriedMessageId;

    await pumpTestApp(
      tester,
      ChatMessageBubble(
        message: message,
        onRetry: (id) => retriedMessageId = id,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);

    await tester.tap(find.byIcon(Icons.refresh_rounded));
    await tester.pumpAndSettle();

    expect(retriedMessageId, 'failed-123');
  });

  testWidgets('renders correctly in Arabic (RTL)', (tester) async {
    final message = ChatMessageEntity(
      id: 'msg-ar',
      matchId: 'match-1',
      senderId: 'me',
      body: 'تم العثور على المحفظة في الكافيه',
      createdAt: DateTime(2026, 11, 23, 15, 45),
      isMine: true,
    );

    await pumpTestApp(
      tester,
      ChatMessageBubble(
        message: message,
        showDateHeader: true,
        dateHeaderLabel: 'اليوم',
      ),
      rtl: true,
    );
    await tester.pumpAndSettle();

    expect(find.text('تم العثور على المحفظة في الكافيه'), findsOneWidget);
    expect(find.text('اليوم'), findsOneWidget);
  });
}
