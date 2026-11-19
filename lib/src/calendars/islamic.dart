import '../civil_date.dart';
import '../data/islamic_tr_diyanet.g.dart' as tr;
import '../data/islamic_umm_al_qura.g.dart' as uaq;

/// Result of converting a Hijri date to the Gregorian calendar.
typedef IslamicResolution = ({CivilDate date, bool estimated});

/// One way of deciding when Islamic months begin.
///
/// Countries disagree, so each country picks its own:
/// * Turkey (Diyanet) — 2016 Unified Hijri Calendar criterion, calculated.
/// * Saudi Arabia — Umm al-Qura (published table).
/// * Indonesia / Malaysia / Brunei / Singapore — MABIMS criterion, calculated.
/// * Pakistan, Egypt, Morocco, … — local moon sighting: can only be estimated
///   ahead of time, then corrected from official announcements.
abstract interface class IslamicCalendar {
  /// Short identifier, e.g. `tr-diyanet`, `umm-al-qura`, `tabular`.
  String get id;

  /// Gregorian date of Hijri [year]/[month]/[day], or `null` if the day does
  /// not exist (e.g. day 30 of a 29-day month).
  IslamicResolution? resolve(int year, int month, int day);
}

/// Arithmetical ("tabular", civil epoch) Islamic calendar.
///
/// Only an approximation of real practice — usually within ±1 day — so every
/// result is flagged `estimated`. Used as the fallback outside table ranges.
final class TabularIslamicCalendar implements IslamicCalendar {
  /// Creates the tabular calendar.
  const TabularIslamicCalendar();

  @override
  String get id => 'tabular';

  /// Whether Hijri [year] has 355 days in the 30-year cycle.
  static bool isLeapYear(int year) => (14 + 11 * year) % 30 < 11;

  /// Length of Hijri [month] of [year] in days (29 or 30).
  static int monthLength(int year, int month) =>
      month.isOdd || (month == 12 && isLeapYear(year)) ? 30 : 29;

  @override
  IslamicResolution? resolve(int year, int month, int day) {
    if (month < 1 || month > 12 || day < 1 || day > monthLength(year, month)) {
      return null;
    }
    // JDN of 1 Muharram 1 AH (civil epoch, Friday 16 July 622 Julian) is
    // 1948440.
    final jdn = day +
        (59 * (month - 1) + 1) ~/ 2 + // ceil(29.5 * (month - 1))
        (year - 1) * 354 +
        (3 + 11 * year) ~/ 30 +
        1948439;
    return (date: CivilDate.fromEpochDay(jdn - 2440588), estimated: true);
  }
}

/// Islamic calendar backed by a pre-computed table of month lengths.
///
/// Tables are generated offline (see `tool/`) by running the country's own
/// astronomical criterion, then checked against officially published dates.
/// Outside the table range it falls back to [fallback], flagged `estimated`.
final class TableIslamicCalendar implements IslamicCalendar {
  @override
  final String id;

  /// Hijri year of the first month in the table.
  final int firstYear;

  /// Hijri month (1 to 12) of the first month in the table.
  final int firstMonth;

  /// Used for dates before or after the table.
  final IslamicCalendar fallback;

  final List<int> _starts; // epoch day of each month start; one extra at end
  final Set<int> _estimatedMonths;

  /// Creates a calendar from [monthLengths], one character per month
  /// (`'1'` = 30 days, `'0'` = 29 days), starting at [firstEpochDay].
  ///
  /// [estimatedMonths] lists table months (0 = the first) whose start is not
  /// certain; dates in them are returned with `estimated: true`.
  TableIslamicCalendar({
    required this.id,
    required this.firstYear,
    required this.firstMonth,
    required int firstEpochDay,
    required String monthLengths,
    Iterable<int> estimatedMonths = const [],
    this.fallback = const TabularIslamicCalendar(),
  })  : _starts = _buildStarts(firstEpochDay, monthLengths),
        _estimatedMonths = Set.unmodifiable(estimatedMonths);

  static List<int> _buildStarts(int first, String lengths) {
    final starts = <int>[first];
    for (final unit in lengths.codeUnits) {
      // '1' → 30-day month, '0' → 29-day month.
      starts.add(starts.last + (unit == 0x31 ? 30 : 29));
    }
    return List.unmodifiable(starts);
  }

  int _index(int year, int month) =>
      (year - firstYear) * 12 + (month - firstMonth);

  /// Whether Hijri [year]/[month] comes from the table (not the fallback).
  bool covers(int year, int month) {
    final index = _index(year, month);
    return month >= 1 &&
        month <= 12 &&
        index >= 0 &&
        index < _starts.length - 1;
  }

  @override
  IslamicResolution? resolve(int year, int month, int day) {
    if (month < 1 || month > 12 || day < 1) return null;
    if (!covers(year, month)) return fallback.resolve(year, month, day);
    final index = _index(year, month);
    if (day > _starts[index + 1] - _starts[index]) return null;
    return (
      date: CivilDate.fromEpochDay(_starts[index] + day - 1),
      estimated: _estimatedMonths.contains(index),
    );
  }
}

/// Turkey — Diyanet İşleri Başkanlığı, 2016 Unified Hijri Calendar criterion.
///
/// Covers 1438–1480 AH (October 2016 to May 2058). Months that Diyanet has
/// not published yet and that sit on the edge of the visibility limits are
/// returned with `estimated: true`.
final IslamicCalendar turkeyDiyanetCalendar = TableIslamicCalendar(
  id: 'tr-diyanet',
  firstYear: tr.firstHijriYear,
  firstMonth: tr.firstHijriMonth,
  firstEpochDay: tr.firstEpochDay,
  monthLengths: tr.monthLengths,
  estimatedMonths: tr.borderlineMonths,
);

/// Saudi Arabia — the Umm al-Qura calendar, 1365–1500 AH (1945 to 2077).
///
/// This is the official civil calendar. The start of Ramadan, Shawwal and
/// Dhu al-Hijjah is announced after moon sighting and can differ by a day.
final IslamicCalendar ummAlQuraCalendar = TableIslamicCalendar(
  id: 'umm-al-qura',
  firstYear: uaq.firstHijriYear,
  firstMonth: uaq.firstHijriMonth,
  firstEpochDay: uaq.firstEpochDay,
  monthLengths: uaq.monthLengths,
);

/// Hijri years that can have dates inside Gregorian years [fromYear]…[toYear].
Iterable<int> hijriYearsCovering(int fromYear, int toYear) sync* {
  // One Hijri year ≈ 0.970 Gregorian years; pad generously on each side.
  final from = ((fromYear - 622) * 33) ~/ 32 - 2;
  final to = ((toYear - 622) * 33) ~/ 32 + 2;
  for (var y = from; y <= to; y++) {
    yield y;
  }
}
