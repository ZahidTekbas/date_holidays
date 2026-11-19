# Contributing to date_holidays

Thanks for helping. The most valuable contributions are **holiday data**:
a new country, a missing holiday, or a corrected date. You do not need to
know the engine to add them — a country is one Dart file of plain data.

All code, comments, documentation, commit messages and issues are written in
English. Holiday names are the exception: give each one in the country's own
language and in English.

## Ways to contribute

| You want to… | Do this |
|---|---|
| Report a wrong or missing date | Open an issue with the date, the country and a link to an official source |
| Add a country | See [Adding a country](#adding-a-country) |
| Translate holiday names | See [Adding translations](#adding-translations) |
| Update Türkiye when Diyanet publishes a new year | See [Updating the Diyanet table](#updating-the-diyanet-table) |
| Add a calendar (Hebrew, Chinese, MABIMS, …) | Open an issue first so we can agree on the design |
| Change the public API | Open an issue first |

## Setup

You need the [Dart SDK](https://dart.dev/get-dart) 3.5 or newer.

```sh
git clone https://github.com/zahidtekbas/date_holidays.git
cd date_holidays
dart pub get
dart test
```

Before you open a pull request, all of these must pass. CI runs the same
commands.

```sh
dart format --output=none --set-exit-if-changed .
dart analyze --fatal-infos
dart test
```

## Project layout

```
lib/
  date_holidays.dart          Public API and the country registry
  src/civil_date.dart         Time-zone-free date
  src/rules.dart              Date rules: FixedDate, HijriDate, EasterOffset, …
  src/holiday.dart            HolidayRule (data) and Holiday (result)
  src/holiday_calendar.dart   Resolution, business days, substitute days
  src/calendars/              Easter and Islamic calendars
  src/countries/              One file per country
  src/data/*.g.dart           Generated tables — never edit by hand
tool/                         Python scripts that generate the tables
test/                         Tests
doc/                          Generated notes about the tables
```

## Adding a country

1. Create `lib/src/countries/<code>.dart` (ISO 3166-1 alpha-2, lower case)
   with a `CountryDefinition`. Use `lib/src/countries/tr.dart` as the model.
2. Register it in the `_countries` map in `lib/date_holidays.dart`.
3. Add `test/<code>_test.dart`.
4. Add a line to `CHANGELOG.md` and to the README.

Rules for the data:

- **Use official sources.** The law that defines the holidays, a government
  gazette, or the responsible ministry. Put the source in a comment above
  the definition. Wikipedia and other holiday libraries are not sources.
- **Do not copy data from other libraries.** In particular, the country
  files of `date-holidays` (npm) are CC BY-SA and cannot be included in this
  MIT-licensed package. Write the rules yourself from the official source.
- **Give every holiday a stable id**, `<code>.<slug>`, for example
  `tr.ramazan-bayrami`. Ids are part of the public API; do not rename them.
- **Record when a holiday started or ended** with `since` and `until`.
- **Mark the type correctly.** `public` for days off, `observance` for days
  that are commemorated but worked.
- **Model half-days** with `startsAt`, and weekend replacements with
  `SubstitutePolicy`.
- **Pick the country's own Islamic calendar.** If the country decides by
  local moon sighting, use `TabularIslamicCalendar`; its dates are returned
  with `estimated: true`, which is the honest answer.

Tests for a country must include:

- the complete list of days off for at least one recent year, compared with
  the officially published list;
- every rule that depends on a year (`since`, `until`);
- at least one moving holiday checked against official dates for three
  different years.

If a rule you need does not exist (for example "the Monday after …"), add a
`DateRule` subclass in `lib/src/rules.dart` with tests, in the same pull
request.

## Adding translations

Holiday names live in the `names` map of each `HolidayRule`, keyed by
language tag:

```dart
names: {'tr': 'Ramazan Bayramı', 'en': 'Eid al-Fitr', 'de': 'Zuckerfest'},
```

- Keys are lower-case BCP 47 tags with `-` as the separator: `de`, `pt-br`.
  Use the plain language (`de`) unless a region really uses another name.
- Every holiday must keep its local-language name and its `en` name. `en` is
  the fallback for all other languages.
- Use the name people in that language actually use for the holiday, not a
  word-for-word translation. If the language has no established name, leave
  it out and let it fall back to English.
- Translate all holidays of a country in one pull request, so a language is
  never half done, and add the language to the test of that country.
- Do not change holiday ids. Apps use them as keys for their own
  translations.

## Updating the Diyanet table

Türkiye's Islamic dates come from `lib/src/data/islamic_tr_diyanet.g.dart`,
which is generated and then checked against the month starts Diyanet has
published.

When Diyanet publishes its "Dini Günler" list for a new year:

1. Add the month starts to `tool/diyanet_reference.csv`. A kandil date gives
   you the first day of its month: Miraç Kandili is 26 Recep, Berat Kandili
   14 Şaban, Kadir Gecesi 26 Ramazan, Mevlid Kandili 11 Rebiülevvel.
2. Regenerate:

   ```sh
   pip install astronomy-engine global-land-mask numpy
   python3 tool/generate_tr_diyanet.py
   dart format .
   ```

3. Add the new dates to the Diyanet tests in `test/tr_test.dart` and run
   `dart test`.

The generator stops with an error if its calculation and Diyanet disagree.
That is a real finding, not something to work around: open an issue with the
month and the source, and do not edit the generated table by hand.

Months listed in `doc/tr-diyanet.md` are the ones most likely to need this.

## Code style

- Format with `dart format`; keep `dart analyze` clean.
- Every public class, member and top-level function has a `///` doc comment.
- Dates are `CivilDate` everywhere. Do not use `DateTime` for calendar
  arithmetic; time zones and daylight saving cause off-by-one-day bugs.
- The package has no runtime dependencies and must keep working on the web
  and Wasm: no `dart:io`, no `dart:ffi`, no 64-bit integer tricks.
- Never state a date as certain when it is not. Use the `estimated` flag.

## Pull requests

- One topic per pull request, with tests.
- Explain where the data comes from and link the source.
- Update `CHANGELOG.md` under an "Unreleased" heading.
- Changes to `*.g.dart` must come from the generator, together with the
  script or CSV change that produced them.

## Versioning

The package follows semantic versioning. A corrected date is a bug fix. A
new country or rule is a minor release. Renaming a holiday id or changing a
public type is a breaking change.

## License

By contributing you agree that your contribution is licensed under the MIT
License of this repository.
