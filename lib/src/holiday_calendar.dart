import 'calendars/islamic.dart';
import 'civil_date.dart';
import 'holiday.dart';
import 'rules.dart';
import 'translations.dart';

/// Everything that defines one country's holidays.
final class CountryDefinition {
  /// ISO 3166-1 alpha-2, e.g. `TR`.
  final String code;

  /// Country names by language tag (lower case, e.g. `tr`, `en`).
  final Map<String, String> names;

  /// ISO weekdays that are the weekend (Turkey: Saturday + Sunday).
  final Set<int> weekend;

  /// IANA zone, for apps that need to turn dates into instants.
  final String timeZone;

  /// The country's own method for Islamic month starts.
  final IslamicCalendar islamicCalendar;

  /// The holiday definitions.
  final List<HolidayRule> rules;

  /// Creates a country definition.
  const CountryDefinition({
    required this.code,
    required this.names,
    required this.weekend,
    required this.timeZone,
    required this.islamicCalendar,
    required this.rules,
  });

  /// The country's name in [language], falling back to English.
  ///
  /// [language] may carry a region or script (`tr_TR`, `en-US`).
  String name([String language = 'en']) =>
      lookUpName(null, names, language) ??
      lookUpName(null, names, 'en') ??
      names.values.first;
}

/// Query API for one country (and optionally one region).
final class HolidayCalendar {
  /// The country this calendar answers for.
  final CountryDefinition country;

  /// Sub-national code, if regional holidays should be included.
  final String? region;

  final RuleContext _ctx;
  final Map<int, List<Holiday>> _cache = {};

  /// Creates a calendar for [country] (and optionally one [region]).
  HolidayCalendar(this.country, {this.region})
      : _ctx = RuleContext(islamicCalendar: country.islamicCalendar);

  /// All holiday days in Gregorian [year], sorted by date.
  List<Holiday> holidaysIn(int year) => _cache.putIfAbsent(year, () {
        final from = CivilDate(year, 1, 1);
        final to = CivilDate(year, 12, 31);
        final result = <Holiday>[];
        for (final rule in country.rules) {
          if (rule.regions != null &&
              (region == null || !rule.regions!.contains(region))) {
            continue;
          }
          // Start a bit early so multi-day holidays that began last year
          // (e.g. Ramazan Bayramı starting 30 Dec) still show their later
          // days.
          final starts =
              rule.date.datesBetween(from.addDays(-(rule.days - 1)), to, _ctx);
          for (final start in starts) {
            if (!rule.activeIn(start.date.year)) continue;
            for (var i = 0; i < rule.days; i++) {
              final day = start.date.addDays(i);
              if (day.year != year) continue;
              result.add(Holiday(
                date: day,
                rule: rule,
                dayNumber: i + 1,
                estimated: start.estimated,
              ));
            }
          }
        }
        _addSubstitutes(result);
        // List.sort is not stable, so break ties to keep the order fixed.
        result.sort((a, b) {
          final byDate = a.date.compareTo(b.date);
          return byDate != 0 ? byDate : a.id.compareTo(b.id);
        });
        return List.unmodifiable(result);
      });

  void _addSubstitutes(List<Holiday> days) {
    final taken = {
      for (final h in days)
        if (h.isDayOff) h.date
    };
    for (final h in [...days]) {
      if (h.rule.substitute != SubstitutePolicy.nextWorkday) continue;
      if (!country.weekend.contains(h.date.weekday)) continue;
      var d = h.date.addDays(1);
      while (country.weekend.contains(d.weekday) || taken.contains(d)) {
        d = d.addDays(1);
      }
      taken.add(d);
      days.add(Holiday(
          date: d, rule: h.rule, estimated: h.estimated, isSubstitute: true));
    }
  }

  /// Holidays on [date] (usually zero or one).
  List<Holiday> holidaysOn(CivilDate date) =>
      holidaysIn(date.year).where((h) => h.date == date).toList();

  /// All holiday days from [from] to [to] (both inclusive), sorted by date.
  List<Holiday> holidaysBetween(CivilDate from, CivilDate to) => [
        for (var y = from.year; y <= to.year; y++)
          for (final h in holidaysIn(y))
            if (!h.date.isBefore(from) && !h.date.isAfter(to)) h
      ];

  /// Whether [date] is a day off (weekend or full-day holiday).
  /// Half-days count as working days unless [halfDayIsOff] is true.
  bool isDayOff(CivilDate date, {bool halfDayIsOff = false}) {
    if (country.weekend.contains(date.weekday)) return true;
    return holidaysOn(date)
        .any((h) => h.isDayOff && (halfDayIsOff || !h.isHalfDay));
  }

  /// The opposite of [isDayOff].
  bool isBusinessDay(CivilDate date, {bool halfDayIsOff = false}) =>
      !isDayOff(date, halfDayIsOff: halfDayIsOff);

  /// [date] moved by [days] business days (negative = backwards).
  /// Banking settlement, delivery estimates, legal deadlines…
  CivilDate addBusinessDays(CivilDate date, int days,
      {bool halfDayIsOff = false}) {
    final step = days >= 0 ? 1 : -1;
    var remaining = days.abs();
    var d = date;
    while (remaining > 0) {
      d = d.addDays(step);
      if (isBusinessDay(d, halfDayIsOff: halfDayIsOff)) remaining--;
    }
    return d;
  }

  /// Next holiday strictly after [date] (looks up to two years ahead).
  ///
  /// Skips working-day observances unless [dayOffOnly] is false.
  Holiday? nextHoliday(CivilDate date, {bool dayOffOnly = true}) {
    for (var y = date.year; y <= date.year + 2; y++) {
      for (final h in holidaysIn(y)) {
        if (h.date.isAfter(date) && (!dayOffOnly || h.isDayOff)) return h;
      }
    }
    return null;
  }
}
