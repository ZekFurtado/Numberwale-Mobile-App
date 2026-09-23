import 'package:numberwale/src/authentication/domain/entities/local_user.dart';
import 'package:numberwale/src/authentication/domain/repositories/auth_repository.dart';

/// Returns the locally cached user from a previous session, or null if
/// there isn't one — a pure local read, never a network call. Used to
/// restore [AuthenticationBloc]'s state after an app restart so pages that
/// fall back to it (e.g. the profile summary) have something to show
/// immediately, instead of waiting on a network round trip.
class GetCurrentUser {
  const GetCurrentUser(this._repository);

  final AuthRepository _repository;

  Future<LocalUser?> call() => _repository.getCurrentUser();
}
