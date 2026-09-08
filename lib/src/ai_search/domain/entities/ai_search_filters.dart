import 'package:equatable/equatable.dart';

/// Structured filters parsed from an AI Search natural-language query.
///
/// The backend interprets the raw query text (e.g. "req 706 ending numbers
/// under 5000") and returns a JSON object of filter keys such as
/// `endsWith`, `maxPrice`, `category`. The exact key set is model-driven, so
/// it is kept as a raw map here rather than a fixed set of fields — callers
/// map the keys they care about onto their own filter types.
class AiSearchFilters extends Equatable {
  const AiSearchFilters({this.raw = const {}});

  final Map<String, dynamic> raw;

  @override
  List<Object?> get props => [raw];
}
