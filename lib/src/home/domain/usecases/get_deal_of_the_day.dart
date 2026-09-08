import 'package:numberwale/core/usecases/usecase.dart';
import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/home/domain/entities/phone_number.dart';
import 'package:numberwale/src/home/domain/repositories/home_repository.dart';

/// This use case executes the business logic for fetching the actively
/// running "Deal of the Day" numbers.
class GetDealOfTheDay extends UseCaseWithoutParams<List<PhoneNumber>> {
  /// Depends on the [HomeRepository] for its operations
  final HomeRepository repository;

  GetDealOfTheDay(this.repository);

  @override
  ResultFuture<List<PhoneNumber>> call() {
    return repository.getDealOfTheDay();
  }
}
