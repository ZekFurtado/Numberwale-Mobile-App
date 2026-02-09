import 'package:flutter/material.dart';
import 'package:numberwale/src/app/presentation/pages/app_shell.dart';
import 'package:numberwale/src/splash/presentation/pages/splash_screen.dart';
import 'package:numberwale/src/onboarding/presentation/pages/onboarding_page.dart';
import 'package:numberwale/src/authentication/presentation/pages/login_page.dart';
import 'package:numberwale/src/authentication/presentation/pages/register_page.dart';
import 'package:numberwale/src/authentication/presentation/pages/otp_verification_page.dart';
import 'package:numberwale/src/authentication/presentation/pages/forgot_password_page.dart';
import 'package:numberwale/src/authentication/presentation/pages/reset_password_page.dart';
import 'package:numberwale/src/products/presentation/pages/product_detail_page.dart';
import 'package:numberwale/src/cart/presentation/pages/cart_page.dart';
import 'package:numberwale/src/checkout/presentation/pages/address_selection_page.dart';
import 'package:numberwale/src/checkout/presentation/pages/order_summary_page.dart';
import 'package:numberwale/src/checkout/presentation/pages/order_success_page.dart';
import 'package:numberwale/src/orders/presentation/pages/orders_page.dart';
import 'package:numberwale/src/orders/presentation/pages/order_detail_page.dart';
import 'package:numberwale/src/address/presentation/pages/address_list_page.dart';
import 'package:numberwale/src/address/presentation/pages/address_form_page.dart' as address_form;

class Routes {
  // Splash & Onboarding
  static const String splash = '/';
  static const String onboarding = '/onboarding';

  // Authentication
  static const String login = '/login';
  static const String register = '/register';
  static const String otpVerification = '/otp-verification';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';

  // Main App
  static const String appShell = '/app';
  static const String home = '/home';

  // Products
  static const String exploreNumbers = '/explore';
  static const String advancedSearch = '/search/advanced';
  static const String productDetail = '/product';

  // Cart & Checkout
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String addressSelection = '/checkout/address';
  static const String addressForm = '/checkout/address/form';
  static const String orderSummary = '/checkout/summary';
  static const String payment = '/checkout/payment';
  static const String orderSuccess = '/checkout/success';

  // Orders
  static const String orders = '/orders';
  static const String orderDetail = '/order';

  // Account
  static const String account = '/account';
  static const String editProfile = '/account/edit';
  static const String changePassword = '/account/change-password';
  static const String addresses = '/account/addresses';

  // Custom Requests
  static const String customRequest = '/custom-request';
  static const String numerologyConsultation = '/numerology';

  // Contact & Support
  static const String contactUs = '/contact';
  static const String careers = '/careers';

  // CMS Pages
  static const String faq = '/faq';
  static const String about = '/about';
  static const String privacyPolicy = '/privacy-policy';
  static const String termsAndConditions = '/terms';
  static const String refundPolicy = '/refund-policy';
  static const String blogs = '/blogs';
  static const String blogDetail = '/blog';

  /// Static route map
  static Map<String, WidgetBuilder> get routes => {
        // Splash Screen
        splash: (context) => const SplashScreen(),

        // Onboarding
        onboarding: (context) => const OnboardingPage(),

        // Authentication
        login: (context) => const LoginPage(),
        register: (context) => const RegisterPage(),
        otpVerification: (context) => const OTPVerificationPage(),
        forgotPassword: (context) => const ForgotPasswordPage(),
        resetPassword: (context) => const ResetPasswordPage(),

        // App Shell
        appShell: (context) => const AppShell(),

        // Cart
        cart: (context) => const CartPage(),

        // Checkout
        checkout: (context) => const AddressSelectionPage(),
        addressSelection: (context) => const AddressSelectionPage(),

        // Orders
        orders: (context) => const OrdersPage(),

        // Addresses
        addresses: (context) => const AddressListPage(),

        // More routes will be added as pages are created
      };

  /// Generate routes for dynamic navigation (with parameters)
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    // Extract route name and arguments
    final routeName = settings.name;
    final args = settings.arguments;

    switch (routeName) {
      // Product Detail (with phoneNumber parameter)
      case productDetail:
        if (args is String) {
          return MaterialPageRoute(
            builder: (_) => ProductDetailPage(phoneNumber: args),
            settings: settings,
          );
        }
        break;

      // Order Detail (with orderId parameter)
      case orderDetail:
        if (args is String) {
          return MaterialPageRoute(
            builder: (_) => OrderDetailPage(orderId: args),
            settings: settings,
          );
        }
        break;

      // Order Summary (with delivery address parameter)
      case orderSummary:
        if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => OrderSummaryPage(deliveryAddress: args),
            settings: settings,
          );
        }
        break;

      // Order Success (with order details)
      case orderSuccess:
        if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => OrderSuccessPage(
              orderId: args['orderId'],
              amount: args['amount'],
            ),
            settings: settings,
          );
        }
        break;

      // Blog Detail (with blogId parameter)
      case blogDetail:
        if (args is String) {
          // Return BlogDetailPage when created
          return MaterialPageRoute(
            builder: (_) => Scaffold(
              appBar: AppBar(title: const Text('Blog')),
              body: Center(child: Text('Blog ID: $args')),
            ),
            settings: settings,
          );
        }
        break;

      // Address Form (with address parameter for editing)
      case addressForm:
        // Can accept a Map with addressId and address entity for editing
        if (args == null) {
          return MaterialPageRoute(
            builder: (_) => const address_form.AddressFormPage(),
            settings: settings,
          );
        } else if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => address_form.AddressFormPage(
              addressId: args['addressId'],
              address: args['address'],
            ),
            settings: settings,
          );
        }
        break;

      // OTP Verification (with phone/email parameter)
      case otpVerification:
        if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => Scaffold(
              appBar: AppBar(title: const Text('Verify OTP')),
              body: Center(
                child: Text('Verify OTP for: ${args['contact']}'),
              ),
            ),
            settings: settings,
          );
        }
        break;

      default:
        break;
    }

    // Return null to let the app handle it with onUnknownRoute or show error
    return null;
  }

  /// Unknown route handler
  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Page Not Found',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Route: ${settings.name}',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // This won't work without context, but serves as placeholder
                },
                child: const Text('Go to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
