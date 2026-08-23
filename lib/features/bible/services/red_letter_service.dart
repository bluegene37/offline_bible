import 'dart:convert';

import 'package:flutter/services.dart';

/// Words of Christ, as character ranges into each verse's text.
///
/// Ranges are derived from the public-domain OSIS King James Version published
/// by eBible.org, which marks them with `<q who="Jesus">`. They were resolved
/// against this app's bundled text by substring match rather than raw offset,
/// so a whitespace difference between the two editions cannot shift a span
/// onto the wrong words.
class RedLetterService {
  static Map<String, List<List<int>>> _spans = const {};
  static bool _loaded = false;

  static bool get isLoaded => _loaded;

  /// Small enough (~48KB) to load at startup rather than lazily.
  static Future<void> load() async {
    if (_loaded) return;
    final raw = await rootBundle.loadString('assets/red_letter.json');
    final decoded = json.decode(raw) as Map<String, dynamic>;
    _spans = decoded.map(
      (key, value) => MapEntry(
        key,
        (value as List<dynamic>)
            .map((pair) =>
                (pair as List<dynamic>).map((n) => (n as num).toInt()).toList())
            .toList(),
      ),
    );
    _loaded = true;
  }

  /// Ranges for [verseKey], clamped to [textLength] and sorted. Empty when the
  /// verse contains no words of Christ, which is the common case.
  ///
  /// Only the bundled KJV carries these ranges; other translations word verses
  /// differently, so callers must not apply them to a different version.
  static List<List<int>> spansFor(String verseKey, int textLength) {
    final raw = _spans[verseKey];
    if (raw == null) return const [];
    final ranges = <List<int>>[];
    for (final pair in raw) {
      if (pair.length != 2) continue;
      final start = pair[0].clamp(0, textLength);
      final end = pair[1].clamp(0, textLength);
      if (end > start) ranges.add([start, end]);
    }
    ranges.sort((a, b) => a[0].compareTo(b[0]));
    return ranges;
  }
}
