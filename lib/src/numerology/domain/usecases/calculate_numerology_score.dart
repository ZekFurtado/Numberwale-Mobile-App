import 'package:numberwale/src/numerology/domain/entities/numerology_score.dart';

/// Computes a mobile number's numerology score from its 10 digits.
///
/// This mirrors the "Number Calculator" tool on numberwale.com/numerology.
/// It's a pure, synchronous calculation with no repository dependency, so
/// it doesn't follow the `UseCaseWithParams`/`Either<Failure,T>` shape used
/// by the other, network-backed use cases in this app.
class CalculateNumerologyScore {
  const CalculateNumerologyScore();

  NumerologyScore call(String tenDigitNumber) {
    assert(RegExp(r'^\d{10}$').hasMatch(tenDigitNumber));

    final digits = tenDigitNumber.split('').map(int.parse);
    final literSum = digits.reduce((a, b) => a + b);
    final midSum = _digitSum(literSum);

    var finalScore = midSum;
    while (finalScore >= 10) {
      finalScore = _digitSum(finalScore);
    }

    return NumerologyScore(
      literSum: literSum,
      midSum: midSum,
      finalScore: finalScore,
    );
  }

  int _digitSum(int n) =>
      n.toString().split('').map(int.parse).reduce((a, b) => a + b);
}
