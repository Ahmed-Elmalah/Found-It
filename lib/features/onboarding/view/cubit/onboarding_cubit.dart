import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:found_it/features/onboarding/domain/complete_onboarding_use_case.dart';

part 'onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit(this._completeOnboarding) : super(const OnboardingState());

  static const int pageCount = 3;

  final CompleteOnboardingUseCase _completeOnboarding;

  void pageChanged(int page) {
    emit(state.copyWith(page: page.clamp(0, pageCount - 1)));
  }

  Future<void> complete() async {
    try {
      await _completeOnboarding();
    } catch (_) {
      // Saving failed: still let the user in. Worst case the onboarding
      // shows once more on the next launch.
    }
    if (isClosed) return;
    emit(state.copyWith(completed: true));
  }
}
