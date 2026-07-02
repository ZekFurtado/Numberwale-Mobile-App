import 'package:equatable/equatable.dart';

/// Result of running the numerology "Number Calculator" over a 10-digit
/// mobile number.
class NumerologyScore extends Equatable {
  const NumerologyScore({
    required this.literSum,
    required this.midSum,
    required this.finalScore,
  });

  /// Sum of all 10 digits.
  final int literSum;

  /// Digit sum of [literSum].
  final int midSum;

  /// Single-digit numerological root of [midSum].
  final int finalScore;

  @override
  List<Object?> get props => [literSum, midSum, finalScore];
}
