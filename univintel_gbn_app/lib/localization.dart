import 'package:flutter/material.dart';
import 'package:univintel_gbn_app/services/api.dart';

class UnivIntelLocale {
  UnivIntelLocale(Locale defaultLocale) {
    locale = defaultLocale;
    //TODO: read locale from settings?????
  }

  Locale locale;

  static Map<String, Map<String, String>> _localizedValues = {
    'en': {
    },
    'ru': {
    }
  };

  static addLocale(String key, String english, String russian){
    _localizedValues['en'].putIfAbsent(key, () => english);
    _localizedValues['ru'].putIfAbsent(key, () => russian);
  }

  String translate(key) {
    var value = _localizedValues[locale.languageCode][key];
    return value == null ? key : value;
  }

  void changeLocale(Locale newLocale) {
    locale = newLocale;
  }

  static String of(BuildContext context, String key) {
    return Localizations.of<UnivIntelLocale>(context,  UnivIntelLocale).translate(key);
  }

  static void changeApplicationLocale(BuildContext context, Locale locale) {
    Localizations.of<UnivIntelLocale>(context,  UnivIntelLocale).changeLocale(locale);
  }

}

class UnivIntelLocaleDelegate extends 
  LocalizationsDelegate<UnivIntelLocale> {
  
  const UnivIntelLocaleDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ru'].contains(locale.languageCode);

  @override
  Future<UnivIntelLocale> load(Locale locale) async {
    final ApiService apiService = new ApiService();
    var result = await apiService.getWithoutSession("api/1/localization/all");
    for (var item in result) {
      UnivIntelLocale.addLocale(item['key'], item['english'], item['russian']);
    }

    return UnivIntelLocale(locale);
  }

  @override
  bool shouldReload(UnivIntelLocaleDelegate old) => false;  
}