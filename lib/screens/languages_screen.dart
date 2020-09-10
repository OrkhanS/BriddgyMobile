import 'package:briddgy/localization/localization_constants.dart';
import 'package:briddgy/models/language.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:briddgy/main.dart';
import 'package:briddgy/models/language.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class LanguageScreen extends StatefulWidget {
  @override
  _LanguageScreenState createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  _changeLanguage(Language language) async {
    Locale _temp = await setLocale(language.languageCode);
    MyApp.setLocale(context, _temp);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.chevron_left),
                  color: Theme.of(context).primaryColor,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                Text(
                  t(context, "change_language"),
                  style: Theme.of(context).textTheme.headline4.copyWith(
                        fontSize: 20,
                        color: Theme.of(context).primaryColor,
                      ),
                )
              ],
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.8,
              child: ListView(
                children: [
                  for (var x in Language.languageList())
                    ListTile(
                      title: Text(x.name),
                      leading: Text(x.flag),
                      onTap: () {
                        _changeLanguage(x);
                        Navigator.pop(context);
                        Flushbar(
                          flushbarStyle: FlushbarStyle.GROUNDED,
                          titleText: Text(
                            "Warning",
                            style: TextStyle(color: Colors.black, fontSize: 22),
                          ),
                          messageText: Text(
                            "You need to Log in to add Item!",
                            style: TextStyle(color: Colors.black),
                          ),
                          icon: Icon(MdiIcons.login),
                          backgroundColor: Colors.white,
                          borderColor: Theme.of(context).primaryColor,
                          padding: const EdgeInsets.all(10),
                          margin: EdgeInsets.only(left: 20, right: 20, bottom: 120),
                          borderRadius: 10,
                          duration: Duration(seconds: 5),
                        )..show(context);
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
