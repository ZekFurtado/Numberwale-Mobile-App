part of 'custom_request_bloc.dart';

abstract class CustomRequestState extends Equatable {
  const CustomRequestState();

  @override
  List<Object?> get props => [];
}

class CustomRequestInitial extends CustomRequestState {
  const CustomRequestInitial();
}

class CustomRequestLoading extends CustomRequestState {
  const CustomRequestLoading();
}

class CustomRequestSubmitted extends CustomRequestState {
  final String requestId;
  final bool otpSent;

  const CustomRequestSubmitted({
    required this.requestId,
    required this.otpSent,
  });

  @override
  List<Object?> get props => [requestId, otpSent];
}

class CustomRequestVerifying extends CustomRequestState {
  const CustomRequestVerifying();
}

class CustomRequestVerified extends CustomRequestState {
  const CustomRequestVerified();
}

class CustomRequestError extends CustomRequestState {
  final String message;

  const CustomRequestError({required this.message});

  @override
  List<Object?> get props => [message];
}
