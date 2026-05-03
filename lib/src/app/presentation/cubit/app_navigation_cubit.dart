import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:numberwale/core/models/filter_models.dart';

part 'app_navigation_state.dart';

class AppNavigationCubit extends Cubit<AppNavigationState> {
  AppNavigationCubit() : super(const AppNavigationState(selectedIndex: 0));

  void selectTab(int index) {
    if (index >= 0 && index < 4) {
      emit(AppNavigationState(selectedIndex: index));
    }
  }

  void selectTabWithSearch(int index, String query) {
    if (index >= 0 && index < 4) {
      emit(AppNavigationState(selectedIndex: index, initialSearchQuery: query));
    }
  }

  void selectTabWithFilters(int index, NumberFilters filters) {
    if (index >= 0 && index < 4) {
      emit(AppNavigationState(selectedIndex: index, initialFilters: filters));
    }
  }
}
