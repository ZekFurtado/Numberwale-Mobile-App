import 'package:equatable/equatable.dart';
import 'package:numberwale/core/usecases/usecase.dart';
import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/home/domain/entities/phone_number.dart';
import 'package:numberwale/src/products/domain/repositories/product_repository.dart';

/// Use case for getting a specific product by its mobile number
class GetProductByNumber
    extends UseCaseWithParams<PhoneNumber, GetProductByNumberParams> {
  final ProductRepository _repository;

  GetProductByNumber(this._repository);

  @override
  ResultFuture<PhoneNumber> call(GetProductByNumberParams params) {
    return _repository.getProductByNumber(params.number);
  }
}

class GetProductByNumberParams extends Equatable {
  final String number;

  const GetProductByNumberParams({required this.number});

  @override
  List<Object?> get props => [number];
}
