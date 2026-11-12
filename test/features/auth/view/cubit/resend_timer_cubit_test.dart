import 'package:flutter_test/flutter_test.dart';

import 'package:found_it/features/auth/view/cubit/resend_timer_cubit.dart';

void main() {
  testWidgets('starts at 45 and cannot resend', (tester) async {
    final cubit = ResendTimerCubit();
    expect(cubit.state, 45);
    expect(cubit.canResend, isFalse);
    await cubit.close();
  });

  testWidgets('counts down by one each second', (tester) async {
    final cubit = ResendTimerCubit();
    await tester.pump(const Duration(seconds: 1));
    expect(cubit.state, 44);
    await cubit.close();
  });

  testWidgets('reaches 0 after 45s and stays at 0', (tester) async {
    final cubit = ResendTimerCubit();
    await tester.pump(const Duration(seconds: 45));
    expect(cubit.state, 0);
    expect(cubit.canResend, isTrue);
    await tester.pump(const Duration(seconds: 10));
    expect(cubit.state, 0);
    await cubit.close();
  });

  testWidgets('resend while counting does nothing', (tester) async {
    final cubit = ResendTimerCubit();
    await tester.pump(const Duration(seconds: 10));
    cubit.resend();
    expect(cubit.state, 35);
    await cubit.close();
  });

  testWidgets('resend at 0 restarts at 45', (tester) async {
    final cubit = ResendTimerCubit();
    await tester.pump(const Duration(seconds: 45));
    cubit.resend();
    expect(cubit.state, 45);
    expect(cubit.canResend, isFalse);
    await tester.pump(const Duration(seconds: 1));
    expect(cubit.state, 44);
    await cubit.close();
  });

  testWidgets('custom cooldown works', (tester) async {
    final cubit = ResendTimerCubit(cooldown: const Duration(seconds: 3));
    expect(cubit.state, 3);
    await tester.pump(const Duration(seconds: 3));
    expect(cubit.state, 0);
    expect(cubit.canResend, isTrue);
    await cubit.close();
  });

  test('format gives mm:ss', () {
    expect(ResendTimerCubit.format(45), '00:45');
    expect(ResendTimerCubit.format(5), '00:05');
    expect(ResendTimerCubit.format(75), '01:15');
  });
}
