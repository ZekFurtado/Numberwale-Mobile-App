part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load all home screen data (banners, categories, numbers)
class LoadHomeDataEvent extends HomeEvent {
  const LoadHomeDataEvent();
}

/// Event to refresh home screen data (pull-to-refresh)
class RefreshHomeDataEvent extends HomeEvent {
  const RefreshHomeDataEvent();
}
