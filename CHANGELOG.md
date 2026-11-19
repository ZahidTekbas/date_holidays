## 0.1.0

First release.

- Türkiye (`TR`): public holidays with half-days (arife, 28 Ekim), Ramazan
  and Kurban Bayramı, and the religious days in Diyanet's calendar (kandil
  nights, Üç Aylar, Ramazan, Hicri Yılbaşı, Aşure).
- Diyanet Islamic calendar for 1438–1480 AH (2016–2058), calculated with the
  2016 Unified Hijri Calendar criterion and checked against 69 month starts
  published by Diyanet. Borderline future months are flagged `estimated`.
- Umm al-Qura calendar (Saudi Arabia) for 1365–1500 AH.
- Date rules: `FixedDate`, `HijriDate`, `EasterOffset`, `NthWeekday`,
  `WeekdayOnOrAfter`, `Shifted`.
- Localization: `name()` accepts region tags (`tr_TR`, `en-US`),
  `localizedName()` reports missing languages, and
  `Holidays.addTranslations` adds names for other languages.
- Business-day helpers: `isBusinessDay`, `addBusinessDays`, `nextHoliday`,
  `holidaysBetween`.
