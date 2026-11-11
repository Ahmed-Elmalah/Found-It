import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:found_it/core/constants/app_durations.dart';
import 'package:found_it/features/auth/domain/has_active_session_use_case.dart';
import 'package:found_it/features/onboarding/domain/is_first_launch_use_case.dart';

part 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  SplashCubit(
    this._isFirstLaunch,
    this._hasActiveSession, {
    this.minDisplay = AppDurations.splash,
  }) : super(const SplashInitial());

  final IsFirstLaunchUseCase _isFirstLaunch;
  final HasActiveSessionUseCase _hasActiveSession;
  final Duration minDisplay;

  bool _started = false;

  Future<void> start() async {
    if (_started) return;
    _started = true;

    final stopwatch = Stopwatch()..start();
    final destination = _decide();

    final remaining = minDisplay - stopwatch.elapsed;
    await Future<void>.delayed(
      remaining.isNegative ? Duration.zero : remaining,
    );

    if (isClosed) return;
    emit(SplashNavigate(destination));
  }

  SplashDestination _decide() {
    try {
      if (_isFirstLaunch()) return SplashDestination.onboarding;
      return _hasActiveSession()
          ? SplashDestination.home
          : SplashDestination.login;
    } catch (_) {
      return SplashDestination.login;
    }
  }
}
