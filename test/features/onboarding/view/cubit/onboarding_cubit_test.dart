import 'package:flutter_test/flutter_test.dart';
import 'package:found_it/features/onboarding/domain/complete_onboarding_use_case.dart';
import 'package:found_it/features/onboarding/domain/onboarding_repository.dart';
import 'package:found_it/features/onboarding/view/cubit/onboarding_cubit.dart';

class _FakeRepo implements OnboardingRepository {
  int completeCalls = 0;

  @override
  bool isFirstLaunch() => true;

  @override
  Future<void> completeOnboarding() async => completeCalls++;
}

void main() {
  late _FakeRepo repo;
  late OnboardingCubit cubit;

  setUp(() {
    repo = _FakeRepo();
    cubit = OnboardingCubit(CompleteOnboardingUseCase(repo));
  });

  tearDown(() => cubit.close());

  test('initial page 0, not last, not completed', () {
    expect(cubit.state.page, 0);
    expect(cubit.state.isLastPage, isFalse);
    expect(cubit.state.completed, isFalse);
  });

  test('pageChanged(2) is last page', () {
    cubit.pageChanged(2);
    expect(cubit.state.page, 2);
    expect(cubit.state.isLastPage, isTrue);
  });

  test('out-of-range pages are clamped', () {
    cubit.pageChanged(7);
    expect(cubit.state.page, 2);
    cubit.pageChanged(-3);
    expect(cubit.state.page, 0);
  });

  test('complete calls use case once and emits completed', () async {
    await cubit.complete();
    expect(repo.completeCalls, 1);
    expect(cubit.state.completed, isTrue);
  });
}
