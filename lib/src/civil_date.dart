/// A calendar date with no time and no time zone.
///
/// Holidays are civil dates ("20 March 2026 in Turkey"), not instants, so the
/// engine never uses [DateTime] internally. That avoids DST and UTC-offset bugs
/// and keeps all arithmetic in plain integers, which behaves the same on the
/// VM, on the web (JS numbers) and on Wasm.
final class CivilDate implements Comparable<CivilDate> {
  /// Gregorian year.
  final int year;

  /// Month, 1 (January) to 12 (December).
  final int month;

  /// Day of the month, starting at 1.
  final int day;

  /// Creates a date. The values are not validated; see [isValid].
  const CivilDate(this.year, this.month, this.day);

  /// The date [epochDay] days after 1970-01-01 (negative = before).
  factory CivilDate.fromEpochDay(int epochDay) {
    // Howard Hinnant's civil_from_days algorithm.
    final z = epochDay + 719468;
    final era = (z >= 0 ? z : z - 146096) ~/ 146097;
    final doe = z - era * 146097;
    final yoe = (doe - doe ~/ 1460 + doe ~/ 36524 - doe ~/ 146096) ~/ 365;
    final doy = doe - (365 * yoe + yoe ~/ 4 - yoe ~/ 100);
    final mp = (5 * doy + 2) ~/ 153;
    final d = doy - (153 * mp + 2) ~/ 5 + 1;
    final m = mp < 10 ? mp + 3 : mp - 9;
    final y = yoe + era * 400 + (m <= 2 ? 1 : 0);
    return CivilDate(y, m, d);
  }

  /// Uses only the year, month and day fields of [dateTime].
  factory CivilDate.fromDateTime(DateTime dateTime) =>
      CivilDate(dateTime.year, dateTime.month, dateTime.day);

  /// Parses `YYYY-MM-DD`. Throws a [FormatException] for anything else.
  factory CivilDate.parse(String iso) {
    final parts = iso.split('-');
    if (parts.length != 3) {
      throw FormatException('Expected YYYY-MM-DD', iso);
    }
    final date = CivilDate(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
    if (!date.isValid) throw FormatException('Not a calendar date', iso);
    return date;
  }

  /// Whether [year] is a Gregorian leap year.
  static bool isLeapYear(int year) =>
      year % 4 == 0 && (year % 100 != 0 || year % 400 == 0);

  /// Number of days in [month] of [year].
  static int daysInMonth(int year, int month) => switch (month) {
        2 => isLeapYear(year) ? 29 : 28,
        4 || 6 || 9 || 11 => 30,
        _ => 31,
      };

  /// Whether this is a real calendar date (30 February is not).
  bool get isValid =>
      month >= 1 && month <= 12 && day >= 1 && day <= daysInMonth(year, month);

  /// Days since 1970-01-01 (Howard Hinnant's days_from_civil).
  int get epochDay {
    final y = month <= 2 ? year - 1 : year;
    final era = (y >= 0 ? y : y - 399) ~/ 400;
    final yoe = y - era * 400;
    final mp = (month + 9) % 12; // March = 0
    final doy = (153 * mp + 2) ~/ 5 + day - 1;
    final doe = yoe * 365 + yoe ~/ 4 - yoe ~/ 100 + doy;
    return era * 146097 + doe - 719468;
  }

  /// ISO weekday: Monday = 1 … Sunday = 7 (same as [DateTime.weekday]).
  int get weekday => (epochDay + 3) % 7 + 1; // 1970-01-01 was a Thursday.

  /// This date moved by [days] (negative = earlier).
  CivilDate addDays(int days) => CivilDate.fromEpochDay(epochDay + days);

  /// Days from this date to [other] (negative when [other] is earlier).
  int daysUntil(CivilDate other) => other.epochDay - epochDay;

  /// Whether this date is earlier than [other].
  bool isBefore(CivilDate other) => epochDay < other.epochDay;

  /// Whether this date is later than [other].
  bool isAfter(CivilDate other) => epochDay > other.epochDay;

  /// Midnight UTC of this date; convert with your own time-zone package.
  DateTime toDateTimeUtc() => DateTime.utc(year, month, day);

  @override
  int compareTo(CivilDate other) => epochDay.compareTo(other.epochDay);

  @override
  bool operator ==(Object other) =>
      other is CivilDate &&
      other.year == year &&
      other.month == month &&
      other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() =>
      '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}'
      '-${day.toString().padLeft(2, '0')}';
}

/// Julian Day Number of a proleptic Gregorian [date].
int julianDayNumber(CivilDate date) => date.epochDay + 2440588;

/// Converts a Julian-calendar date to a (Gregorian) [CivilDate].
CivilDate julianCalendarToCivil(int year, int month, int day) {
  final a = (14 - month) ~/ 12;
  final y = year + 4800 - a;
  final m = month + 12 * a - 3;
  final jdn = day + (153 * m + 2) ~/ 5 + 365 * y + y ~/ 4 - 32083;
  return CivilDate.fromEpochDay(jdn - 2440588);
}
