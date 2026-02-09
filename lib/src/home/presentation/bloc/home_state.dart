part of 'home_bloc.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class HomeInitial extends HomeState {
  const HomeInitial();
}

/// Loading home data for the first time
class LoadingHomeData extends HomeState {
  const LoadingHomeData();
}

/// Refreshing home data (pull-to-refresh)
class RefreshingHomeData extends HomeState {
  const RefreshingHomeData();
}

/// Home data loaded successfully
class HomeDataLoaded extends HomeState {
  const HomeDataLoaded({
    required this.banners,
    required this.categories,
    required this.featuredNumbers,
    required this.latestNumbers,
  });

  final List<Banner> banners;
  final List<Category> categories;
  final List<PhoneNumber> featuredNumbers;
  final List<PhoneNumber> latestNumbers;

  @override
  List<Object> get props => [
        banners,
        categories,
        featuredNumbers,
        latestNumbers,
      ];
}

/// Error occurred while loading home data
class HomeError extends HomeState {
  const HomeError({required this.message});

  final String message;

  @override
  List<Object> get props => [message];
}
