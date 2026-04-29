import 'package:intl/intl.dart';


class DateTimeUtils {
  static String formatArabicDateTime(DateTime dt) {
    return DateFormat('yyyy/MM/dd – HH:mm').format(dt);
  }
}