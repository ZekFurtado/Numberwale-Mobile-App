import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../src/app/presentation/cubit/app_navigation_cubit.dart';
import '../../src/authentication/data/datasources/auth_local_data_source.dart';
import '../../src/authentication/data/datasources/auth_remote_data_source.dart';
import '../../src/authentication/data/repositories/auth_repository_impl.dart';
import '../../src/authentication/domain/repositories/auth_repository.dart';
import '../../src/authentication/domain/usecases/sign_out.dart';
import '../../src/authentication/domain/usecases/register.dart';
import '../../src/authentication/domain/usecases/login.dart';
import '../../src/authentication/domain/usecases/sign_in.dart';
import '../../src/authentication/domain/usecases/verify_otp.dart';
import '../../src/authentication/domain/usecases/forgot_password.dart';
import '../../src/authentication/domain/usecases/reset_password.dart';
import '../../src/authentication/domain/usecases/resend_otp.dart';
import '../../src/authentication/domain/usecases/refresh_token.dart';
import '../../src/authentication/presentation/bloc/authentication_bloc.dart';
import '../../src/address/data/datasources/address_local_data_source.dart';
import '../../src/address/data/datasources/address_remote_data_source.dart';
import '../../src/address/data/repositories/address_repository_impl.dart';
import '../../src/address/domain/repositories/address_repository.dart';
import '../../src/address/domain/usecases/add_address.dart';
import '../../src/address/domain/usecases/delete_address.dart';
import '../../src/address/domain/usecases/get_addresses.dart';
import '../../src/address/domain/usecases/get_location_from_pincode.dart';
import '../../src/address/domain/usecases/set_primary_address.dart';
import '../../src/address/domain/usecases/update_address.dart';
import '../../src/address/presentation/bloc/address_bloc.dart';
import '../../src/home/data/datasources/home_local_data_source.dart';
import '../../src/home/data/datasources/home_remote_data_source.dart';
import '../../src/home/data/repositories/home_repository_impl.dart';
import '../../src/home/domain/repositories/home_repository.dart';
import '../../src/home/domain/usecases/get_banners.dart';
import '../../src/home/domain/usecases/get_categories.dart';
import '../../src/home/domain/usecases/get_featured_numbers.dart';
import '../../src/home/domain/usecases/get_latest_numbers.dart';
import '../../src/home/presentation/bloc/home_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  sl

    /// APP LOGIC

    /// App Navigation
    ..registerFactory(() => AppNavigationCubit())

    /// Authentication
    ..registerFactory(() => AuthenticationBloc(
        signOutUser: sl(),
        register: sl(),
        login: sl(),
        signIn: sl(),
        verifyOtp: sl(),
        forgotPassword: sl(),
        resetPassword: sl(),
        resendOtp: sl(),
    )
    )
    // () => AuthenticationCubit(createUser: sl(), emailSignIn: sl()))

    /// Address
    ..registerFactory(() => AddressBloc(
        getAddresses: sl(),
        addAddress: sl(),
        updateAddress: sl(),
        deleteAddress: sl(),
        setPrimaryAddress: sl(),
        getLocationFromPinCode: sl(),
    ))

    /// Home
    ..registerFactory(() => HomeBloc(
        getBanners: sl(),
        getCategories: sl(),
        getFeaturedNumbers: sl(),
        getLatestNumbers: sl(),
    ))

    /// USE CASES

    /// Authentication
    ..registerLazySingleton(() => SignOutUseCase(sl()))
    ..registerLazySingleton(() => Register(sl()))
    ..registerLazySingleton(() => Login(sl()))
    ..registerLazySingleton(() => SignIn(sl()))
    ..registerLazySingleton(() => VerifyOtp(sl()))
    ..registerLazySingleton(() => ForgotPassword(sl()))
    ..registerLazySingleton(() => ResetPassword(sl()))
    ..registerLazySingleton(() => ResendOtp(sl()))
    ..registerLazySingleton(() => RefreshToken(sl()))

    /// Address
    ..registerLazySingleton(() => GetAddresses(sl()))
    ..registerLazySingleton(() => AddAddress(sl()))
    ..registerLazySingleton(() => UpdateAddress(sl()))
    ..registerLazySingleton(() => DeleteAddress(sl()))
    ..registerLazySingleton(() => SetPrimaryAddress(sl()))
    ..registerLazySingleton(() => GetLocationFromPinCode(sl()))

    /// Home
    ..registerLazySingleton(() => GetBanners(sl()))
    ..registerLazySingleton(() => GetCategories(sl()))
    ..registerLazySingleton(() => GetFeaturedNumbers(sl()))
    ..registerLazySingleton(() => GetLatestNumbers(sl()))


    /// REPOSITORIES

    /// Authentication
    ..registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(sl(), sl()))

    /// Address
    ..registerLazySingleton<AddressRepository>(
        () => AddressRepositoryImpl(sl(), sl()))

    /// Home
    ..registerLazySingleton<HomeRepository>(
        () => HomeRepositoryImpl(sl(), sl()))


    /// DATA SOURCES

    /// Authentication
    ..registerLazySingleton<AuthRemoteDataSource>(
        () => AuthRemoteDataSourceImpl(sl()))
    ..registerLazySingleton<AuthLocalDataSource>(
        () => AuthLocalDataSourceImpl(sl()))

    /// Address
    ..registerLazySingleton<AddressRemoteDataSource>(
        () => AddressRemoteDataSourceImpl(sl()))
    ..registerLazySingleton<AddressLocalDataSource>(
        () => AddressLocalDataSourceImpl(sl()))

    /// Home
    ..registerLazySingleton<HomeRemoteDataSource>(
        () => HomeRemoteDataSourceImpl(sl()))
    ..registerLazySingleton<HomeLocalDataSource>(
        () => HomeLocalDataSourceImpl(sl()))

    /// Call Support


    /// SERVICES

    /// EXTERNAL DEPENDENCIES
    ..registerLazySingleton(http.Client.new)
    ..registerLazySingleton(() => sharedPreferences)

    /// Firebase
   ;
}
