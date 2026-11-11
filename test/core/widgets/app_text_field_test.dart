import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:found_it/core/widgets/app_text_field.dart';

import '../../helpers/test_app.dart';

void main() {
  testWidgets('shows label and hint', (tester) async {
    await pumpTestApp(
      tester,
      const AppTextField(label: 'Email', hint: 'you@mail.com'),
    );
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('you@mail.com'), findsOneWidget);
  });

  testWidgets('password is obscured and eye toggles it', (tester) async {
    await pumpTestApp(
      tester,
      const AppTextField(label: 'Password', isPassword: true),
    );
    bool obscure() =>
        tester.widget<EditableText>(find.byType(EditableText)).obscureText;

    expect(obscure(), isTrue);
    expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);

    await tester.tap(find.byType(IconButton));
    await tester.pump();
    expect(obscure(), isFalse);
    expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);

    await tester.tap(find.byType(IconButton));
    await tester.pump();
    expect(obscure(), isTrue);
  });

  testWidgets('hasError uses the theme error color for borders',
      (tester) async {
    await pumpTestApp(
      tester,
      const AppTextField(label: 'Email', hasError: true),
    );
    final errorColor = Theme.of(tester.element(find.byType(TextField))).colorScheme.error;
    final decoration = tester.widget<TextField>(find.byType(TextField)).decoration!;
    final enabled = decoration.enabledBorder! as OutlineInputBorder;
    final focused = decoration.focusedBorder! as OutlineInputBorder;
    expect(enabled.borderSide.color, errorColor);
    expect(focused.borderSide.color, errorColor);
  });

  testWidgets('validator message shows after Form.validate()', (tester) async {
    final formKey = GlobalKey<FormState>();
    await pumpTestApp(
      tester,
      Form(
        key: formKey,
        child: AppTextField(
          label: 'Email',
          validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
        ),
      ),
    );
    expect(find.text('Required'), findsNothing);
    expect(formKey.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('Required'), findsOneWidget);
  });

  testWidgets('prefixText is visible without focus', (tester) async {
    await pumpTestApp(
      tester,
      const AppTextField(
        label: 'Phone',
        prefixIcon: Icons.phone_iphone,
        prefixText: '+20',
      ),
    );
    expect(find.text('+20'), findsOneWidget);
  });

  testWidgets('field is 56 high and text starts 52 after the start edge',
      (tester) async {
    await pumpTestApp(
      tester,
      const AppTextField(label: 'Email', prefixIcon: Icons.mail_outline),
    );
    final field = tester.getRect(find.byType(TextField));
    expect(field.height, 56);
    final text = tester.getRect(find.byType(EditableText));
    expect(text.left - field.left, closeTo(52, 2));
  });

  testWidgets('RTL: prefix icon is right of the text, no overflow',
      (tester) async {
    await pumpTestApp(
      tester,
      const AppTextField(label: 'Email', prefixIcon: Icons.mail_outline),
      rtl: true,
    );
    final icon = tester.getRect(find.byIcon(Icons.mail_outline));
    final text = tester.getRect(find.byType(EditableText));
    expect(icon.center.dx, greaterThan(text.center.dx));
    expect(tester.takeException(), isNull);
  });
}
