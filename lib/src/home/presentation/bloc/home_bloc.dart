import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:numberwale/src/home/domain/entities/banner.dart';
import 'package:numberwale/src/home/domain/entities/category.dart';
import 'package:numberwale/src/home/domain/entities/phone_number.dart';
import 'package:numberwale/src/home/domain/usecases/get_banners.dart';
import 'package:numberwale/src/home/domain/usecases/get_categories.dart';
import 'package:numberwale/src/home/domain/usecases/get_featured_numbers.dart';
import 'package:numberwale/src/home/domain/usecases/get_latest_numbers.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({
    required GetBanners getBanners,
    required GetCategories getCategories,
    required GetFeaturedNumbers getFeaturedNumbers,
    required GetLatestNumbers getLatestNumbers,
  })  : _getBanners = getBanners,
        _getCategories = getCategories,
        _getFeaturedNumbers = getFeaturedNumbers,
        _getLatestNumbers = getLatestNumbers,
        super(const HomeInitial()) {
    on<LoadHomeDataEvent>(_loadHomeDataHandler);
    on<RefreshHomeDataEvent>(_refreshHomeDataHandler);
  }

  final GetBanners _getBanners;
  final GetCategories _getCategories;
  final GetFeaturedNumbers _getFeaturedNumbers;
  final GetLatestNumbers _getLatestNumbers;

  Future<void> _loadHomeDataHandler(
    LoadHomeDataEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(const LoadingHomeData());

    // Load all data in parallel
    final results = await Future.wait([
      _getBanners(),
      _getCategories(),
      _getFeaturedNumbers(const GetFeaturedNumbersParams(limit: 10)),
      _getLatestNumbers(const GetLatestNumbersParams(limit: 10)),
    ]);

    // Check if all succeeded
    final bannersResult = results[0];
    final categoriesResult = results[1];
    final featuredNumbersResult = results[2];
    final latestNumbersResult = results[3];

    // Handle categories - this endpoint is now active
    if (categoriesResult.isLeft()) {
      final failure = categoriesResult.fold((l) => l, (r) => null);
      log(failure?.message ?? "Categories Failed");
      emit(
          HomeError(message: failure?.message ?? 'Failed to load categories'));
      return;
    }

    // Extract data - banners, featured, and latest are disabled, so return empty lists
    // Categories should return real data from API
    // UI will fall back to mock data for disabled endpoints
    final banners =
        bannersResult.fold((l) => <Banner>[], (r) => r as List<Banner>);
    final categories =
        categoriesResult.fold((l) => <Category>[], (r) => r as List<Category>);
    final featuredNumbers = featuredNumbersResult.fold(
        (l) => <PhoneNumber>[], (r) => r as List<PhoneNumber>);
    final latestNumbers = latestNumbersResult.fold(
        (l) => <PhoneNumber>[], (r) => r as List<PhoneNumber>);

    emit(HomeDataLoaded(
      banners: banners,
      categories: categories,
      featuredNumbers: featuredNumbers,
      latestNumbers: latestNumbers,
    ));
  }

  Future<void> _refreshHomeDataHandler(
    RefreshHomeDataEvent event,
    Emitter<HomeState> emit,
  ) async {
    // Emit loading but keep current data visible
    emit(const RefreshingHomeData());

    // Load all data in parallel
    final results = await Future.wait([
      _getBanners(),
      _getCategories(),
      _getFeaturedNumbers(const GetFeaturedNumbersParams(limit: 10)),
      _getLatestNumbers(const GetLatestNumbersParams(limit: 10)),
    ]);

    // Check if all succeeded
    final bannersResult = results[0];
    final categoriesResult = results[1];
    final featuredNumbersResult = results[2];
    final latestNumbersResult = results[3];

    // Extract data - banners, featured, and latest are disabled, so return empty lists
    // Categories should return real data from API
    // For refresh, we're lenient and show partial data even if categories fail
    final banners =
        bannersResult.fold((l) => <Banner>[], (r) => r as List<Banner>);
    final categories =
        categoriesResult.fold((l) => <Category>[], (r) => r as List<Category>);
    final featuredNumbers = featuredNumbersResult.fold(
        (l) => <PhoneNumber>[], (r) => r as List<PhoneNumber>);
    final latestNumbers = latestNumbersResult.fold(
        (l) => <PhoneNumber>[], (r) => r as List<PhoneNumber>);

    emit(HomeDataLoaded(
      banners: banners,
      categories: categories,
      featuredNumbers: featuredNumbers,
      latestNumbers: latestNumbers,
    ));
  }
}
