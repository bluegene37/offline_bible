import 'package:intl/intl.dart';

class DateUtils {
  static String formatDateTime(DateTime dateTime) {
    return DateFormat.yMMMMEEEEd().add_jms().format(dateTime);
  }

  static String formatDateOnly(DateTime dateTime) {
    return DateFormat.yMMMMEEEEd().format(dateTime);
  }

  static int generateUniqueId() {
    final now = DateTime.now();
    return int.parse('${DateFormat('yyMMdd').format(now)}${DateFormat('HHmmssS').format(now)}');
  }
}