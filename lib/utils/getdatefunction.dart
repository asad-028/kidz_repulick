import 'package:intl/intl.dart';

import '../main.dart';
// String? givendate_;
String getCurrentDate() {
  isloadingDate = true;
  final now = DateTime.now();
  final day =
  now.day.toString().padLeft(2, '0'); // Add leading zero if needed
  final month =
  now.month.toString().padLeft(2, '0'); // Add leading zero if needed
  final year = now.year.toString();

  isloadingDate = false;
  return '$day-$month-$year';

}
String getCurrentDateforattendance() {
  isloadingDate = true;
  final now = DateTime.now();
  final day =
      ' ${DateFormat.EEEE().format(DateTime.now())},  ${DateFormat.d().format(DateTime.now())} ${DateFormat.MMMM().format(DateTime.now())} ${DateFormat.y().format(DateTime.now())} ';
  now.day.toString().padLeft(2, '0'); // Add leading zero if needed
  isloadingDate = false;

  return '$day';
   // '$day-$month-$year';


}
String getDateforReport() {
  isloadingDate = true;
  final now = DateTime.now();
  final day = ' ${DateFormat.EEEE().format(DateTime.now())},  ${DateFormat.d().format(DateTime.now())} ${DateFormat.MMMM().format(DateTime.now())} ${DateFormat.y().format(DateTime.now())} ';
  now.day.toString().padLeft(2, '0'); // Add leading zero if needed
  isloadingDate = false;

  return '$day';
   // '$day-$month-$year';


}
