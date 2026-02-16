part of 'numerology_bloc.dart';

abstract class NumerologyState extends Equatable {
  const NumerologyState();

  @override
  List<Object?> get props => [];
}

class NumerologyInitial extends NumerologyState {
  const NumerologyInitial();
}

class NumerologyLoading extends NumerologyState {
  const NumerologyLoading();
}

class NumerologySubmitted extends NumerologyState {
  final String message;

  const NumerologySubmitted({required this.message});

  @override
  List<Object?> get props => [message];
}

class NumerologyError extends NumerologyState {
  final String message;

  const NumerologyError({required this.message});

  @override
  List<Object?> get props => [message];
}
