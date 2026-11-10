import 'package:intl/intl.dart';

final DateFormat _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');

/// Formats an epoch millisecond timestamp into a human-readable date and time (e.g. `10/11/2026 16:30`).
String formatDateTime(int epochMillis) {
  final date = DateTime.fromMillisecondsSinceEpoch(epochMillis);
  return _dateTimeFormat.format(date);
}

