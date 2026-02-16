import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:numberwale/src/custom_request/domain/usecases/submit_custom_request.dart';
import 'package:numberwale/src/custom_request/domain/usecases/verify_custom_request_otp.dart';

part 'custom_request_event.dart';
part 'custom_request_state.dart';

class CustomRequestBloc
    extends Bloc<CustomRequestEvent, CustomRequestState> {
  final SubmitCustomRequest _submitCustomRequest;
  final VerifyCustomRequestOtp _verifyCustomRequestOtp;

  CustomRequestBloc({
    required SubmitCustomRequest submitCustomRequest,
    required VerifyCustomRequestOtp verifyCustomRequestOtp,
  })  : _submitCustomRequest = submitCustomRequest,
        _verifyCustomRequestOtp = verifyCustomRequestOtp,
        super(const CustomRequestInitial()) {
    on<SubmitCustomRequestEvent>(_onSubmitCustomRequest);
    on<VerifyCustomRequestOtpEvent>(_onVerifyCustomRequestOtp);
  }

  Future<void> _onSubmitCustomRequest(
    SubmitCustomRequestEvent event,
    Emitter<CustomRequestState> emit,
  ) async {
    log('CustomRequestBloc: handling SubmitCustomRequestEvent');
    emit(const CustomRequestLoading());

    final result = await _submitCustomRequest(SubmitCustomRequestParams(
      requested: event.requested,
      category: event.category,
      userId: event.userId,
      name: event.name,
      email: event.email,
      mobileNo: event.mobileNo,
      city: event.city,
      phoneword: event.phoneword,
    ));

    result.fold(
      (failure) => emit(CustomRequestError(message: failure.message)),
      (customRequest) => emit(CustomRequestSubmitted(
        requestId: customRequest.requestId,
        otpSent: customRequest.otpSent,
      )),
    );
  }

  Future<void> _onVerifyCustomRequestOtp(
    VerifyCustomRequestOtpEvent event,
    Emitter<CustomRequestState> emit,
  ) async {
    log('CustomRequestBloc: handling VerifyCustomRequestOtpEvent');
    emit(const CustomRequestVerifying());

    final result = await _verifyCustomRequestOtp(VerifyCustomRequestOtpParams(
      customizeNumberId: event.customizeNumberId,
      otp: event.otp,
    ));

    result.fold(
      (failure) => emit(CustomRequestError(message: failure.message)),
      (_) => emit(const CustomRequestVerified()),
    );
  }
}
