import 'package:equatable/equatable.dart';
import 'package:numberwale/core/usecases/usecase.dart';
import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/home/domain/entities/phone_number.dart';
import 'package:numberwale/src/home/domain/repositories/home_repository.dart';

/// This use case executes the business logic for fetching featured phone numbers.
/// The execution will move to the data layer by automatically calling the method
/// of the subclass of the dependency based on the dependency injection defined
/// in [lib/core/services/injection_container.dart]
class GetFeaturedNumbers
    extends UseCaseWithParams<List<PhoneNumber>, GetFeaturedNumbersParams> {
  /// Depends on the [HomeRepository] for its operations
  final HomeRepository repository;

  GetFeaturedNumbers(this.repository);

  @override
  ResultFuture<List<PhoneNumber>> call(GetFeaturedNumbersParams params) {
    return repository.getFeaturedNumbers(limit: params.limit);
  }
}

/// Parameters for fetching featured numbers
class GetFeaturedNumbersParams extends Equatable {
  final int limit;

  const GetFeaturedNumbersParams({this.limit = 10});

  @override
  List<Object?> get props => [limit];
}
