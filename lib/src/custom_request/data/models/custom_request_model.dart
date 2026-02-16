import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/custom_request/domain/entities/custom_request.dart';

class CustomRequestModel extends CustomRequest {
  const CustomRequestModel({
    required super.requestId,
    required super.otpSent,
  });

  factory CustomRequestModel.fromMap(DataMap map) {
    final data = map['data'] as DataMap;
    return CustomRequestModel(
      requestId: data['requestId'] as String? ?? '',
      otpSent: data['otpSent'] as bool? ?? false,
    );
  }
}
