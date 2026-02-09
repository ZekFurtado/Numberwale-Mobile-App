part of 'app_navigation_cubit.dart';

class AppNavigationState extends Equatable {
  const AppNavigationState({required this.selectedIndex});

  final int selectedIndex;

  @override
  List<Object> get props => [selectedIndex];
}
