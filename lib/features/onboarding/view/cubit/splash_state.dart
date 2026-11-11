part of 'splash_cubit.dart';

enum SplashDestination { onboarding, login, home }

sealed class SplashState extends Equatable {
  const SplashState();

  @override
  List<Object?> get props => [];
}

final class SplashInitial extends SplashState {
  const SplashInitial();
}

final class SplashNavigate extends SplashState {
  const SplashNavigate(this.destination);

  final SplashDestination destination;

  @override
  List<Object?> get props => [destination];
}
