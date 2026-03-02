import 'dart:ui' as ui;
import 'package:intl/intl.dart';

String toArabicNumerals(String input) {
  const western = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  const eastern = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  String result = input;
  for (int i = 0; i < western.length; i++) {
    result = result.replaceAll(western[i], eastern[i]);
  }
  return result;
}

String localizeNumber(int number, String locale) {
  if (locale == 'ar') return toArabicNumerals(number.toString());
  return number.toString();
}

String localizeTime(String time24, String locale) {
  final parts = time24.split(':');
  final hour = int.parse(parts[0]);
  final minute = parts[1];

  if (locale == 'ar') {
    final h = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final period = hour >= 12 ? 'م' : 'ص';
    return '${toArabicNumerals('$h:$minute')} $period';
  }

  final h = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
  final period = hour >= 12 ? 'PM' : 'AM';
  return '$h:$minute $period';
}

String localizeDate(DateTime date, String locale) {
  final formatter = DateFormat.yMMMd(locale == 'ar' ? 'ar' : 'en');
  return formatter.format(date);
}

bool isRtl(String locale) => locale == 'ar';

ui.TextDirection textDirection(String locale) =>
    locale == 'ar' ? ui.TextDirection.rtl : ui.TextDirection.ltr;
