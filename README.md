# date_holidays

Offline public holidays and business days for Dart and Flutter. Pure Dart, no
network, no native code: it runs on mobile, desktop, server, web and Wasm.

- **Türkiye, complete.** Public holidays with half-days (arife, 28 Ekim),
  Ramazan and Kurban Bayramı, and the religious days in Diyanet's calendar
  (kandil nights, Üç Aylar, Ramazan, Hicri Yılbaşı, Aşure).
- **Islamic dates per country.** Türkiye (Diyanet) and Saudi Arabia (Umm
  al-Qura) do not always start a month on the same day; each country uses its
  own calendar.
- **Business days.** `isBusinessDay`, `addBusinessDays`, `nextHoliday`.
- **Honest about uncertainty.** Dates that could still move by a day come
  back with `estimated: true`.
- **Localizable.** Names in the local language and English, region-aware
  lookup, and a hook to add your own translations.
- **Your own countries.** Holidays are plain data built from a few rules.

## Usage

```dart
import 'package:date_holidays/date_holidays.dart';

final tr = Holidays.of('TR');

for (final h in tr.holidaysIn(2026)) {
  print('${h.date}  ${h.name('tr')}');
}
// 2026-01-01  Yılbaşı
// 2026-01-15  Miraç Kandili
// …
// 2026-03-19  Ramazan Bayramı Arifesi
// 2026-03-20  Ramazan Bayramı

tr.isBusinessDay(CivilDate(2026, 3, 20)); // false
tr.addBusinessDays(CivilDate(2026, 5, 25), 3); // 2026-06-02
tr.nextHoliday(CivilDate(2026, 10, 1)); // 2026-10-28 Republic Day Eve
tr.holidaysBetween(CivilDate(2026, 12, 1), CivilDate(2027, 1, 10));
```

Dates are `CivilDate` values (year, month, day) with no time zone, so there
are no daylight-saving or UTC surprises. Convert with
`CivilDate.fromDateTime(...)` and `date.toDateTimeUtc()`.

### Days off, half-days and observances

| | `isDayOff` | `isHalfDay` | Counts as a business day |
|---|---|---|---|
| Public holiday | true | false | no |
| Half-day (arife, 28 Ekim from 13:00) | true | true | yes, unless `halfDayIsOff: true` |
| Religious day (kandil, Aşure, …) | false | false | yes |

```dart
final daysOff = tr.holidaysIn(2026).where((h) => h.isDayOff);
tr.isBusinessDay(CivilDate(2026, 3, 19), halfDayIsOff: true); // false
```

Kandil nights are listed, as Diyanet lists them, on the day whose evening
they begin: Miraç Kandili is the night of 27 Recep, so its date is 26 Recep.

## Localization

Every holiday has a name in its country's language and in English.
`name()` accepts the language tag your app already has, with or without a
region, and falls back to English:

```dart
h.name('tr'); // Ramazan Bayramı
h.name('tr_TR'); // Ramazan Bayramı
h.name('en-US'); // Eid al-Fitr
h.name('ja'); // Eid al-Fitr (no Japanese name, English fallback)
h.localizedName('ja'); // null — no fallback, so you can tell
```

To show holidays in another language, add the names once at start-up. Each
holiday has a stable id, and your names win over the built-in ones:

```dart
Holidays.addTranslations('de', {
  'tr.ramazan-bayrami': 'Zuckerfest',
  'tr.kurban-bayrami': 'Opferfest',
});
h.name('de_AT'); // Zuckerfest
```

In a Flutter app you can also skip this and use the id as a key in your own
ARB files. Translations that would help everyone are welcome as pull
requests; see [CONTRIBUTING.md](CONTRIBUTING.md).

The package returns `CivilDate` values and leaves formatting them
("20 Mart 2026", "March 20, 2026") to your app, for example with `intl`.

## How accurate are the Islamic dates?

Türkiye's dates come from a table generated with the criterion Diyanet uses,
the one adopted by the 2016 International Hijri Calendar Union Congress: a
month starts after the first evening on which the crescent is at least 5°
above the horizon and 8° from the sun somewhere on Earth before 24:00 UTC,
with an exception for the Americas.

