import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:numberwale/src/home/domain/entities/banner.dart';
import 'package:numberwale/src/home/domain/entities/category.dart';
import 'package:numberwale/src/home/domain/entities/phone_number.dart';
import 'package:numberwale/src/home/domain/usecases/get_banners.dart';
import 'package:numberwale/src/home/domain/usecases/get_categories.dart';
import 'package:numberwale/src/home/domain/usecases/get_discounted_numbers.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({
    required GetBanners getBanners,
    required GetCategories getCategories,
    required GetDiscountedNumbers getDiscountedNumbers,
  })  : _getBanners = getBanners,
        _getCategories = getCategories,
        _getDiscountedNumbers = getDiscountedNumbers,
        super(const HomeInitial()) {
    on<LoadHomeDataEvent>(_loadHomeDataHandler);
    on<RefreshHomeDataEvent>(_refreshHomeDataHandler);
  }

  final GetBanners _getBanners;
  final GetCategories _getCategories;
  final GetDiscountedNumbers _getDiscountedNumbers;

  Future<void> _loadHomeDataHandler(
    LoadHomeDataEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(const LoadingHomeData());

    final results = await Future.wait([
      _getBanners(),
      _getCategories(),
      _getDiscountedNumbers(const GetDiscountedNumbersParams(limit: 10)),
    ]);

    final bannersResult = results[0];
    final categoriesResult = results[1];
    final discountedResult = results[2];

    if (categoriesResult.isLeft()) {
      final failure = categoriesResult.fold((l) => l, (r) => null);
      log(failure?.message ?? 'Categories failed');
      emit(HomeError(message: failure?.message ?? 'Failed to load categories'));
      return;
    }

    emit(HomeDataLoaded(
      banners: bannersResult.fold((l) => <Banner>[], (r) => r as List<Banner>),
      categories: categoriesResult.fold(
          (l) => <Category>[], (r) => r as List<Category>),
      discountedNumbers: discountedResult.fold(
          (l) => <PhoneNumber>[], (r) => r as List<PhoneNumber>),
    ));
  }

  Future<void> _refreshHomeDataHandler(
    RefreshHomeDataEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(const RefreshingHomeData());

    final results = await Future.wait([
      _getBanners(),
      _getCategories(),
      _getDiscountedNumbers(const GetDiscountedNumbersParams(limit: 10)),
    ]);

    final bannersResult = results[0];
    final categoriesResult = results[1];
    final discountedResult = results[2];

    final banners =
        bannersResult.fold((l) => <Banner>[], (r) => r as List<Banner>);
    final categories =
        categoriesResult.fold((l) => <Category>[], (r) => r as List<Category>);
    final discountedNumbers = discountedResult.fold(
        (l) => <PhoneNumber>[], (r) => r as List<PhoneNumber>);

    emit(HomeDataLoaded(
      banners: banners,
      categories: categories,
      discountedNumbers: discountedNumbers,
    ));
  }
}
