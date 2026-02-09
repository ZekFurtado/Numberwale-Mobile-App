import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/home/domain/entities/banner.dart';
import 'package:numberwale/src/home/domain/entities/category.dart';
import 'package:numberwale/src/home/domain/entities/phone_number.dart';

/// Contains all the methods specific for home screen data operations
abstract class HomeRepository {
  /// Automatically calls the respective class that implements this abstract
  /// class due to the dependency injection at runtime.
  ///
  /// In this case, since the dependencies are already set by the [sl] service
  /// locator, the respective subclass' method will be called.

  /// Fetches promotional banners for the home screen
  ResultFuture<List<Banner>> getBanners();

  /// Fetches all active categories with their counts
  ResultFuture<List<Category>> getCategories();

  /// Fetches featured/VIP numbers for the home screen
  ResultFuture<List<PhoneNumber>> getFeaturedNumbers({int limit = 10});

  /// Fetches latest/recently added numbers for the home screen
  ResultFuture<List<PhoneNumber>> getLatestNumbers({int limit = 10});

  /// Fetches trending numbers based on views/searches
  ResultFuture<List<PhoneNumber>> getTrendingNumbers({int limit = 10});
}
