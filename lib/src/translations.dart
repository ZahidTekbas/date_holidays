/// Holiday names added at run time: language → holiday id → name.
final Map<String, Map<String, String>> _addedNames = {};

/// Language tags to try for [language], most specific first.
///
/// Tags are compared in lower case with `-` as the separator, so `tr_TR`,
/// `tr-TR` and `tr` all find names stored under `tr`:
/// `zh_Hant_TW` → `zh-hant-tw`, `zh-hant`, `zh`.
List<String> languageCandidates(String language) {
  var tag = language.trim().toLowerCase().replaceAll('_', '-');
  final candidates = <String>[];
  while (tag.isNotEmpty) {
    candidates.add(tag);
    final cut = tag.lastIndexOf('-');
    if (cut < 0) break;
    tag = tag.substring(0, cut);
  }
  return candidates;
}

/// Stores [names] (holiday id → name) for [language].
void addHolidayNames(String language, Map<String, String> names) {
  final candidates = languageCandidates(language);
  if (candidates.isEmpty) {
    throw ArgumentError.value(language, 'language', 'must not be empty');
  }
  _addedNames.putIfAbsent(candidates.first, () => {}).addAll(names);
}

/// The name for [language] or one of its parent tags, without falling back
/// to another language. Names added at run time win over [builtIn] names.
String? lookUpName(String? id, Map<String, String> builtIn, String language) {
  for (final tag in languageCandidates(language)) {
    final name = (id == null ? null : _addedNames[tag]?[id]) ?? builtIn[tag];
    if (name != null) return name;
  }
  return null;
}
