abstract interface class OnboardingRepository {
  bool isFirstLaunch();
  Future<void> completeOnboarding();
}
