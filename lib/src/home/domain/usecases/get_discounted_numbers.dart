import 'package:equatable/equatable.dart';
import 'package:numberwale/core/usecases/usecase.dart';
import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/home/domain/entities/phone_number.dart';
import 'package:numberwale/src/home/domain/repositories/home_repository.dart';

class GetDiscountedNumbers
    extends UseCaseWithParams<List<PhoneNumber>, GetDiscountedNumbersParams> {
  final HomeRepository repository;

  GetDiscountedNumbers(this.repository);

  @override
  ResultFuture<List<PhoneNumber>> call(GetDiscountedNumbersParams params) {
    return repository.getDiscountedNumbers(limit: params.limit);
  }
}

class GetDiscountedNumbersParams extends Equatable {
  final int limit;

  const GetDiscountedNumbersParams({this.limit = 10});

  @override
  List<Object?> get props => [limit];
}
