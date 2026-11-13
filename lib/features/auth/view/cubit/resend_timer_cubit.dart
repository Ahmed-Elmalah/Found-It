import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:found_it/core/constants/app_durations.dart';

/// Countdown for the "Resend email" button on the Verify email screen (P10).
/// The state is the number of seconds left; 0 means the user can resend.
class ResendTimerCubit extends Cubit<int> {
  ResendTimerCubit({this.cooldown = AppDurations.resendCooldown})
    : super(cooldown.inSeconds) {
    _start();
  }

  final Duration cooldown;
  Timer? _timer;

  bool get canResend => state == 0;

  void _start() {
    _timer?.cancel();
    if (state != cooldown.inSeconds) emit(cooldown.inSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (isClosed) {
        timer.cancel();
        return;
      }
      final next = state - 1;
      emit(next);
      if (next <= 0) timer.cancel();
    });
  }

  void resend() {
    if (!canResend) return;
    // TODO(stage 8): call Supabase auth.resend(type: OtpType.signup, email: ...)
    // here. For now this only restarts the countdown (UI only).
    _start();
  }

  /// 45 -> '00:45', 5 -> '00:05', 75 -> '01:15'.
  static String format(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
