import '../calendars/islamic.dart';
import '../holiday.dart';
import '../holiday_calendar.dart';
import '../rules.dart';

const _afternoon = Duration(hours: 13); // Half-days start at 13:00.

/// Türkiye — Law No. 2429 on National and General Holidays (Ulusal Bayram
/// ve Genel Tatiller Hakkında Kanun).
/// Islamic dates follow Diyanet's calendar (2016 Unified Hijri Calendar).
///
/// Kandil nights are listed, as Diyanet does, on the day whose evening they
/// begin: Miraç is the night of 27 Recep, so its date is 26 Recep.
final CountryDefinition turkey = CountryDefinition(
  code: 'TR',
  names: const {'tr': 'Türkiye', 'en': 'Türkiye'},
  weekend: const {DateTime.saturday, DateTime.sunday},
  timeZone: 'Europe/Istanbul',
  islamicCalendar: turkeyDiyanetCalendar,
  rules: const [
    HolidayRule(
      id: 'tr.yilbasi',
      names: {'tr': 'Yılbaşı', 'en': "New Year's Day"},
      date: FixedDate(1, 1),
    ),
    HolidayRule(
      id: 'tr.23-nisan',
      names: {
        'tr': 'Ulusal Egemenlik ve Çocuk Bayramı',
        'en': "National Sovereignty and Children's Day",
      },
      date: FixedDate(4, 23),
    ),
    HolidayRule(
      id: 'tr.1-mayis',
      names: {
        'tr': 'Emek ve Dayanışma Günü',
        'en': 'Labour and Solidarity Day',
      },
      date: FixedDate(5, 1),
      since: 2009,
    ),
    HolidayRule(
      id: 'tr.19-mayis',
      names: {
        'tr': "Atatürk'ü Anma, Gençlik ve Spor Bayramı",
        'en': 'Commemoration of Atatürk, Youth and Sports Day',
      },
      date: FixedDate(5, 19),
    ),
    HolidayRule(
      id: 'tr.15-temmuz',
      names: {
        'tr': 'Demokrasi ve Millî Birlik Günü',
        'en': 'Democracy and National Unity Day',
      },
      date: FixedDate(7, 15),
      since: 2017, // Added by Law 6752 in 2016; first observed in 2017.
    ),
    HolidayRule(
      id: 'tr.30-agustos',
      names: {'tr': 'Zafer Bayramı', 'en': 'Victory Day'},
      date: FixedDate(8, 30),
    ),
    HolidayRule(
      id: 'tr.cumhuriyet-arifesi',
      names: {'tr': 'Cumhuriyet Bayramı Arifesi', 'en': 'Republic Day Eve'},
      date: FixedDate(10, 28),
      startsAt: _afternoon,
    ),
    HolidayRule(
      id: 'tr.29-ekim',
      names: {'tr': 'Cumhuriyet Bayramı', 'en': 'Republic Day'},
      date: FixedDate(10, 29),
    ),
    HolidayRule(
      id: 'tr.ramazan-bayrami-arifesi',
      names: {'tr': 'Ramazan Bayramı Arifesi', 'en': 'Eid al-Fitr Eve'},
      date: Shifted(HijriDate(10, 1), -1),
      startsAt: _afternoon,
    ),
    HolidayRule(
      id: 'tr.ramazan-bayrami',
      names: {'tr': 'Ramazan Bayramı', 'en': 'Eid al-Fitr'},
      date: HijriDate(10, 1),
      days: 3,
    ),
    HolidayRule(
      id: 'tr.kurban-bayrami-arifesi',
      names: {'tr': 'Kurban Bayramı Arifesi', 'en': 'Eid al-Adha Eve'},
      date: HijriDate(12, 9),
      startsAt: _afternoon,
    ),
    HolidayRule(
      id: 'tr.kurban-bayrami',
      names: {'tr': 'Kurban Bayramı', 'en': 'Eid al-Adha'},
      date: HijriDate(12, 10),
      days: 4,
    ),

    // Religious days: commemorated, but normal working days.
    HolidayRule(
      id: 'tr.hicri-yilbasi',
      names: {'tr': 'Hicri Yılbaşı', 'en': 'Islamic New Year'},
      date: HijriDate(1, 1),
      type: HolidayType.observance,
    ),
    HolidayRule(
      id: 'tr.asure',
      names: {'tr': 'Aşure Günü', 'en': 'Day of Ashura'},
      date: HijriDate(1, 10),
      type: HolidayType.observance,
    ),
    HolidayRule(
      id: 'tr.mevlid-kandili',
      names: {'tr': 'Mevlid Kandili', 'en': 'Mawlid (Mevlid Kandili)'},
      date: HijriDate(3, 11),
      type: HolidayType.observance,
    ),
    HolidayRule(
      id: 'tr.uc-aylar',
      names: {
        'tr': 'Üç Ayların Başlangıcı',
        'en': 'Start of the Three Holy Months',
      },
      date: HijriDate(7, 1),
      type: HolidayType.observance,
    ),
    HolidayRule(
      id: 'tr.regaip-kandili',
      names: {'tr': 'Regaip Kandili', 'en': 'Laylat al-Raghaib'},
      // The night before the first Friday of Recep. When 1 Recep is itself
      // a Friday, that is the evening before Recep begins.
      date: Shifted(WeekdayOnOrAfter(HijriDate(7, 1), DateTime.friday), -1),
      type: HolidayType.observance,
    ),
    HolidayRule(
      id: 'tr.mirac-kandili',
      names: {'tr': 'Miraç Kandili', 'en': "Isra and Mi'raj"},
      date: HijriDate(7, 26),
      type: HolidayType.observance,
    ),
    HolidayRule(
      id: 'tr.berat-kandili',
      names: {'tr': 'Berat Kandili', 'en': "Mid-Sha'ban (Berat Kandili)"},
      date: HijriDate(8, 14),
      type: HolidayType.observance,
    ),
    HolidayRule(
      id: 'tr.ramazan-baslangici',
      names: {'tr': 'Ramazan Başlangıcı', 'en': 'First day of Ramadan'},
      date: HijriDate(9, 1),
      type: HolidayType.observance,
    ),
    HolidayRule(
      id: 'tr.kadir-gecesi',
      names: {'tr': 'Kadir Gecesi', 'en': 'Laylat al-Qadr'},
      date: HijriDate(9, 26),
      type: HolidayType.observance,
    ),
  ],
);
