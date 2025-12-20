import 'package:intl/intl.dart';

class DateFormatter {
  static String format(String dateString) {
    if (dateString.isEmpty) return "";
    try {
      DateTime utc = DateTime.parse(dateString);

      // Explicitly convert to IST (UTC + 5:30) regardless of device timezone
      DateTime ist = utc.toUtc().add(const Duration(hours: 5, minutes: 30));

      // Format: Date Month Year
      return DateFormat('dd MMM yyyy').format(ist);
    } catch (e) {
      return dateString;
    }
  }
}
