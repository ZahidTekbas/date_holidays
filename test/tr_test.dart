import 'package:date_holidays/date_holidays.dart';
import 'package:test/test.dart';

/// First days of Ramazan and Kurban Bayramı as published by Diyanet.
const _diyanetBayrams = {
  2017: ('2017-06-25', '2017-09-01'),
  2018: ('2018-06-15', '2018-08-21'),
  2019: ('2019-06-04', '2019-08-11'),
  2020: ('2020-05-24', '2020-07-31'),
  2021: ('2021-05-13', '2021-07-20'),
  2022: ('2022-05-02', '2022-07-09'),
  2023: ('2023-04-21', '2023-06-28'),
  2024: ('2024-04-10', '2024-06-16'),
  2025: ('2025-03-30', '2025-06-06'),
  2026: ('2026-03-20', '2026-05-27'),
  2027: ('2027-03-09', '2027-05-16'),
};

/// Islamic month starts published by Diyanet: (Hijri year, month) → first
/// day. Same data as tool/diyanet_reference.csv.
const _diyanetMonthStarts = {
  (1438, 7): '2017-03-29',
  (1438, 9): '2017-05-27',
  (1438, 10): '2017-06-25',
  (1438, 12): '2017-08-23',
  (1439, 1): '2017-09-21',
  (1439, 3): '2017-11-19',
  (1439, 5): '2018-01-18',
  (1439, 7): '2018-03-19',
  (1439, 8): '2018-04-17',
  (1439, 9): '2018-05-16',
  (1439, 10): '2018-06-15',
  (1439, 12): '2018-08-12',
  (1440, 1): '2018-09-11',
  (1440, 3): '2018-11-09',
  (1440, 10): '2019-06-04',
  (1440, 12): '2019-08-02',
  (1441, 8): '2020-03-25',
  (1441, 10): '2020-05-24',
  (1441, 12): '2020-07-22',
  (1442, 7): '2021-02-13',
  (1442, 8): '2021-03-14',
  (1442, 9): '2021-04-13',
  (1442, 10): '2021-05-13',
  (1442, 11): '2021-06-11',
  (1442, 12): '2021-07-11',
  (1443, 1): '2021-08-09',
  (1443, 3): '2021-10-07',
  (1443, 10): '2022-05-02',
  (1443, 11): '2022-05-31',
  (1443, 12): '2022-06-30',
  (1444, 1): '2022-07-30',
  (1444, 2): '2022-08-28',
  (1444, 4): '2022-10-27',
  (1444, 10): '2023-04-21',
  (1444, 11): '2023-05-21',
  (1444, 12): '2023-06-19',
  (1445, 1): '2023-07-19',
  (1445, 2): '2023-08-17',
  (1445, 3): '2023-09-16',
  (1445, 7): '2024-01-12',
  (1445, 9): '2024-03-11',
  (1445, 10): '2024-04-10',
  (1445, 11): '2024-05-09',
  (1445, 12): '2024-06-07',
  (1446, 1): '2024-07-07',
  (1446, 2): '2024-08-05',
  (1446, 3): '2024-09-04',
  (1446, 7): '2025-01-01',
  (1446, 8): '2025-01-31',
  (1446, 9): '2025-03-01',
  (1446, 10): '2025-03-30',
  (1446, 11): '2025-04-29',
  (1446, 12): '2025-05-28',
  (1447, 3): '2025-08-24',
  (1447, 5): '2025-10-23',
  (1447, 7): '2025-12-21',
  (1447, 8): '2026-01-20',
  (1447, 9): '2026-02-19',
  (1447, 10): '2026-03-20',
  (1447, 12): '2026-05-18',
  (1448, 3): '2026-08-14',
  (1448, 7): '2026-12-10',
  (1448, 8): '2027-01-09',
  (1448, 9): '2027-02-08',
  (1448, 10): '2027-03-09',
  (1448, 12): '2027-05-07',
  (1449, 1): '2027-06-06',
  (1449, 3): '2027-08-03',
  (1449, 7): '2027-11-29',
};

