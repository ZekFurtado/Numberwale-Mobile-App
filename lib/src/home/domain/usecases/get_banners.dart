import 'package:numberwale/core/usecases/usecase.dart';
import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/home/domain/entities/banner.dart';
import 'package:numberwale/src/home/domain/repositories/home_repository.dart';

/// This use case executes the business logic for fetching promotional banners.
/// The execution will move to the data layer by automatically calling the method
/// of the subclass of the dependency based on the dependency injection defined
/// in [lib/core/services/injection_container.dart]
class GetBanners extends UseCaseWithoutParams<List<Banner>> {
  /// Depends on the [HomeRepository] for its operations
  final HomeRepository repository;

  GetBanners(this.repository);

  @override
  ResultFuture<List<Banner>> call() {
    return repository.getBanners();
  }
}
