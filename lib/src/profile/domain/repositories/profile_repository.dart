import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/profile/domain/entities/user_profile.dart';

abstract class ProfileRepository {
  /// Get current user's profile
  ResultFuture<UserProfile> getProfile();

  /// Update user profile
  ResultFuture<UserProfile> updateProfile({
    required String name,
    required String email,
    required String mobile,
    String? accountType,
    String? companyName,
    String? gstinNo,
    bool? getWhatsappUpdate,
    bool? acceptTermsAndConditions,
  });

  /// Update user password
  ResultVoid updatePassword({
    required String oldPassword,
    required String newPassword,
  });
}
