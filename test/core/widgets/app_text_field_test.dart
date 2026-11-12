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

  testWidgets('hasError uses the theme error color for borders', (
    tester,
  ) async {
    await pumpTestApp(
      tester,
      const AppTextField(label: 'Email', hasError: true),
    );
    final errorColor = Theme.of(tester.element(find.byType(TextField)))
        .colorScheme
        .error;
    final decoration = tester
        .widget<TextField>(find.byType(TextField))
        .decoration!;
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

  testWidgets('field is 56 high and text starts 52 after the start edge', (
    tester,
  ) async {
    await pumpTestApp(
      tester,
      const AppTextField(label: 'Email', prefixIcon: Icons.mail_outline),
    );
    final field = tester.getRect(find.byType(TextField));
    expect(field.height, 56);
    final text = tester.getRect(find.byType(EditableText));
    expect(text.left - field.left, closeTo(52, 2));
  });

  testWidgets('RTL: prefix icon is right of the text, no overflow', (
    tester,
  ) async {
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

  testWidgets('helper text aligns with field start, 8 below', (tester) async {
    await pumpTestApp(
      tester,
      const AppTextField(
        label: 'Password',
        prefixIcon: Icons.lock_outline,
        helperText: 'At least 8 characters',
      ),
    );
    final field = tester.getRect(find.byType(TextField));
    final helper = tester.getRect(find.text('At least 8 characters'));
    expect(helper.left, closeTo(field.left, 1));
    expect(helper.top - field.bottom, closeTo(8, 2));
  });

  testWidgets('error text aligns with field start and border is red', (
    tester,
  ) async {
    final formKey = GlobalKey<FormState>();
    await pumpTestApp(
      tester,
      Form(
        key: formKey,
        child: AppTextField(label: 'Email', validator: (_) => 'Required'),
      ),
    );
    formKey.currentState!.validate();
    await tester.pump();
    final field = tester.getRect(find.byType(TextField));
    expect(tester.getRect(find.text('Required')).left, closeTo(field.left, 1));
    final errorColor = Theme.of(tester.element(find.byType(TextField)))
        .colorScheme
        .error;
    final decoration = tester
        .widget<TextField>(find.byType(TextField))
        .decoration!;
    expect(
      (decoration.enabledBorder! as OutlineInputBorder).borderSide.color,
      errorColor,
    );
  });

  testWidgets('RTL: helper text right edge equals field right edge', (
    tester,
  ) async {
    await pumpTestApp(
      tester,
      const AppTextField(label: 'Password', helperText: 'At least 8'),
      rtl: true,
    );
    final field = tester.getRect(find.byType(TextField));
    final helper = tester.getRect(find.text('At least 8'));
    expect(helper.right, closeTo(field.right, 1));
  });

  for (final external in [false, true]) {
    testWidgets(
      'validator receives typed value (external controller: $external)',
      (tester) async {
        final formKey = GlobalKey<FormState>();
        String? received;
        await pumpTestApp(
          tester,
          Form(
            key: formKey,
            child: AppTextField(
              label: 'Email',
              controller: external ? TextEditingController() : null,
              validator: (v) {
                received = v;
                return null;
              },
            ),
          ),
        );
        await tester.enterText(find.byType(TextField), 'abc@x.com');
        formKey.currentState!.validate();
        expect(received, 'abc@x.com');
      },
    );
  }

  testWidgets('isRequired shows red asterisk next to label', (tester) async {
    await pumpTestApp(
      tester,
      const AppTextField(label: 'Item title', isRequired: true),
    );
    expect(find.textContaining('Item title'), findsOneWidget);
    expect(find.textContaining('*'), findsOneWidget);
  });

  testWidgets('maxLength shows end-aligned counter and updates on typing', (tester) async {
    await pumpTestApp(
      tester,
      const AppTextField(label: 'Item title', maxLength: 50),
    );
    expect(find.text('0/50'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Wallet');
    await tester.pump();
    expect(find.text('6/50'), findsOneWidget);
  });

  testWidgets('showErrorIcon displays error_outline icon before error message', (tester) async {
    final formKey = GlobalKey<FormState>();
    await pumpTestApp(
      tester,
      Form(
        key: formKey,
        child: AppTextField(
          label: 'Item title',
          showErrorIcon: true,
          validator: (_) => 'Required',
        ),
      ),
    );
    expect(find.byIcon(Icons.error_outline), findsNothing);
    formKey.currentState!.validate();
    await tester.pump();
    expect(find.text('Required'), findsOneWidget);
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
  });

  testWidgets('forceLtr keeps phone numbers left-to-right in Arabic', (
    tester,
  ) async {
    final controller = TextEditingController(text: '10 1234 5678');
    addTearDown(controller.dispose);
    await pumpTestApp(
      tester,
      AppTextField(
        label: 'رقم الهاتف',
        prefixIcon: Icons.phone_iphone,
        prefixText: '+20',
        controller: controller,
        forceLtr: true,
      ),
      rtl: true,
    );

    final editable = tester.widget<EditableText>(find.byType(EditableText));
    expect(editable.textDirection, TextDirection.ltr);
    expect(editable.textAlign, TextAlign.right); // stays on the icon side
    final prefix = tester.widget<Text>(find.text('+20'));
    expect(prefix.textDirection, TextDirection.ltr);
    expect(tester.takeException(), isNull);
  });

  testWidgets('without forceLtr the text follows the app direction', (
    tester,
  ) async {
    await pumpTestApp(tester, const AppTextField(label: 'الاسم'), rtl: true);
    final editable = tester.widget<EditableText>(find.byType(EditableText));
    // null = inherited from the screen (Arabic -> right-to-left)
    expect(editable.textDirection, isNull);
    expect(
      Directionality.of(tester.element(find.byType(EditableText))),
      TextDirection.rtl,
    );
  });
}
