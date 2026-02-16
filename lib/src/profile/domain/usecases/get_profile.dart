import 'package:numberwale/core/usecases/usecase.dart';
import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/profile/domain/entities/user_profile.dart';
import 'package:numberwale/src/profile/domain/repositories/profile_repository.dart';

/// Use case to get current user's profile
class GetProfile extends UseCaseWithoutParams<UserProfile> {
  final ProfileRepository _repository;

  GetProfile(this._repository);

  @override
  ResultFuture<UserProfile> call() {
    return _repository.getProfile();
  }
}
