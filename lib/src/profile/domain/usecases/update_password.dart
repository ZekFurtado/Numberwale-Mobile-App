import 'package:equatable/equatable.dart';
import 'package:numberwale/core/usecases/usecase.dart';
import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/profile/domain/repositories/profile_repository.dart';

/// Use case to update the user's password
class UpdatePassword extends UseCaseWithParams<void, UpdatePasswordParams> {
  final ProfileRepository _repository;

  UpdatePassword(this._repository);

  @override
  ResultVoid call(UpdatePasswordParams params) {
    return _repository.updatePassword(
      oldPassword: params.oldPassword,
      newPassword: params.newPassword,
    );
  }
}

class UpdatePasswordParams extends Equatable {
  final String oldPassword;
  final String newPassword;

  const UpdatePasswordParams({
    required this.oldPassword,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [oldPassword, newPassword];
}
