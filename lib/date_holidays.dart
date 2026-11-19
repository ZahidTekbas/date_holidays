/// Offline public-holiday engine for Dart and Flutter.
///
/// ```dart
/// final tr = Holidays.of('TR');
/// for (final h in tr.holidaysIn(2026)) print(h);
/// tr.isBusinessDay(CivilDate(2026, 3, 20)); // false — Ramazan Bayramı
/// ```
library;

import 'src/countries/tr.dart';
import 'src/holiday_calendar.dart';
import 'src/translations.dart';

export 'src/calendars/easter.dart' show gregorianEaster, orthodoxEaster;
export 'src/calendars/islamic.dart'
    show
        IslamicCalendar,
        IslamicResolution,
        TableIslamicCalendar,
        TabularIslamicCalendar,
        turkeyDiyanetCalendar,
        ummAlQuraCalendar;
export 'src/civil_date.dart' show CivilDate;
export 'src/holiday.dart';
export 'src/holiday_calendar.dart';
export 'src/rules.dart';

/// Entry point: look up a country by ISO code.
abstract final class Holidays {
  static final Map<String, CountryDefinition> _countries = {
    'TR': turkey,
  };

  /// Supported ISO 3166-1 alpha-2 codes.
  static Iterable<String> get countries => _countries.keys;

  /// Calendar for [countryCode] (optionally a [region] such as `US-CA`).
  ///
  /// Throws an [ArgumentError] when the country is not supported.
  static HolidayCalendar of(String countryCode, {String? region}) {
    final def = _countries[countryCode.toUpperCase()];
    if (def == null) {
      throw ArgumentError.value(countryCode, 'countryCode', 'not supported');
    }
    return HolidayCalendar(def, region: region);
  }

  /// Registers or replaces a country (lets apps add or patch data).
  static void register(CountryDefinition definition) =>
      _countries[definition.code.toUpperCase()] = definition;

  /// Adds or replaces holiday names for [language].
  ///
  /// [names] maps holiday ids to names. Call it once at start-up to show
  /// holidays in a language the package does not ship:
  ///
  /// ```dart
  /// Holidays.addTranslations('de', {
  ///   'tr.ramazan-bayrami': 'Zuckerfest',
  ///   'tr.kurban-bayrami': 'Opferfest',
  /// });
  /// Holidays.of('TR').holidaysIn(2026).first.name('de_DE');
  /// ```
  ///
  /// These names win over the built-in ones, so this can also be used to
  /// reword a name. Ids that are not translated keep falling back to
  /// English.
  static void addTranslations(String language, Map<String, String> names) =>
      addHolidayNames(language, names);
}
