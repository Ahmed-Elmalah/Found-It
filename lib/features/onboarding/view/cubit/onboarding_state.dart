part of 'onboarding_cubit.dart';

class OnboardingState extends Equatable {
  const OnboardingState({this.page = 0, this.completed = false});

  final int page;
  final bool completed;

  bool get isLastPage => page == OnboardingCubit.pageCount - 1;

  OnboardingState copyWith({int? page, bool? completed}) => OnboardingState(
    page: page ?? this.page,
    completed: completed ?? this.completed,
  );

  @override
  List<Object?> get props => [page, completed];
}
