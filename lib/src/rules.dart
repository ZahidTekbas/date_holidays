import 'calendars/easter.dart';
import 'calendars/islamic.dart';
import 'civil_date.dart';

/// A rule-produced date, plus whether it is only an estimate.
typedef RuleDate = ({CivilDate date, bool estimated});

/// What a rule needs to know about the country it is evaluated for.
final class RuleContext {
  /// The country's own method for Islamic month starts.
  final IslamicCalendar islamicCalendar;

  /// Creates a context.
  const RuleContext({required this.islamicCalendar});
}

/// How to find the (first) date of a holiday. Rules are plain data, so a
/// country definition can be written in Dart or generated from YAML.
sealed class DateRule {
  /// Const constructor for subclasses.
  const DateRule();

  /// All dates this rule produces in [from]…[to] (inclusive).
  Iterable<RuleDate> datesBetween(
      CivilDate from, CivilDate to, RuleContext ctx);
}

/// Same Gregorian month/day every year, e.g. `FixedDate(10, 29)`.
///
/// `FixedDate(2, 29)` only produces a date in leap years.
final class FixedDate extends DateRule {
  /// Month, 1 to 12.
  final int month;

  /// Day of the month.
  final int day;

  /// Creates a rule for [month]/[day].
  const FixedDate(this.month, this.day);

  @override
  Iterable<RuleDate> datesBetween(
      CivilDate from, CivilDate to, RuleContext ctx) sync* {
    for (var y = from.year; y <= to.year; y++) {
      final d = CivilDate(y, month, day);
      if (d.isValid && !d.isBefore(from) && !d.isAfter(to)) {
        yield (date: d, estimated: false);
      }
    }
  }
}

/// A date in the Islamic calendar, e.g. `HijriDate(10, 1)` = 1 Shawwal.
/// Resolved with the country's own [IslamicCalendar].
final class HijriDate extends DateRule {
  /// Islamic month, 1 (Muharram) to 12 (Dhu al-Hijjah).
  final int month;

  /// Day of the Islamic month, 1 to 30.
  final int day;

  /// Creates a rule for [day] of Islamic [month].
  const HijriDate(this.month, this.day);

  @override
  Iterable<RuleDate> datesBetween(
      CivilDate from, CivilDate to, RuleContext ctx) sync* {
    // A Gregorian year can contain the same Hijri date twice (~every 33
    // years), so check every Hijri year that overlaps the range.
    for (final hy in hijriYearsCovering(from.year, to.year)) {
      final r = ctx.islamicCalendar.resolve(hy, month, day);
      if (r != null && !r.date.isBefore(from) && !r.date.isAfter(to)) yield r;
    }
  }
}

/// Days relative to Easter Sunday, e.g. `EasterOffset(-2)` = Good Friday.
final class EasterOffset extends DateRule {
  /// Days after Easter Sunday (negative = before).
  final int offset;

  /// Use Orthodox Easter instead of Western Easter.
  final bool orthodox;

  /// Creates a rule [offset] days from Easter Sunday.
  const EasterOffset(this.offset, {this.orthodox = false});

  @override
  Iterable<RuleDate> datesBetween(
      CivilDate from, CivilDate to, RuleContext ctx) sync* {
    for (var y = from.year - 1; y <= to.year + 1; y++) {
      final easter = orthodox ? orthodoxEaster(y) : gregorianEaster(y);
      final d = easter.addDays(offset);
      if (!d.isBefore(from) && !d.isAfter(to)) {
        yield (date: d, estimated: false);
      }
    }
  }
}

/// The [n]th [weekday] of [month]; negative [n] counts from the end
/// (`NthWeekday(5, DateTime.monday, -1)` = last Monday of May).
final class NthWeekday extends DateRule {
  /// Month, 1 to 12.
  final int month;

  /// ISO weekday, Monday = 1 … Sunday = 7.
  final int weekday;

  /// Which occurrence: 1 = first, 2 = second, -1 = last. Never 0.
  final int n;

  /// Creates a rule for the [n]th [weekday] of [month].
  const NthWeekday(this.month, this.weekday, this.n) : assert(n != 0);

  @override
  Iterable<RuleDate> datesBetween(
      CivilDate from, CivilDate to, RuleContext ctx) sync* {
    for (var y = from.year; y <= to.year; y++) {
      final CivilDate d;
      if (n > 0) {
        final first = CivilDate(y, month, 1);
        d = first.addDays((weekday - first.weekday) % 7 + 7 * (n - 1));
      } else {
        final nextMonth =
            month == 12 ? CivilDate(y + 1, 1, 1) : CivilDate(y, month + 1, 1);
        final last = nextMonth.addDays(-1);
        d = last.addDays(-((last.weekday - weekday) % 7) + 7 * (n + 1));
      }
      if (d.month == month && !d.isBefore(from) && !d.isAfter(to)) {
        yield (date: d, estimated: false);
      }
    }
  }
}

/// Another rule moved by [days], e.g. the eve of a holiday:
/// `Shifted(HijriDate(10, 1), -1)` = arife of Ramazan Bayramı.
final class Shifted extends DateRule {
  /// The rule being moved.
  final DateRule base;

  /// Days to add (negative = earlier).
  final int days;

  /// Creates a rule that moves [base] by [days].
  const Shifted(this.base, this.days);

  @override
  Iterable<RuleDate> datesBetween(
          CivilDate from, CivilDate to, RuleContext ctx) =>
      base
          .datesBetween(from.addDays(-days), to.addDays(-days), ctx)
          .map((r) => (date: r.date.addDays(days), estimated: r.estimated));
}

/// The first [weekday] on or after the date of another rule.
///
/// Regaip Kandili is the night before the first Friday of Recep:
/// `Shifted(WeekdayOnOrAfter(HijriDate(7, 1), DateTime.friday), -1)`.
final class WeekdayOnOrAfter extends DateRule {
  /// The rule that gives the earliest possible date.
  final DateRule base;

  /// ISO weekday, Monday = 1 … Sunday = 7.
  final int weekday;

  /// Creates a rule for the first [weekday] on or after [base].
  const WeekdayOnOrAfter(this.base, this.weekday)
      : assert(weekday >= 1 && weekday <= 7);

  @override
  Iterable<RuleDate> datesBetween(
      CivilDate from, CivilDate to, RuleContext ctx) sync* {
    for (final r in base.datesBetween(from.addDays(-6), to, ctx)) {
      final d = r.date.addDays((weekday - r.date.weekday) % 7);
      if (!d.isBefore(from) && !d.isAfter(to)) {
        yield (date: d, estimated: r.estimated);
      }
    }
  }
}
