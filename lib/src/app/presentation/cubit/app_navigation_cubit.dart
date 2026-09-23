import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:numberwale/core/models/filter_models.dart';

part 'app_navigation_state.dart';

class AppNavigationCubit extends Cubit<AppNavigationState> {
  AppNavigationCubit() : super(const AppNavigationState(selectedIndex: homeTab));

  /// Bottom-navigation tab indices. Use these instead of bare numbers so
  /// adding or reordering a tab stays a one-line change.
  static const int homeTab = 0;
  static const int exploreTab = 1;
  static const int offersTab = 2;
  static const int numerologyTab = 3;
  static const int accountTab = 4;
  static const int tabCount = 5;

  void selectTab(int index) {
    if (index >= 0 && index < tabCount) {
      emit(AppNavigationState(selectedIndex: index));
    }
  }

  void selectTabWithSearch(int index, String query) {
    if (index >= 0 && index < tabCount) {
      emit(AppNavigationState(selectedIndex: index, initialSearchQuery: query));
    }
  }

  void selectTabWithFilters(int index, NumberFilters filters) {
    if (index >= 0 && index < tabCount) {
      emit(AppNavigationState(selectedIndex: index, initialFilters: filters));
    }
  }
}
