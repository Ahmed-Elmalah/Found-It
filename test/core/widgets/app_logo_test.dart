import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:found_it/core/widgets/app_logo.dart';
import 'package:found_it/core/widgets/line_icon.dart';

import '../../helpers/test_app.dart';

Color? _tileColor(WidgetTester tester) {
  final box = tester.widget<Container>(
    find.descendant(
      of: find.byType(AppLogo),
      matching: find.byType(Container),
    ),
  );
  return (box.decoration! as BoxDecoration).color;
}

ColorScheme _scheme(WidgetTester tester) =>
    Theme.of(tester.element(find.byType(AppLogo))).colorScheme;

void main() {
  testWidgets('default size is 96x96', (tester) async {
    await pumpTestApp(tester, const AppLogo());
    expect(tester.getSize(find.byType(AppLogo)), const Size(96, 96));
  });

  testWidgets('custom size 48 is 48x48', (tester) async {
    await pumpTestApp(tester, const AppLogo(size: 48));
    expect(tester.getSize(find.byType(AppLogo)), const Size(48, 48));
  });

  testWidgets('light theme tile is surface', (tester) async {
    await pumpTestApp(tester, const AppLogo());
    expect(_tileColor(tester), _scheme(tester).surface);
  });

  testWidgets('dark theme tile is primary', (tester) async {
    await pumpTestApp(tester, const AppLogo(), dark: true);
    expect(_tileColor(tester), _scheme(tester).primary);
  });

  testWidgets('contains the searchCheck line icon', (tester) async {
    await pumpTestApp(tester, const AppLogo());
    final icon = tester.widget<LineIcon>(find.byType(LineIcon));
    expect(icon.type, LineIconType.searchCheck);
  });

  testWidgets('custom colors override defaults', (tester) async {
    await pumpTestApp(
      tester,
      const AppLogo(tileColor: Colors.red, iconColor: Colors.blue),
    );
    expect(_tileColor(tester), Colors.red);
    expect(tester.widget<LineIcon>(find.byType(LineIcon)).color, Colors.blue);
  });
}
