import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'app_navigation_state.dart';

class AppNavigationCubit extends Cubit<AppNavigationState> {
  AppNavigationCubit() : super(const AppNavigationState(selectedIndex: 0));

  void selectTab(int index) {
    if (index >= 0 && index < 5) {
      emit(AppNavigationState(selectedIndex: index));
    }
  }
}
