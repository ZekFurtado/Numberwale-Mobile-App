import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/custom_request/domain/entities/custom_request.dart';

abstract class CustomRequestRepository {
  ResultFuture<CustomRequest> submitRequest({
    required String requested,
    required String category,
    String? userId,
    String? name,
    String? email,
    String? mobileNo,
    String? city,
    String? phoneword,
  });

  ResultVoid verifyOtp({
    required String customizeNumberId,
    required String otp,
  });
}
