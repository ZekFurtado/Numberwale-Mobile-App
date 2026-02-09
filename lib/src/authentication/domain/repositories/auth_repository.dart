import 'package:numberwale/core/utils/typedef.dart';

import '../entities/local_user.dart';

/// Contains all the methods specific for the authentication process
abstract class AuthRepository {
  /// Automatically calls the respective class that implements this abstract
  /// class due to the dependency injection at runtime. For eg:
  ///         AuthCubit(
  ///           SignIn(
  ///               AuthRepositoryImpl(
  ///                   AuthRemoteDataSourceImpl()
  ///               )
  ///           )
  ///       )
  ///
  /// In this case, since the dependencies are already set by the [sl] service
  /// locator, the respective subclass' method will be called.

  /// Register a new user and send OTP for verification
  /// Returns OTP expiry time and delivery channels on success
  ResultFuture<DataMap> register({
    required String name,
    required String email,
    required String password,
    required String mobile,
    required String accountType,
    bool getWhatsappUpdate = false,
    bool acceptTermsAndConditions = true,
    String? companyName,
    String? gstinNo,
  });

  /// Verify OTP sent during registration or login
  /// Returns authenticated user data on success
  ResultFuture<LocalUser> verifyOtp({
    String? email,
    String? mobile,
    required String otp,
  });

  /// Resend OTP to user's email or mobile
  /// Returns OTP expiry time and delivery channels on success
  ResultFuture<DataMap> resendOtp({
    String? email,
    String? mobile,
  });

  /// Login with email/mobile and password
  /// Returns authenticated user data on success
  ResultFuture<LocalUser> login({
    required String contact,
    required String password,
  });

  /// Request OTP for mobile number login
  /// Returns OTP expiry time and delivery channels on success
  ResultFuture<DataMap> signIn({
    required String mobile,
  });

  /// Request password reset OTP
  /// Returns OTP expiry time and delivery channels on success
  ResultFuture<DataMap> forgotPassword({
    String? email,
    String? mobile,
  });

  /// Reset password using OTP
  /// Returns authenticated user data on success
  ResultFuture<LocalUser> resetPassword({
    String? mobile,
    String? email,
    required String otp,
    required String newPassword,
  });

  /// Sign out the user and invalidate tokens
  ResultVoid signOut();

  /// Refresh authentication tokens
  /// Returns updated user data on success
  ResultFuture<LocalUser> refreshToken();
}
