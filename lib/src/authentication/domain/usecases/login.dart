import 'package:equatable/equatable.dart';
import 'package:numberwale/core/usecases/usecase.dart';
import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/authentication/domain/entities/local_user.dart';
import 'package:numberwale/src/authentication/domain/repositories/auth_repository.dart';

/// Use case for user login with email/mobile and password
///
/// Authenticates user with their registered email or mobile number and password.
/// Returns authenticated user data on success.
class Login extends UseCaseWithParams<LocalUser, LoginParams> {
  final AuthRepository _repository;

  Login(this._repository);

  @override
  ResultFuture<LocalUser> call(LoginParams params) {
    return _repository.login(
      contact: params.contact,
      password: params.password,
    );
  }
}

class LoginParams extends Equatable {
  final String contact; // Can be email or mobile
  final String password;

  const LoginParams({
    required this.contact,
    required this.password,
  });

  @override
  List<Object?> get props => [contact, password];
}
