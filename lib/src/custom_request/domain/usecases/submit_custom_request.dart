import 'package:equatable/equatable.dart';
import 'package:numberwale/core/usecases/usecase.dart';
import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/custom_request/domain/entities/custom_request.dart';
import 'package:numberwale/src/custom_request/domain/repositories/custom_request_repository.dart';

class SubmitCustomRequest
    extends UseCaseWithParams<CustomRequest, SubmitCustomRequestParams> {
  final CustomRequestRepository _repository;

  SubmitCustomRequest(this._repository);

  @override
  ResultFuture<CustomRequest> call(SubmitCustomRequestParams params) {
    return _repository.submitRequest(
      requested: params.requested,
      category: params.category,
      userId: params.userId,
      name: params.name,
      email: params.email,
      mobileNo: params.mobileNo,
      city: params.city,
      phoneword: params.phoneword,
    );
  }
}

class SubmitCustomRequestParams extends Equatable {
  final String requested;
  final String category;
  final String? userId;
  final String? name;
  final String? email;
  final String? mobileNo;
  final String? city;
  final String? phoneword;

  const SubmitCustomRequestParams({
    required this.requested,
    required this.category,
    this.userId,
    this.name,
    this.email,
    this.mobileNo,
    this.city,
    this.phoneword,
  });

  @override
  List<Object?> get props => [
        requested,
        category,
        userId,
        name,
        email,
        mobileNo,
        city,
        phoneword,
      ];
}
