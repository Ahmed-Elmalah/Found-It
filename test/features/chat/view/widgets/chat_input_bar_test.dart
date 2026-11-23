import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:found_it/features/chat/view/widgets/chat_input_bar.dart';
import '../../../../helpers/test_app.dart';

void main() {
  testWidgets('renders input bar with placeholder and attach button', (tester) async {
    await pumpTestApp(
      tester,
      ChatInputBar(
        onSendMessage: (_) {},
        onSendImage: (bytes, ext) {},
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Type a message...'), findsOneWidget);
    expect(find.byIcon(Icons.camera_alt_outlined), findsOneWidget);
  });

  testWidgets('typing text enables send button and triggers onSendMessage', (tester) async {
    String? sentText;

    await pumpTestApp(
      tester,
      ChatInputBar(
        onSendMessage: (text) => sentText = text,
        onSendImage: (bytes, ext) {},
      ),
    );
    await tester.pumpAndSettle();

    // Type text into the text field
    await tester.enterText(find.byType(TextField), 'Hello, I have your keys!');
    await tester.pumpAndSettle();

    expect(find.text('Hello, I have your keys!'), findsOneWidget);

    // Tap the send button (arrow icon)
    await tester.tap(find.byIcon(Icons.arrow_upward_rounded));
    await tester.pumpAndSettle();

    expect(sentText, 'Hello, I have your keys!');
    // Field should be cleared after send
    expect(find.text('Hello, I have your keys!'), findsNothing);
  });

  testWidgets('renders closed message when isClosed is true', (tester) async {
    await pumpTestApp(
      tester,
      ChatInputBar(
        isClosed: true,
        onSendMessage: (_) {},
        onSendImage: (bytes, ext) {},
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('This conversation is closed'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
  });

  testWidgets('renders closed message in Arabic (RTL) when isClosed is true', (tester) async {
    await pumpTestApp(
      tester,
      ChatInputBar(
        isClosed: true,
        onSendMessage: (_) {},
        onSendImage: (bytes, ext) {},
      ),
      rtl: true,
    );
    await tester.pumpAndSettle();

    expect(find.text('تم إغلاق هذه المحادثة'), findsOneWidget);
  });
}
