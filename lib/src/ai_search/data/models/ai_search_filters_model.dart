import 'dart:convert';

import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/ai_search/domain/entities/ai_search_filters.dart';

class AiSearchFiltersModel extends AiSearchFilters {
  const AiSearchFiltersModel({required super.raw});

  /// The API wraps the filters as `{"result": "<json-encoded-string>"}` —
  /// `result` is a JSON string, not a nested object, so it needs a second
  /// decode pass.
  factory AiSearchFiltersModel.fromMap(DataMap map) {
    final resultString = map['result'] as String?;
    if (resultString == null || resultString.isEmpty) {
      return const AiSearchFiltersModel(raw: {});
    }

    final decoded = jsonDecode(resultString);
    return AiSearchFiltersModel(
      raw: decoded is DataMap ? decoded : const {},
    );
  }
}
