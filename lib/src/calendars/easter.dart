import '../civil_date.dart';

/// Western (Gregorian) Easter Sunday — Anonymous Gregorian algorithm
/// (Meeus/Jones/Butcher).
CivilDate gregorianEaster(int year) {
  final a = year % 19;
  final b = year ~/ 100;
  final c = year % 100;
  final d = b ~/ 4;
  final e = b % 4;
  final f = (b + 8) ~/ 25;
  final g = (b - f + 1) ~/ 3;
  final h = (19 * a + b - d - g + 15) % 30;
  final i = c ~/ 4;
  final k = c % 4;
  final l = (32 + 2 * e + 2 * i - h - k) % 7;
  final m = (a + 11 * h + 22 * l) ~/ 451;
  final n = h + l - 7 * m + 114;
  return CivilDate(year, n ~/ 31, n % 31 + 1);
}

/// Orthodox Easter Sunday, returned as a Gregorian date (Meeus' Julian
/// algorithm, then Julian → Gregorian conversion).
CivilDate orthodoxEaster(int year) {
  final a = year % 4;
  final b = year % 7;
  final c = year % 19;
  final d = (19 * c + 15) % 30;
  final e = (2 * a + 4 * b - d + 34) % 7;
  final n = d + e + 114;
  return julianCalendarToCivil(year, n ~/ 31, n % 31 + 1);
}
