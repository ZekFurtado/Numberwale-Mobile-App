import 'package:equatable/equatable.dart';

class CustomRequest extends Equatable {
  final String requestId;
  final bool otpSent;

  const CustomRequest({
    required this.requestId,
    required this.otpSent,
  });

  @override
  List<Object?> get props => [requestId, otpSent];
}
