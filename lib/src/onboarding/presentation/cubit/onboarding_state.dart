part of 'onboarding_cubit.dart';

class OnboardingState extends Equatable {
  const OnboardingState({required this.currentPage});

  final int currentPage;

  @override
  List<Object> get props => [currentPage];
}
