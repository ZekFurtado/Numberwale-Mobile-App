import 'package:numberwale/core/usecases/usecase.dart';
import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/authentication/domain/entities/local_user.dart';
import 'package:numberwale/src/authentication/domain/repositories/auth_repository.dart';

/// Use case for refreshing authentication tokens
///
/// Refreshes access and refresh tokens using the existing refresh token cookie.
/// This is typically called automatically by an HTTP interceptor when the
/// access token expires (401 response).
///
/// Returns updated user data on success.
class RefreshToken extends UseCaseWithoutParams<LocalUser> {
  final AuthRepository _repository;

  RefreshToken(this._repository);

  @override
  ResultFuture<LocalUser> call() {
    return _repository.refreshToken();
  }
}
