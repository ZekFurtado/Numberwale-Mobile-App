part of 'app_navigation_cubit.dart';

class AppNavigationState extends Equatable {
  const AppNavigationState({
    required this.selectedIndex,
    this.initialSearchQuery,
    this.initialFilters,
  });

  final int selectedIndex;
  final String? initialSearchQuery;
  final NumberFilters? initialFilters;

  @override
  List<Object?> get props => [selectedIndex, initialSearchQuery, initialFilters];
}