/// Kandil nights as listed in Diyanet's yearly "Dini Günler" calendars.
const _diyanetKandils = {
  2018: {
    'tr.regaip-kandili': ['2018-03-22'],
    'tr.mirac-kandili': ['2018-04-13'],
    'tr.berat-kandili': ['2018-04-30'],
    'tr.kadir-gecesi': ['2018-06-10'],
    'tr.mevlid-kandili': ['2018-11-19'],
  },
  2021: {
    'tr.regaip-kandili': ['2021-02-18'],
    'tr.mirac-kandili': ['2021-03-10'],
    'tr.berat-kandili': ['2021-03-27'],
    'tr.kadir-gecesi': ['2021-05-08'],
  },
  2023: {
    'tr.regaip-kandili': ['2023-01-26'],
    'tr.mirac-kandili': ['2023-02-17'],
    'tr.berat-kandili': ['2023-03-06'],
    'tr.kadir-gecesi': ['2023-04-17'],
    'tr.mevlid-kandili': ['2023-09-26'],
  },
  2024: {
    'tr.regaip-kandili': ['2024-01-11'],
    'tr.kadir-gecesi': ['2024-04-05'],
    'tr.mevlid-kandili': ['2024-09-14'],
  },
  2025: {
    'tr.regaip-kandili': ['2025-01-02', '2025-12-25'],
    'tr.mirac-kandili': ['2025-01-26'],
    'tr.berat-kandili': ['2025-02-13'],
    'tr.kadir-gecesi': ['2025-03-26'],
    'tr.mevlid-kandili': ['2025-09-03'],
  },
  2026: {
    'tr.regaip-kandili': ['2026-12-10'],
    'tr.mirac-kandili': ['2026-01-15'],
    'tr.berat-kandili': ['2026-02-02'],
    'tr.kadir-gecesi': ['2026-03-16'],
    'tr.mevlid-kandili': ['2026-08-24'],
  },
  2027: {
    'tr.regaip-kandili': ['2027-12-02'],
    'tr.mirac-kandili': ['2027-01-04', '2027-12-24'],
    'tr.berat-kandili': ['2027-01-22'],
    'tr.kadir-gecesi': ['2027-03-05'],
    'tr.mevlid-kandili': ['2027-08-13'],
  },
};

