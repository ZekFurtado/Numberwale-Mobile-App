import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit() : super(const OnboardingState(currentPage: 0));

  void nextPage() {
    if (state.currentPage < 2) {
      // 3 pages total (0, 1, 2)
      emit(OnboardingState(currentPage: state.currentPage + 1));
    }
  }

  void previousPage() {
    if (state.currentPage > 0) {
      emit(OnboardingState(currentPage: state.currentPage - 1));
    }
  }

  void goToPage(int page) {
    if (page >= 0 && page <= 2) {
      emit(OnboardingState(currentPage: page));
    }
  }
}
