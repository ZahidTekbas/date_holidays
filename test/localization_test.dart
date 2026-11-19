import 'package:date_holidays/date_holidays.dart';
import 'package:test/test.dart';

void main() {
  final tr = Holidays.of('TR');
  final bayram = tr.holidaysOn(CivilDate(2026, 3, 20)).single;
  final republicDay = tr.holidaysOn(CivilDate(2026, 10, 29)).single;

  test('built-in names', () {
    expect(bayram.name('tr'), 'Ramazan Bayramı');
    expect(bayram.name('en'), 'Eid al-Fitr');
    expect(bayram.name(), 'Eid al-Fitr');
  });

  test('region and script subtags are ignored when needed', () {
    expect(bayram.name('tr_TR'), 'Ramazan Bayramı');
    expect(bayram.name('tr-TR'), 'Ramazan Bayramı');
    expect(bayram.name('TR'), 'Ramazan Bayramı');
    expect(bayram.name('en-US'), 'Eid al-Fitr');
    expect(bayram.name(' tr_Latn_TR '), 'Ramazan Bayramı');
  });

  test('unknown languages fall back to English', () {
    expect(bayram.name('ja'), 'Eid al-Fitr');
    expect(bayram.name(''), 'Eid al-Fitr');
    expect(bayram.localizedName('ja'), isNull);
    expect(bayram.localizedName('tr_TR'), 'Ramazan Bayramı');
  });

  test('addTranslations adds a language', () {
    Holidays.addTranslations('de', {'tr.ramazan-bayrami': 'Zuckerfest'});
    expect(bayram.name('de'), 'Zuckerfest');
    expect(bayram.name('de_AT'), 'Zuckerfest');
    expect(bayram.localizedName('de'), 'Zuckerfest');
    // Holidays without a German name still fall back to English.
    expect(republicDay.name('de'), 'Republic Day');
    expect(republicDay.localizedName('de'), isNull);
  });

  test('a regional translation wins over the base language', () {
    Holidays.addTranslations('pt', {'tr.29-ekim': 'Dia da República'});
    Holidays.addTranslations('pt_BR', {'tr.29-ekim': 'Dia da República (BR)'});
    expect(republicDay.name('pt-BR'), 'Dia da República (BR)');
    expect(republicDay.name('pt_PT'), 'Dia da República');
    expect(republicDay.name('pt'), 'Dia da República');
  });

  test('added names win over built-in ones and can be extended', () {
    Holidays.addTranslations('fr', {'tr.29-ekim': 'Fête de la République'});
    Holidays.addTranslations('fr', {'tr.ramazan-bayrami': 'Aïd el-Fitr'});
    expect(republicDay.name('fr'), 'Fête de la République');
    expect(bayram.name('fr'), 'Aïd el-Fitr');

    final ashura = tr.holidaysOn(CivilDate(2026, 6, 25)).single;
    expect(ashura.name('en'), 'Day of Ashura');
    Holidays.addTranslations('en', {'tr.asure': 'Ashura'});
    expect(ashura.name('en'), 'Ashura');
    expect(ashura.name('nl'), 'Ashura');
    expect(ashura.name('tr'), 'Aşure Günü');
  });

  test('an empty language tag is rejected', () {
    expect(() => Holidays.addTranslations('', {}), throwsArgumentError);
  });

  test('country names', () {
    expect(tr.country.name(), 'Türkiye');
    expect(tr.country.name('tr_TR'), 'Türkiye');
    expect(tr.country.name('ja'), 'Türkiye');
  });
}
