import 'package:equatable/equatable.dart';

/// Value object for the web's "Advanced Search" filters.
///
/// The API docs describe `search` as a single JSON-encoded query string
/// (e.g. `?search={"advanced":{"startsWith":"98"}}`), but the live backend
/// does not actually parse that — it was verified empirically (via direct
/// requests against production) to expect bracket-notation query params
/// instead, e.g. `search[advanced][startsWith]=98`. `toQueryParams()`
/// reflects the verified format, not the documented one. `mostContain`
/// (Digit Frequency) was verified to have no effect server-side under any
/// param naming tried — it's still sent in case the backend adds support
/// later, but currently does not filter results.
class AdvancedSearchFilters extends Equatable {
  final String? startsWith;
  final String? endsWith;
  final String? anywhere;
  final String? mustContain;
  final String? notContain;
  final int? literSum;
  final int? trapSum;
  final int? scoreSum;
  final String? exactDigitPlacement;
  final String? mostContainDigit;
  final int? mostContainCount;

  const AdvancedSearchFilters({
    this.startsWith,
    this.endsWith,
    this.anywhere,
    this.mustContain,
    this.notContain,
    this.literSum,
    this.trapSum,
    this.scoreSum,
    this.exactDigitPlacement,
    this.mostContainDigit,
    this.mostContainCount,
  });

  AdvancedSearchFilters copyWith({
    String? startsWith,
    String? endsWith,
    String? anywhere,
    String? mustContain,
    String? notContain,
    int? literSum,
    int? trapSum,
    int? scoreSum,
    String? exactDigitPlacement,
    String? mostContainDigit,
    int? mostContainCount,
  }) {
    return AdvancedSearchFilters(
      startsWith: startsWith ?? this.startsWith,
      endsWith: endsWith ?? this.endsWith,
      anywhere: anywhere ?? this.anywhere,
      mustContain: mustContain ?? this.mustContain,
      notContain: notContain ?? this.notContain,
      literSum: literSum ?? this.literSum,
      trapSum: trapSum ?? this.trapSum,
      scoreSum: scoreSum ?? this.scoreSum,
      exactDigitPlacement: exactDigitPlacement ?? this.exactDigitPlacement,
      mostContainDigit: mostContainDigit ?? this.mostContainDigit,
      mostContainCount: mostContainCount ?? this.mostContainCount,
    );
  }

  /// Builds `search[advanced][...]` bracket-notation query params. Omits
  /// null/empty fields. `mustContain`/`notContain` are truncated to 5
  /// comma-separated entries. `mostContain` is only included when both
  /// digit and count are set.
  Map<String, String> toQueryParams() {
    final params = <String, String>{};
    const prefix = 'search[advanced]';

    if (startsWith != null && startsWith!.isNotEmpty) {
      params['$prefix[startsWith]'] = startsWith!;
    }
    if (endsWith != null && endsWith!.isNotEmpty) {
      params['$prefix[endsWith]'] = endsWith!;
    }
    if (anywhere != null && anywhere!.isNotEmpty) {
      params['$prefix[anywhere]'] = anywhere!;
    }

    final mustContainDigits = _splitDigits(mustContain);
    if (mustContainDigits.isNotEmpty) {
      params['$prefix[mustContain]'] = mustContainDigits.join(',');
    }

    final notContainDigits = _splitDigits(notContain);
    if (notContainDigits.isNotEmpty) {
      params['$prefix[notContain]'] = notContainDigits.join(',');
    }

    if (literSum != null) params['$prefix[literSum]'] = literSum.toString();
    if (trapSum != null) params['$prefix[trapSum]'] = trapSum.toString();
    if (scoreSum != null) params['$prefix[scoreSum]'] = scoreSum.toString();

    if (exactDigitPlacement != null && exactDigitPlacement!.length == 10) {
      params['$prefix[exactDigitPlacement]'] = exactDigitPlacement!;
    }

    if (mostContainDigit != null &&
        mostContainDigit!.isNotEmpty &&
        mostContainCount != null) {
      params['$prefix[mostContain][digit]'] = mostContainDigit!;
      params['$prefix[mostContain][count]'] = mostContainCount.toString();
    }

    return params;
  }

  static List<String> _splitDigits(String? raw) {
    if (raw == null || raw.isEmpty) return const [];
    return raw
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .take(5)
        .toList();
  }

  bool get isEmpty => toQueryParams().isEmpty;

  @override
  List<Object?> get props => [
        startsWith,
        endsWith,
        anywhere,
        mustContain,
        notContain,
        literSum,
        trapSum,
        scoreSum,
        exactDigitPlacement,
        mostContainDigit,
        mostContainCount,
      ];
}
