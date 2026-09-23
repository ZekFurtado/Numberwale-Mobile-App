import 'package:flutter/widgets.dart';

class _Run {
  _Run(this.start, this.length);
  final int start;
  final int length;
}

/// Splits [number] into digit spans, highlighting the "fancy" portion of the
/// number using [highlightStyle] and leaving the rest in [plainStyle]. A
/// single space separates adjacent runs so the number reads in groups.
///
/// Three patterns are detected, matching the categories numbers are usually
/// sold under:
/// - A run of the same digit repeated 3+ times (e.g. `111`, `777`) - mirror /
///   repeated-digit numbers.
/// - A run of 3+ digits that are strictly sequential, ascending or
///   descending, by 1 (e.g. `12345`, `54321`) - counting numbers.
/// - Two or more back-to-back doubled digits (e.g. `11 99 55`) - doubling
///   numbers. Each doubled pair is kept as its own group so it reads with a
///   space between pairs; a single isolated pair (e.g. the `88` in `889`)
///   does not qualify on its own.
List<InlineSpan> buildFancyNumberSpans(
  String number, {
  required TextStyle plainStyle,
  required TextStyle highlightStyle,
}) {
  final digits = number.split('');
  final n = digits.length;
  final groupId = List<int>.filled(n, -1);
  var nextGroup = 0;

  // Run-length encode the digit string.
  final runs = <_Run>[];
  var i = 0;
  while (i < n) {
    var j = i;
    while (j < n && digits[j] == digits[i]) {
      j++;
    }
    runs.add(_Run(i, j - i));
    i = j;
  }

  // Repeated-digit runs of length >= 3.
  for (final r in runs) {
    if (r.length >= 3) {
      final g = nextGroup++;
      for (var k = r.start; k < r.start + r.length; k++) {
        groupId[k] = g;
      }
    }
  }

  // Sequential (ascending/descending by 1) runs of length >= 3.
  i = 0;
  while (i < n) {
    if (groupId[i] != -1) {
      i++;
      continue;
    }
    final startVal = int.tryParse(digits[i]);
    if (startVal == null) {
      i++;
      continue;
    }
    var j = i;
    int? step;
    while (j + 1 < n && groupId[j + 1] == -1) {
      final a = int.tryParse(digits[j]);
      final b = int.tryParse(digits[j + 1]);
      if (a == null || b == null) break;
      final diff = b - a;
      if (diff != 1 && diff != -1) break;
      step ??= diff;
      if (diff != step) break;
      j++;
    }
    final length = j - i + 1;
    if (length >= 3) {
      final g = nextGroup++;
      for (var k = i; k <= j; k++) {
        groupId[k] = g;
      }
      i = j + 1;
    } else {
      i++;
    }
  }

  // Chains of 2+ back-to-back doubled digits.
  var ri = 0;
  while (ri < runs.length) {
    final r = runs[ri];
    if (r.length != 2 || groupId[r.start] != -1) {
      ri++;
      continue;
    }
    var rj = ri;
    while (rj < runs.length &&
        runs[rj].length == 2 &&
        groupId[runs[rj].start] == -1) {
      rj++;
    }
    if (rj - ri >= 2) {
      for (var k = ri; k < rj; k++) {
        final pair = runs[k];
        final g = nextGroup++;
        for (var idx = pair.start; idx < pair.start + pair.length; idx++) {
          groupId[idx] = g;
        }
      }
    }
    ri = rj;
  }

  // Build segments: contiguous unclaimed digits merge into one plain
  // segment; each claimed group becomes its own highlighted segment.
  final segments = <(String, bool)>[];
  i = 0;
  while (i < n) {
    if (groupId[i] == -1) {
      var j = i;
      while (j < n && groupId[j] == -1) {
        j++;
      }
      segments.add((digits.sublist(i, j).join(), false));
      i = j;
    } else {
      final g = groupId[i];
      var j = i;
      while (j < n && groupId[j] == g) {
        j++;
      }
      segments.add((digits.sublist(i, j).join(), true));
      i = j;
    }
  }

  final spans = <InlineSpan>[];
  for (var idx = 0; idx < segments.length; idx++) {
    if (idx > 0) {
      spans.add(TextSpan(text: ' ', style: plainStyle));
    }
    final (text, highlighted) = segments[idx];
    spans.add(TextSpan(
      text: text,
      style: highlighted ? highlightStyle : plainStyle,
    ));
  }
  return spans;
}
