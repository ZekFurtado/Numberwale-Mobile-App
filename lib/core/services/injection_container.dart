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
import '../../src/products/data/datasources/product_remote_data_source.dart';
import '../../src/products/data/repositories/product_repository_impl.dart';
import '../../src/products/domain/repositories/product_repository.dart';
import '../../src/products/domain/usecases/get_discounted_products.dart';
import '../../src/products/domain/usecases/get_product_by_number.dart';
import '../../src/products/domain/usecases/get_products.dart';
import '../../src/products/presentation/bloc/product_bloc.dart';
import '../../src/cart/data/datasources/cart_remote_data_source.dart';
import '../../src/cart/data/repositories/cart_repository_impl.dart';
import '../../src/cart/domain/repositories/cart_repository.dart';
import '../../src/cart/domain/usecases/add_to_cart.dart';
import '../../src/cart/domain/usecases/checkout.dart';
import '../../src/cart/domain/usecases/clear_cart.dart';
import '../../src/cart/domain/usecases/confirm_payment.dart';
import '../../src/cart/domain/usecases/get_cart.dart';
import '../../src/cart/domain/usecases/get_payment_gateways.dart';
import '../../src/cart/domain/usecases/remove_cart_item.dart';
import '../../src/cart/presentation/bloc/cart_bloc.dart';
import '../../src/orders/data/datasources/order_remote_data_source.dart';
import '../../src/orders/data/repositories/order_repository_impl.dart';
import '../../src/orders/domain/repositories/order_repository.dart';
import '../../src/orders/domain/usecases/get_orders.dart';
import '../../src/orders/presentation/bloc/order_bloc.dart';
import '../../src/profile/data/datasources/profile_remote_data_source.dart';
import '../../src/profile/data/repositories/profile_repository_impl.dart';
import '../../src/profile/domain/repositories/profile_repository.dart';
import '../../src/profile/domain/usecases/get_profile.dart';
import '../../src/profile/domain/usecases/update_password.dart';
import '../../src/profile/domain/usecases/update_profile.dart';
import '../../src/profile/presentation/bloc/profile_bloc.dart';
import '../../src/numerology/data/datasources/numerology_remote_data_source.dart';
import '../../src/numerology/data/repositories/numerology_repository_impl.dart';
import '../../src/numerology/domain/repositories/numerology_repository.dart';
import '../../src/numerology/domain/usecases/submit_numerology_consultation.dart';
import '../../src/numerology/presentation/bloc/numerology_bloc.dart';
import '../../src/custom_request/data/datasources/custom_request_remote_data_source.dart';
import '../../src/custom_request/data/repositories/custom_request_repository_impl.dart';
import '../../src/custom_request/domain/repositories/custom_request_repository.dart';
import '../../src/custom_request/domain/usecases/submit_custom_request.dart';
import '../../src/custom_request/domain/usecases/verify_custom_request_otp.dart';
import '../../src/custom_request/presentation/bloc/custom_request_bloc.dart';
import '../../src/contact/data/datasources/contact_remote_data_source.dart';
import '../../src/contact/data/repositories/contact_repository_impl.dart';
import '../../src/contact/domain/repositories/contact_repository.dart';
import '../../src/contact/domain/usecases/submit_contact.dart';
import '../../src/contact/domain/usecases/submit_career_application.dart';
import '../../src/contact/presentation/bloc/contact_bloc.dart';

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

    /// Products
    ..registerFactory(() => ProductBloc(
        getProducts: sl(),
        getDiscountedProducts: sl(),
        getProductByNumber: sl(),
    ))

    /// Cart
    ..registerFactory(() => CartBloc(
        getCart: sl(),
        addToCart: sl(),
        removeCartItem: sl(),
        clearCart: sl(),
        checkout: sl(),
        confirmPayment: sl(),
        getPaymentGateways: sl(),
    ))

    /// Orders
    ..registerFactory(() => OrderBloc(getOrders: sl()))

    /// Profile
    ..registerFactory(() => ProfileBloc(
        getProfile: sl(),
        updateProfile: sl(),
        updatePassword: sl(),
    ))

    /// Numerology
    ..registerFactory(() => NumerologyBloc(
        submitNumerologyConsultation: sl(),
    ))

    /// Custom Number Request
    ..registerFactory(() => CustomRequestBloc(
        submitCustomRequest: sl(),
        verifyCustomRequestOtp: sl(),
    ))

    /// Contact
    ..registerFactory(() => ContactBloc(
        submitContact: sl(),
        submitCareerApplication: sl(),
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

    /// Products
    ..registerLazySingleton(() => GetProducts(sl()))
    ..registerLazySingleton(() => GetDiscountedProducts(sl()))
    ..registerLazySingleton(() => GetProductByNumber(sl()))

    /// Cart
    ..registerLazySingleton(() => GetCart(sl()))
    ..registerLazySingleton(() => AddToCart(sl()))
    ..registerLazySingleton(() => RemoveCartItem(sl()))
    ..registerLazySingleton(() => ClearCart(sl()))
    ..registerLazySingleton(() => Checkout(sl()))
    ..registerLazySingleton(() => ConfirmPayment(sl()))
    ..registerLazySingleton(() => GetPaymentGateways(sl()))

    /// Orders
    ..registerLazySingleton(() => GetOrders(sl()))

    /// Profile
    ..registerLazySingleton(() => GetProfile(sl()))
    ..registerLazySingleton(() => UpdateProfile(sl()))
    ..registerLazySingleton(() => UpdatePassword(sl()))

    /// Numerology
    ..registerLazySingleton(() => SubmitNumerologyConsultation(sl()))

    /// Custom Number Request
    ..registerLazySingleton(() => SubmitCustomRequest(sl()))
    ..registerLazySingleton(() => VerifyCustomRequestOtp(sl()))

    /// Contact
    ..registerLazySingleton(() => SubmitContact(sl()))
    ..registerLazySingleton(() => SubmitCareerApplication(sl()))


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

    /// Products
    ..registerLazySingleton<ProductRepository>(
        () => ProductRepositoryImpl(sl()))

    /// Cart
    ..registerLazySingleton<CartRepository>(
        () => CartRepositoryImpl(sl()))

    /// Orders
    ..registerLazySingleton<OrderRepository>(
        () => OrderRepositoryImpl(sl()))

    /// Profile
    ..registerLazySingleton<ProfileRepository>(
        () => ProfileRepositoryImpl(sl()))

    /// Numerology
    ..registerLazySingleton<NumerologyRepository>(
        () => NumerologyRepositoryImpl(sl()))

    /// Custom Number Request
    ..registerLazySingleton<CustomRequestRepository>(
        () => CustomRequestRepositoryImpl(sl()))

    /// Contact
    ..registerLazySingleton<ContactRepository>(
        () => ContactRepositoryImpl(sl()))


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

    /// Products
    ..registerLazySingleton<ProductRemoteDataSource>(
        () => ProductRemoteDataSourceImpl(sl()))

    /// Cart
    ..registerLazySingleton<CartRemoteDataSource>(
        () => CartRemoteDataSourceImpl(sl()))

    /// Orders
    ..registerLazySingleton<OrderRemoteDataSource>(
        () => OrderRemoteDataSourceImpl(sl()))

    /// Profile
    ..registerLazySingleton<ProfileRemoteDataSource>(
        () => ProfileRemoteDataSourceImpl(sl()))

    /// Numerology
    ..registerLazySingleton<NumerologyRemoteDataSource>(
        () => NumerologyRemoteDataSourceImpl(sl()))

    /// Custom Number Request
    ..registerLazySingleton<CustomRequestRemoteDataSource>(
        () => CustomRequestRemoteDataSourceImpl(sl()))

    /// Contact
    ..registerLazySingleton<ContactRemoteDataSource>(
        () => ContactRemoteDataSourceImpl(sl()))

    /// Call Support


    /// SERVICES

    /// EXTERNAL DEPENDENCIES
    ..registerLazySingleton(http.Client.new)
    ..registerLazySingleton(() => sharedPreferences)

    /// Firebase
   ;
}
