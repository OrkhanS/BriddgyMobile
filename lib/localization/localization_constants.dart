import 'package:flutter/cupertino.dart';
import 'package:optisend/localization/demo_localization.dart';

String t(BuildContext context, String key) {
  return DemoLocalization.of(context).getTranslatedValue(key);
}
