import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebScreen extends StatelessWidget {
  WebScreen({@required this.title, @required this.url});
  final String title, url;
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
                  title,
                  style: Theme.of(context).textTheme.headline4.copyWith(
                        fontSize: 20,
                        color: Theme.of(context).primaryColor,
                      ),
                )
              ],
            ),
            Container(
              height: MediaQuery.of(context).size.height - 140,
              child: WebView(
                debuggingEnabled: false,
                initialUrl: url,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
