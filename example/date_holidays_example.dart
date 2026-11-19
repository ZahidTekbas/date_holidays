// Prints examples to the console.
// ignore_for_file: avoid_print
import 'package:date_holidays/date_holidays.dart';

void main() {
  final tr = Holidays.of('TR');

  // Every public holiday and religious day of a year.
  for (final h in tr.holidaysIn(2026)) {
    final kind =
        h.isDayOff ? (h.isHalfDay ? 'half day' : 'day off') : 'observance';
    print('${h.date}  ${h.name('tr')}  ($kind)');
  }

  // Business-day arithmetic that knows about Kurban Bayramı.
  final ordered = CivilDate(2026, 5, 25);
  print('3 business days after $ordered: ${tr.addBusinessDays(ordered, 3)}');

  // What is next?
  final next = tr.nextHoliday(CivilDate(2026, 10, 1))!;
  print('Next holiday: ${next.name('tr')} on ${next.date}');

  // Dates beyond what Diyanet has published can carry an "estimated" flag.
  final bayram2037 =
      tr.holidaysIn(2037).firstWhere((h) => h.id == 'tr.ramazan-bayrami');
  print('${bayram2037.date} estimated: ${bayram2037.estimated}');

  // The same Islamic date in two countries' calendars.
  final turkey = turkeyDiyanetCalendar.resolve(1447, 9, 1)!.date;
  final saudi = ummAlQuraCalendar.resolve(1447, 9, 1)!.date;
  print('1 Ramadan 1447: Türkiye $turkey, Saudi Arabia $saudi');

  // Add your own country (or patch an existing one).
  Holidays.register(CountryDefinition(
    code: 'XX',
    names: const {'en': 'Example'},
    weekend: const {DateTime.saturday, DateTime.sunday},
    timeZone: 'UTC',
    islamicCalendar: ummAlQuraCalendar,
    rules: const [
      HolidayRule(
        id: 'xx.new-year',
        names: {'en': "New Year's Day"},
        date: FixedDate(1, 1),
        substitute: SubstitutePolicy.nextWorkday,
      ),
      HolidayRule(
        id: 'xx.eid',
        names: {'en': 'Eid al-Fitr'},
        date: HijriDate(10, 1),
        days: 3,
      ),
    ],
  ));
  print(Holidays.of('XX').holidaysIn(2027).join('\n'));
}
