import 'package:intl/intl.dart';

class DateFormattingService {

  String formatDate(String? dateString) {
    if (dateString == null) return 'Nicht verfügbar';

    try {
      final dateTime = DateTime.parse(dateString);

      return DateFormat('dd.MM.yyyy').format(dateTime);
    } catch (e) {
      return 'Ungültiges Datum';
    }
  }
}