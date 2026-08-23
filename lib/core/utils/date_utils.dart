import 'package:intl/intl.dart';

class DateUtils {
  /// Timestamp to *store*. Always ISO-8601, never a localized string: the old
  /// format was produced by `DateFormat.yMMMMEEEEd()`, so changing the device
  /// locale made every previously saved note, highlight, and bookmark
  /// unparseable and collapsed their sort order.
  static String timestampNow() => DateTime.now().toIso8601String();

  /// Timestamp to *show*. Accepts both the current ISO format and the legacy
  /// localized one, so records written by older builds keep rendering.
  static String formatForDisplay(String? stored) {
    if (stored == null || stored.isEmpty) return '';
    final parsed = parseDateTime(stored);
    if (parsed == null) return stored; // Unrecognized: show it verbatim.
    return DateFormat.yMMMMd().add_jm().format(parsed);
  }

  static String formatDateTime(DateTime dateTime) {
    return DateFormat.yMMMMEEEEd().add_jms().format(dateTime);
  }

  static String formatDateOnly(DateTime dateTime) {
    return DateFormat.yMMMMEEEEd().format(dateTime);
  }

  /// Collision-free id for a newly created record. The previous scheme had
  /// only tenth-of-a-second resolution, so two notes saved in the same 100ms
  /// shared an id and one silently overwrote the other.
  static String generateUniqueId() {
    final micros = DateTime.now().microsecondsSinceEpoch;
    final salt = _counter = (_counter + 1) & 0xFFFF;
    return '$micros-${salt.toRadixString(16).padLeft(4, '0')}';
  }

  static int _counter = 0;

  static DateTime? parseDateTime(String? dateString) {
    if (dateString == null) return null;
    // ISO first: it is what we write now, and it is unambiguous.
    final iso = DateTime.tryParse(dateString);
    if (iso != null) return iso;
    try {
      return DateFormat.yMMMMEEEEd().add_jms().parse(dateString);
    } catch (_) {
      return null;
    }
  }
}
