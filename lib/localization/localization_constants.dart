import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:optisend/localization/demo_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

String t(BuildContext context, String key) {
  return DemoLocalization.of(context).getTranslatedValue(key);
}

//language Codec

const String ENGLISH = 'en';
const String RUSSIAN = 'ru';

//language code
const String LANGUAGE_CODE = 'languageCode';

Future<Locale> setLocale(String languageCode) async{
  SharedPreferences _prefs = await SharedPreferences.getInstance();

  await _prefs.setString(LANGUAGE_CODE, languageCode);

  await _locale(languageCode);

}

Locale _locale(String languageCode){
  Locale _temp;
  switch (language.languageCode) {
    case ENGLISH:
      _temp = Locale(language.languageCode, 'US');
      break;
    case RUSSIAN:
      _temp = Locale(language.languageCode, 'RU');
      break;
    default:
      _temp = Locale(ENGLISH, 'US');
  }
}