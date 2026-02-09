import 'package:numberwale/core/utils/typedef.dart';

/// Generic class for use cases to access their parameters by extending this
/// class instead of adding the required parameters as dependencies
abstract class UseCaseWithParams<T, Params> {
  const UseCaseWithParams();

  ResultFuture<T> call(Params params);
}

/// Generic class for use cases that do not require parameters
abstract class UseCaseWithoutParams<T> {
  const UseCaseWithoutParams();

  ResultFuture<T> call();
}