void main() {
  final tr = Holidays.of('TR');

  List<CivilDate> firsts(int year, String id) => [
        for (final h in tr.holidaysIn(year))
          if (h.id == id && h.dayNumber == 1) h.date
      ];

  CivilDate first(int year, String id) => firsts(year, id).first;

  group('Türkiye matches Diyanet', () {
    _diyanetBayrams.forEach((year, dates) {
      test('bayrams $year', () {
        expect(first(year, 'tr.ramazan-bayrami'), CivilDate.parse(dates.$1));
        expect(first(year, 'tr.kurban-bayrami'), CivilDate.parse(dates.$2));
      });
    });

    test('every published month start', () {
      _diyanetMonthStarts.forEach((month, start) {
        final r = turkeyDiyanetCalendar.resolve(month.$1, month.$2, 1)!;
        expect(r.date, CivilDate.parse(start), reason: 'month $month');
        expect(r.estimated, isFalse, reason: 'month $month');
      });
    });

    _diyanetKandils.forEach((year, kandils) {
      test('kandils $year', () {
        kandils.forEach((id, dates) {
          expect(firsts(year, id), dates.map(CivilDate.parse), reason: id);
        });
      });
    });

    test('Ramazan 1447 started on 19 Feb 2026 (Saudi Arabia: 18 Feb)', () {
      expect(first(2026, 'tr.ramazan-baslangici'), CivilDate(2026, 2, 19));
      expect(
          ummAlQuraCalendar.resolve(1447, 9, 1)!.date, CivilDate(2026, 2, 18));
    });

    test('Hicri yılbaşı', () {
      expect(first(2023, 'tr.hicri-yilbasi'), CivilDate(2023, 7, 19));
      expect(first(2027, 'tr.hicri-yilbasi'), CivilDate(2027, 6, 6));
    });

    test('Regaip is the eve of Recep when 1 Recep is a Friday', () {
      expect(first(2024, 'tr.uc-aylar'), CivilDate(2024, 1, 12));
      expect(CivilDate(2024, 1, 12).weekday, DateTime.friday);
      expect(first(2024, 'tr.regaip-kandili'), CivilDate(2024, 1, 11));
    });

    test('Regaip falls on 1 Recep when 1 Recep is a Thursday', () {
      expect(first(2026, 'tr.uc-aylar'), CivilDate(2026, 12, 10));
      expect(first(2026, 'tr.regaip-kandili'), CivilDate(2026, 12, 10));
    });
  });

  group('Türkiye, calculated ahead of Diyanet', () {
    test('2028 and 2029 bayrams', () {
      expect(first(2028, 'tr.ramazan-bayrami'), CivilDate(2028, 2, 26));
      expect(first(2028, 'tr.kurban-bayrami'), CivilDate(2028, 5, 5));
      expect(first(2029, 'tr.ramazan-bayrami'), CivilDate(2029, 2, 14));
      expect(first(2029, 'tr.kurban-bayrami'), CivilDate(2029, 4, 24));
    });

    test('Ramazan Bayramı falls twice in 2033', () {
      expect(firsts(2033, 'tr.ramazan-bayrami'),
          [CivilDate(2033, 1, 2), CivilDate(2033, 12, 23)]);
      // Its eve shares 1 January with Yılbaşı.
      expect(tr.holidaysOn(CivilDate(2033, 1, 1)).map((h) => h.id),
          ['tr.ramazan-bayrami-arifesi', 'tr.yilbasi']);
      expect(tr.isBusinessDay(CivilDate(2033, 1, 1)), isFalse);
    });

    test('Kurban Bayramı falls twice in 2039', () {
      expect(firsts(2039, 'tr.kurban-bayrami'),
          [CivilDate(2039, 1, 5), CivilDate(2039, 12, 26)]);
      expect(firsts(2039, 'tr.kurban-bayrami-arifesi'),
          [CivilDate(2039, 1, 4), CivilDate(2039, 12, 25)]);
      final days =
          tr.holidaysIn(2039).where((h) => h.id == 'tr.kurban-bayrami');
      expect(days.length, 8);
    });

    test('borderline months are flagged as estimated', () {
      bool estimated(int year, String id) => tr
          .holidaysIn(year)
          .where((h) => h.id == id)
          .every((h) => h.estimated);
      // Şevval 1459 sits on the edge of the visibility limits.
      expect(first(2037, 'tr.ramazan-bayrami'), CivilDate(2037, 11, 8));
      expect(estimated(2037, 'tr.ramazan-bayrami'), isTrue);
      expect(estimated(2036, 'tr.ramazan-bayrami'), isFalse);
    });

    test('dates after the table are flagged as estimated', () {
      bool anyEstimated(int year, String id) =>
          tr.holidaysIn(year).where((h) => h.id == id).any((h) => h.estimated);
      // The table ends with Zilkade 1480 (May 2058).
      expect(anyEstimated(2058, 'tr.ramazan-bayrami'), isFalse);
      expect(anyEstimated(2058, 'tr.kurban-bayrami'), isTrue);
      final far =
          tr.holidaysIn(2090).where((h) => h.id == 'tr.ramazan-bayrami');
      expect(far.length, 3);
      expect(far.every((h) => h.estimated), isTrue);
    });
  });

  group('Türkiye, public holidays', () {
    test('2026 holiday list', () {
      final days = tr.holidaysIn(2026).where((h) => h.isDayOff).toList();
      expect(days.map((h) => '${h.date} ${h.id} ${h.dayNumber}'), [
        '2026-01-01 tr.yilbasi 1',
        '2026-03-19 tr.ramazan-bayrami-arifesi 1',
        '2026-03-20 tr.ramazan-bayrami 1',
        '2026-03-21 tr.ramazan-bayrami 2',
        '2026-03-22 tr.ramazan-bayrami 3',
        '2026-04-23 tr.23-nisan 1',
        '2026-05-01 tr.1-mayis 1',
        '2026-05-19 tr.19-mayis 1',
        '2026-05-26 tr.kurban-bayrami-arifesi 1',
        '2026-05-27 tr.kurban-bayrami 1',
        '2026-05-28 tr.kurban-bayrami 2',
        '2026-05-29 tr.kurban-bayrami 3',
        '2026-05-30 tr.kurban-bayrami 4',
        '2026-07-15 tr.15-temmuz 1',
        '2026-08-30 tr.30-agustos 1',
        '2026-10-28 tr.cumhuriyet-arifesi 1',
        '2026-10-29 tr.29-ekim 1',
      ]);
      expect(tr.holidaysIn(2026).every((h) => !h.estimated), isTrue);
    });

    test('2026 religious days', () {
      final days = tr.holidaysIn(2026).where((h) => !h.isDayOff);
      expect(days.map((h) => '${h.date} ${h.id}'), [
        '2026-01-15 tr.mirac-kandili',
        '2026-02-02 tr.berat-kandili',
        '2026-02-19 tr.ramazan-baslangici',
        '2026-03-16 tr.kadir-gecesi',
        '2026-06-16 tr.hicri-yilbasi',
        '2026-06-25 tr.asure',
        '2026-08-24 tr.mevlid-kandili',
        '2026-12-10 tr.regaip-kandili',
        '2026-12-10 tr.uc-aylar',
      ]);
      // Religious days are working days.
      expect(tr.isBusinessDay(CivilDate(2026, 8, 24)), isTrue);
    });

    test('15 Temmuz only from 2017', () {
      expect(tr.holidaysIn(2016).any((h) => h.id == 'tr.15-temmuz'), isFalse);
      expect(tr.holidaysIn(2017).any((h) => h.id == 'tr.15-temmuz'), isTrue);
    });

    test('half-days', () {
      final arife = tr.holidaysOn(CivilDate(2026, 3, 19)).single;
      expect(arife.isHalfDay, isTrue);
      expect(arife.startsAt, const Duration(hours: 13));
      expect(tr.isBusinessDay(CivilDate(2026, 3, 19)), isTrue);
      expect(tr.isBusinessDay(CivilDate(2026, 3, 19), halfDayIsOff: true),
          isFalse);
    });

    test('business days skip weekends and Kurban Bayramı', () {
      // Mon 25 May 2026 + 3 business days: 26 (half-day, counts), then
      // 27–30 Bayram, 31 Sunday → Mon 1 June, Tue 2 June.
      expect(
          tr.addBusinessDays(CivilDate(2026, 5, 25), 3), CivilDate(2026, 6, 2));
      expect(tr.addBusinessDays(CivilDate(2026, 6, 2), -3),
          CivilDate(2026, 5, 25));
    });

    test('nextHoliday', () {
      expect(
          tr.nextHoliday(CivilDate(2026, 10, 1))!.id, 'tr.cumhuriyet-arifesi');
      final afterRepublicDay = tr.nextHoliday(CivilDate(2026, 10, 29))!;
      expect(afterRepublicDay.date, CivilDate(2027, 1, 1));
      final any = tr.nextHoliday(CivilDate(2026, 10, 29), dayOffOnly: false)!;
      expect(any.id, 'tr.regaip-kandili');
      expect(any.date, CivilDate(2026, 12, 10));
    });

    test('holidaysBetween crosses the year boundary', () {
      final days =
          tr.holidaysBetween(CivilDate(2026, 12, 1), CivilDate(2027, 1, 10));
      expect(days.map((h) => '${h.date} ${h.id}'), [
        '2026-12-10 tr.regaip-kandili',
        '2026-12-10 tr.uc-aylar',
        '2027-01-01 tr.yilbasi',
        '2027-01-04 tr.mirac-kandili',
      ]);
    });

    test('names and unknown countries', () {
      final bayram = tr.holidaysOn(CivilDate(2026, 3, 20)).single;
      expect(bayram.name('tr'), 'Ramazan Bayramı');
      expect(bayram.name(), 'Eid al-Fitr');
      expect(bayram.name('de'), 'Eid al-Fitr');
      expect(bayram.toString(), '2026-03-20 Eid al-Fitr (day 1/3)');
      expect(Holidays.countries, contains('TR'));
      expect(() => Holidays.of('ZZ'), throwsArgumentError);
    });
  });

  group('Islamic calendars', () {
    test('a 29-day month has no day 30', () {
      // Rebiülevvel 1438 has 29 days, Muharrem 1438 has 30.
      expect(turkeyDiyanetCalendar.resolve(1438, 3, 29)!.date,
          CivilDate(2016, 12, 29));
      expect(turkeyDiyanetCalendar.resolve(1438, 3, 30), isNull);
      expect(turkeyDiyanetCalendar.resolve(1438, 1, 30)!.date,
          CivilDate(2016, 10, 31));
      expect(ummAlQuraCalendar.resolve(1447, 12, 29)!.date,
          CivilDate(2026, 6, 15));
      expect(ummAlQuraCalendar.resolve(1447, 12, 30), isNull);
    });

    test('invalid months and days give null', () {
      expect(turkeyDiyanetCalendar.resolve(1447, 0, 1), isNull);
      expect(turkeyDiyanetCalendar.resolve(1447, 13, 1), isNull);
      expect(turkeyDiyanetCalendar.resolve(1447, 1, 0), isNull);
      expect(turkeyDiyanetCalendar.resolve(1447, 1, 31), isNull);
    });

    test('outside a table the tabular calendar is used, as an estimate', () {
      final before = turkeyDiyanetCalendar.resolve(1437, 12, 10)!;
      expect(before.estimated, isTrue);
      final after = turkeyDiyanetCalendar.resolve(1481, 1, 1)!;
      expect(after.date, CivilDate(2058, 6, 23));
      expect(after.estimated, isTrue);
      expect(ummAlQuraCalendar.resolve(1501, 1, 1)!.estimated, isTrue);
    });

    test('Umm al-Qura table', () {
      expect(
          ummAlQuraCalendar.resolve(1365, 1, 1)!.date, CivilDate(1945, 12, 5));
      expect(
          ummAlQuraCalendar.resolve(1447, 10, 1)!.date, CivilDate(2026, 3, 20));
      expect(ummAlQuraCalendar.resolve(1500, 12, 29)!.date,
          CivilDate(2077, 11, 15));
      expect(ummAlQuraCalendar.resolve(1447, 9, 1)!.estimated, isFalse);
    });

    test('tabular Islamic calendar epoch', () {
      final r = const TabularIslamicCalendar().resolve(1, 1, 1)!;
      expect(r.date.epochDay + 2440588, 1948440); // JDN, 16 July 622 (Julian)
    });
  });

  group('engine', () {
    final demo = HolidayCalendar(_demo);

    test('multi-day holidays continue into the next year', () {
      final days = demo.holidaysIn(2027).where((h) => h.id == 'xx.year-end');
      expect(days.map((h) => '${h.date} ${h.dayNumber}'), [
        '2027-01-01 2',
        '2027-01-02 3',
        '2027-12-31 1',
      ]);
    });

    test('29 February only exists in leap years', () {
      expect(demo.holidaysIn(2027).any((h) => h.id == 'xx.leap'), isFalse);
      expect(demo.holidaysOn(CivilDate(2028, 2, 29)).single.id, 'xx.leap');
    });

    test('substitute days', () {
      // 15 August 2027 is a Sunday, 15 August 2026 a Saturday.
      final sub2027 =
          demo.holidaysIn(2027).where((h) => h.id == 'xx.sub').toList();
      expect(sub2027.map((h) => '${h.date} ${h.isSubstitute}'),
          ['2027-08-15 false', '2027-08-16 true']);
      final sub2026 = demo.holidaysIn(2026).where((h) => h.isSubstitute);
      expect(sub2026.single.date, CivilDate(2026, 8, 17));
      expect(demo.isBusinessDay(CivilDate(2026, 8, 17)), isFalse);
    });

    test('regional holidays need a region', () {
      expect(demo.holidaysIn(2027).any((h) => h.id == 'xx.region'), isFalse);
      final regional = HolidayCalendar(_demo, region: 'XX-A');
      expect(regional.holidaysOn(CivilDate(2027, 6, 1)).single.id, 'xx.region');
    });

    test('Holidays.register adds a country', () {
      Holidays.register(_demo);
      expect(Holidays.of('xx').country.code, 'XX');
    });
  });

  group('rules', () {
    const ctx = RuleContext(islamicCalendar: TabularIslamicCalendar());
    List<CivilDate> in2026(DateRule rule) => [
          for (final r in rule.datesBetween(
              CivilDate(2026, 1, 1), CivilDate(2026, 12, 31), ctx))
            r.date
        ];

    test('NthWeekday', () {
      // Last Monday of May 2026 (US Memorial Day) = 25 May.
      expect(in2026(const NthWeekday(5, DateTime.monday, -1)),
          [CivilDate(2026, 5, 25)]);
      // Fourth Thursday of November 2026 (US Thanksgiving) = 26 November.
      expect(in2026(const NthWeekday(11, DateTime.thursday, 4)),
          [CivilDate(2026, 11, 26)]);
      // There is no fifth Monday in February 2026.
      expect(in2026(const NthWeekday(2, DateTime.monday, 5)), isEmpty);
    });

    test('WeekdayOnOrAfter', () {
      // 10 December 2026 is a Thursday, 11 December a Friday.
      expect(in2026(const WeekdayOnOrAfter(FixedDate(12, 10), DateTime.friday)),
          [CivilDate(2026, 12, 11)]);
      expect(in2026(const WeekdayOnOrAfter(FixedDate(12, 11), DateTime.friday)),
          [CivilDate(2026, 12, 11)]);
    });

    test('Shifted and EasterOffset', () {
      expect(in2026(const Shifted(FixedDate(1, 1), -1)),
          [CivilDate(2026, 12, 31)]);
      expect(in2026(const EasterOffset(-2)), [CivilDate(2026, 4, 3)]);
      expect(in2026(const EasterOffset(1, orthodox: true)),
          [CivilDate(2026, 4, 13)]);
    });

    test('Easter', () {
      expect(gregorianEaster(2025), CivilDate(2025, 4, 20));
      expect(gregorianEaster(2026), CivilDate(2026, 4, 5));
      expect(orthodoxEaster(2026), CivilDate(2026, 4, 12));
    });
  });

  group('CivilDate', () {
    test('epoch day round-trip', () {
      for (var e = -800000; e <= 800000; e += 997) {
        expect(CivilDate.fromEpochDay(e).epochDay, e);
      }
      expect(CivilDate(1970, 1, 1).epochDay, 0);
      expect(CivilDate(1970, 1, 1).weekday, DateTime.thursday);
      expect(CivilDate(2026, 10, 1).weekday, DateTime.thursday);
    });

    test('arithmetic and comparison', () {
      final a = CivilDate(2024, 2, 28);
      expect(a.addDays(2), CivilDate(2024, 3, 1));
      expect(a.addDays(-59), CivilDate(2023, 12, 31));
      expect(a.daysUntil(CivilDate(2025, 2, 28)), 366);
      expect(a.isBefore(a.addDays(1)), isTrue);
      expect(a.isAfter(a.addDays(1)), isFalse);
      expect(a.compareTo(CivilDate(2024, 2, 28)), 0);
      expect(a.hashCode, CivilDate(2024, 2, 28).hashCode);
      expect(a.toString(), '2024-02-28');
      expect(a.toDateTimeUtc(), DateTime.utc(2024, 2, 28));
      expect(CivilDate.fromDateTime(DateTime(2024, 2, 28, 23, 59)), a);
    });

    test('validity and parsing', () {
      expect(CivilDate.daysInMonth(2024, 2), 29);
      expect(CivilDate.daysInMonth(2100, 2), 28);
      expect(CivilDate.daysInMonth(2000, 2), 29);
      expect(CivilDate(2026, 2, 29).isValid, isFalse);
      expect(CivilDate(2026, 13, 1).isValid, isFalse);
      expect(CivilDate.parse('2026-03-20'), CivilDate(2026, 3, 20));
      expect(() => CivilDate.parse('2026-02-30'), throwsFormatException);
      expect(() => CivilDate.parse('20 March'), throwsFormatException);
    });
  });
}

/// A made-up country that exercises the parts Türkiye does not use.
final _demo = CountryDefinition(
  code: 'XX',
  names: const {'en': 'Demo'},
  weekend: const {DateTime.saturday, DateTime.sunday},
  timeZone: 'UTC',
  islamicCalendar: const TabularIslamicCalendar(),
  rules: const [
    HolidayRule(
      id: 'xx.year-end',
      names: {'en': 'Year End'},
      date: FixedDate(12, 31),
      days: 3,
    ),
    HolidayRule(
      id: 'xx.leap',
      names: {'en': 'Leap Day'},
      date: FixedDate(2, 29),
    ),
    HolidayRule(
      id: 'xx.sub',
      names: {'en': 'Substituted'},
      date: FixedDate(8, 15),
      substitute: SubstitutePolicy.nextWorkday,
    ),
    HolidayRule(
      id: 'xx.region',
      names: {'en': 'Regional'},
      date: FixedDate(6, 1),
      regions: {'XX-A'},
    ),
  ],
);
