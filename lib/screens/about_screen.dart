import 'package:briddgy/localization/localization_constants.dart';
import 'package:briddgy/models/language.dart';
import 'package:briddgy/screens/web_screen.dart';
import 'package:flutter/material.dart';
import 'package:briddgy/main.dart';

class AboutScreen extends StatefulWidget {
  @override
  _AboutScreenState createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
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
                  t(context, "about"),
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
                  ListTile(
                    title: Text(t(context, "terms")),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (__) => WebScreen(
                              title: t(context, "terms"),
                              url: 'https://briddgy.com/terms',
                            ),
                          ));
                    },
                  ),
                  ListTile(
                    title: Text(t(context, "privacy")),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (__) => WebScreen(
                              title: t(context, "privacy"),
                              url: 'https://briddgy.com/privacy',
                            ),
                          ));
                    },
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
