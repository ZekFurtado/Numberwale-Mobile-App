part of 'app_navigation_cubit.dart';

class AppNavigationState extends Equatable {
  const AppNavigationState({
    required this.selectedIndex,
    this.initialSearchQuery,
  });

  final int selectedIndex;
  final String? initialSearchQuery;

  @override
  List<Object?> get props => [selectedIndex, initialSearchQuery];
}
