import 'civil_date.dart';
import 'rules.dart';
import 'translations.dart';

/// What a holiday means for work and school.
enum HolidayType {
  /// Official public holiday: government offices closed.
  public,

  /// Banks / markets closed but not a general public holiday.
  bank,

  /// Schools closed only.
  school,

  /// Optional / regional choice (e.g. floating days).
  optional,

  /// Commemorated but a normal working day (e.g. kandil nights in Turkey).
  observance,
}

/// What happens when a holiday falls on a weekend.
enum SubstitutePolicy {
  /// Nothing (Turkey).
  none,

  /// An extra day off on the next working day (UK bank holidays, Japan…).
  nextWorkday,
}

/// A holiday definition: a [DateRule] plus metadata. Pure data.
final class HolidayRule {
  /// Stable identifier, e.g. `tr.ramazan-bayrami`.
  final String id;

  /// Names by language tag, e.g.
  /// `{'tr': 'Ramazan Bayramı', 'en': 'Eid al-Fitr'}`.
  ///
  /// Tags are lower case with `-` as the separator (`pt-br`). Always include
  /// `en`; it is the fallback for every other language.
  final Map<String, String> names;

  /// How the first day of the holiday is found.
  final DateRule date;

  /// Length in days (Kurban Bayramı = 4).
  final int days;

  /// What the holiday means for work and school.
  final HolidayType type;

  /// First Gregorian year the holiday applies (inclusive), if limited.
  final int? since;

  /// Last Gregorian year the holiday applies (inclusive), if limited.
  final int? until;

  /// For half-days: the time of day the holiday starts (Turkey: 13:00).
  final Duration? startsAt;

  /// Sub-national codes this applies to; `null` = whole country.
  final Set<String>? regions;

  /// What happens when the holiday falls on a weekend.
  final SubstitutePolicy substitute;

  /// Creates a holiday definition.
  const HolidayRule({
    required this.id,
    required this.names,
    required this.date,
    this.days = 1,
    this.type = HolidayType.public,
    this.since,
    this.until,
    this.startsAt,
    this.regions,
    this.substitute = SubstitutePolicy.none,
  });

  /// Whether the holiday exists in Gregorian [year].
  bool activeIn(int year) =>
      (since == null || year >= since!) && (until == null || year <= until!);
}

/// One concrete holiday day, produced by resolving a [HolidayRule].
final class Holiday {
  /// The day itself.
  final CivilDate date;

  /// The definition this day comes from.
  final HolidayRule rule;

  /// 1-based day within a multi-day holiday ("Kurban Bayramı 2. gün").
  final int dayNumber;

  /// True when the date could be off by a day: Islamic dates outside the
  /// verified table, borderline months, or sighting-based countries.
  final bool estimated;

  /// True for a day added by [SubstitutePolicy].
  final bool isSubstitute;

  /// Creates a holiday day.
  const Holiday({
    required this.date,
    required this.rule,
    this.dayNumber = 1,
    this.estimated = false,
    this.isSubstitute = false,
  });

  /// Identifier of the holiday, e.g. `tr.ramazan-bayrami`.
  String get id => rule.id;

  /// What the holiday means for work and school.
  HolidayType get type => rule.type;

  /// Length of the whole holiday in days.
  int get totalDays => rule.days;

  /// Whether the holiday only starts part-way through the day.
  bool get isHalfDay => rule.startsAt != null;

  /// For half-days: the time of day the holiday starts.
  Duration? get startsAt => rule.startsAt;

  /// Whether people normally have this day off (half-days count as off).
  bool get isDayOff => type != HolidayType.observance;

  /// The name in [language], falling back to English.
  ///
  /// [language] may carry a region or script (`tr_TR`, `en-US`,
  /// `zh_Hant_TW`); the most specific name available is used. Names added
  /// with `Holidays.addTranslations` win over the built-in ones.
  String name([String language = 'en']) =>
      localizedName(language) ?? localizedName('en') ?? rule.names.values.first;

  /// The name in [language], or `null` when there is no name for that
  /// language. Unlike [name] this never falls back to English.
  String? localizedName(String language) =>
      lookUpName(rule.id, rule.names, language);

  @override
  String toString() {
    final suffix = [
      if (totalDays > 1) 'day $dayNumber/$totalDays',
      if (isHalfDay) 'from ${startsAt!.inHours}:00',
      if (estimated) 'estimated',
      if (isSubstitute) 'substitute',
    ];
    return '$date ${name()}${suffix.isEmpty ? '' : ' (${suffix.join(', ')})'}';
  }
}