- The table covers 1438–1480 AH (October 2016 to May 2058).
- It matches all 69 month starts that Diyanet has published for 2017–2027
  (`tool/diyanet_reference.csv`), including every Ramazan and Kurban Bayramı
  of those years. Kandil dates were checked for 2018, 2021 and 2023–2027.
- For months Diyanet has not published yet, the crescent is sometimes right
  at the limit. Those 12 months are listed in
  [doc/tr-diyanet.md](doc/tr-diyanet.md); dates inside them, and all dates
  after the table ends, have `estimated: true`.

```dart
final bayram = tr.holidaysIn(2037).firstWhere((h) => h.id == 'tr.ramazan-bayrami');
bayram.estimated; // true — could be one day later
```

The Islamic calendars can also be used directly:

```dart
turkeyDiyanetCalendar.resolve(1447, 9, 1)!.date; // 2026-02-19
ummAlQuraCalendar.resolve(1447, 9, 1)!.date; // 2026-02-18
```

| Calendar | For | Source |
|---|---|---|
| `turkeyDiyanetCalendar` | Türkiye | Calculated (2016 criterion), checked against Diyanet |
| `ummAlQuraCalendar` | Saudi Arabia | Official table, 1365–1500 AH |
| `TabularIslamicCalendar` | Fallback | Arithmetic, ±1 day, always `estimated` |

Saudi Arabia announces the start of Ramadan, Shawwal and Dhu al-Hijjah after
moon sighting, which can differ from the Umm al-Qura table by a day.

## Adding a country

```dart
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
    HolidayRule(id: 'xx.eid', names: {'en': 'Eid al-Fitr'}, date: HijriDate(10, 1), days: 3),
  ],
));
```

| Rule | Example |
|---|---|
| `FixedDate(10, 29)` | 29 October |
| `HijriDate(10, 1)` | 1 Shawwal in the country's Islamic calendar |
| `EasterOffset(-2)` | Good Friday (`orthodox: true` for Orthodox Easter) |
| `NthWeekday(5, DateTime.monday, -1)` | Last Monday of May |
| `WeekdayOnOrAfter(rule, DateTime.friday)` | First Friday on or after another rule |
| `Shifted(rule, -1)` | The day before another rule |

A `HolidayRule` can also have a length in days, a first and last year, a
half-day start time, regions and a substitute-day policy.

## Regenerating the tables

The tables in `lib/src/data/` are generated by Python scripts in `tool/`.
They are only needed when extending the tables.

```sh
pip install astronomy-engine global-land-mask numpy hijridate
python3 tool/generate_tr_diyanet.py     # Türkiye; --check only validates
python3 tool/generate_umm_al_qura.py    # Saudi Arabia
```

When Diyanet publishes a new year, add its month starts to
`tool/diyanet_reference.csv` and run the generator again: it stops if the
calculation and Diyanet disagree.

## Contributing

Contributions are welcome, especially new countries and corrected dates. A
country is one Dart file of plain data, so you can add one without touching
the engine.

- Found a wrong date? Open an issue with a link to the official source.
- Want to add a country or update a table? Read
  [CONTRIBUTING.md](CONTRIBUTING.md) for the steps, the rules for data
  sources and the tests a country needs.
- Planning a new calendar or an API change? Open an issue first.

Everything in the repository is written in English; holiday names are given
in the local language and in English.

## Roadmap

- More countries. Saudi Arabia and the MABIMS countries (Indonesia, Malaysia,
  Brunei, Singapore) come first.
- More calendars: Hebrew, Chinese, Persian.
- iCalendar (.ics) export.

## Data sources

- Diyanet İşleri Başkanlığı's yearly "Dini Günler" calendars.
- [Astronomy Engine](https://github.com/cosinekitty/astronomy) (MIT) for sun
  and moon positions in the generator.
- Umm al-Qura table via [hijridate](https://github.com/dralshehri/hijridate)
  (MIT).

## License

MIT
