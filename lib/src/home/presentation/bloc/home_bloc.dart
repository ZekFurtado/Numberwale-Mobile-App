import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:numberwale/src/home/domain/entities/banner.dart';
import 'package:numberwale/src/home/domain/entities/category.dart';
import 'package:numberwale/src/home/domain/entities/phone_number.dart';
import 'package:numberwale/src/home/domain/usecases/get_banners.dart';
import 'package:numberwale/src/home/domain/usecases/get_categories.dart';
import 'package:numberwale/src/home/domain/usecases/get_deal_of_the_day.dart';
import 'package:numberwale/src/home/domain/usecases/get_discounted_numbers.dart';
import 'package:numberwale/src/products/domain/entities/product_filters.dart';
import 'package:numberwale/src/products/domain/entities/product_result.dart';
import 'package:numberwale/src/products/domain/usecases/get_products.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({
    required GetBanners getBanners,
    required GetCategories getCategories,
    required GetDiscountedNumbers getDiscountedNumbers,
    required GetProducts getNewlyAddedProducts,
    required GetProducts getPremiumProducts,
    required GetDealOfTheDay getDealOfTheDay,
  }) : _getBanners = getBanners,
       _getCategories = getCategories,
       _getDiscountedNumbers = getDiscountedNumbers,
       _getNewlyAddedProducts = getNewlyAddedProducts,
       _getPremiumProducts = getPremiumProducts,
       _getDealOfTheDay = getDealOfTheDay,
       super(const HomeInitial()) {
    on<LoadHomeDataEvent>(_loadHomeDataHandler);
    on<RefreshHomeDataEvent>(_refreshHomeDataHandler);
  }

  final GetBanners _getBanners;
  final GetCategories _getCategories;
  final GetDiscountedNumbers _getDiscountedNumbers;
  final GetProducts _getNewlyAddedProducts;
  final GetProducts _getPremiumProducts;
  final GetDealOfTheDay _getDealOfTheDay;

  /// Matches the "Newly Added VIP Numbers" API spec exactly: last 7 days,
  /// newest first, DB count query skipped for speed.
  static const _newlyAddedParams = GetProductsParams(
    filters: ProductFilters(
      recentDays: 7,
      sort: '-createdAt',
      limit: 12,
      skipCount: true,
    ),
  );

  /// "Premium Numbers": the same `get-products` listing endpoint, sorted by
  /// price (highest first) to surface the top-value numbers across all
  /// categories.
  static const _premiumParams = GetProductsParams(
    filters: ProductFilters(
      sortPrice: 'highToLow',
      limit: 10,
      skipCount: true,
    ),
  );

  Future<void> _loadHomeDataHandler(
    LoadHomeDataEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(const LoadingHomeData());

    final results = await Future.wait([
      _getBanners(),
      _getCategories(),
      _getDiscountedNumbers(const GetDiscountedNumbersParams(limit: 10)),
      _getNewlyAddedProducts(_newlyAddedParams),
      _getDealOfTheDay(),
      _getPremiumProducts(_premiumParams),
    ]);

    final bannersResult = results[0];
    final categoriesResult = results[1];
    final discountedResult = results[2];
    final newlyAddedResult = results[3];
    final dealOfTheDayResult = results[4];
    final premiumResult = results[5];

    if (categoriesResult.isLeft()) {
      final failure = categoriesResult.fold((l) => l, (r) => null);
      log(failure?.message ?? 'Categories failed');
      emit(HomeError(message: failure?.message ?? 'Failed to load categories'));
      return;
    }

    emit(
      HomeDataLoaded(
        banners: bannersResult.fold(
          (l) => <Banner>[],
          (r) => r as List<Banner>,
        ),
        categories: categoriesResult.fold(
          (l) => <Category>[],
          (r) => r as List<Category>,
        ),
        discountedNumbers: discountedResult.fold(
          (l) => <PhoneNumber>[],
          (r) => r as List<PhoneNumber>,
        ),
        newlyAddedNumbers: newlyAddedResult.fold(
          (l) => <PhoneNumber>[],
          (r) => (r as ProductResult).products,
        ),
        dealOfTheDayNumbers: dealOfTheDayResult.fold(
          (l) => <PhoneNumber>[],
          (r) => r as List<PhoneNumber>,
        ),
        premiumNumbers: premiumResult.fold(
          (l) => <PhoneNumber>[],
          (r) => (r as ProductResult).products,
        ),
      ),
    );
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
      _getNewlyAddedProducts(_newlyAddedParams),
      _getDealOfTheDay(),
      _getPremiumProducts(_premiumParams),
    ]);

    final bannersResult = results[0];
    final categoriesResult = results[1];
    final discountedResult = results[2];
    final newlyAddedResult = results[3];
    final dealOfTheDayResult = results[4];
    final premiumResult = results[5];

    final banners = bannersResult.fold(
      (l) => <Banner>[],
      (r) => r as List<Banner>,
    );
    final categories = categoriesResult.fold(
      (l) => <Category>[],
      (r) => r as List<Category>,
    );
    final discountedNumbers = discountedResult.fold(
      (l) => <PhoneNumber>[],
      (r) => r as List<PhoneNumber>,
    );
    final newlyAddedNumbers = newlyAddedResult.fold(
      (l) => <PhoneNumber>[],
      (r) => (r as ProductResult).products,
    );
    final dealOfTheDayNumbers = dealOfTheDayResult.fold(
      (l) => <PhoneNumber>[],
      (r) => r as List<PhoneNumber>,
    );
    final premiumNumbers = premiumResult.fold(
      (l) => <PhoneNumber>[],
      (r) => (r as ProductResult).products,
    );

    emit(
      HomeDataLoaded(
        banners: banners,
        categories: categories,
        discountedNumbers: discountedNumbers,
        newlyAddedNumbers: newlyAddedNumbers,
        dealOfTheDayNumbers: dealOfTheDayNumbers,
        premiumNumbers: premiumNumbers,
      ),
    );
  }
}
