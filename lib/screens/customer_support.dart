import 'package:flutter/material.dart';
import 'package:briddgy/localization/localization_constants.dart';

class CustomerSupport extends StatefulWidget {
  var user, message;
  CustomerSupport({this.user, this.message});
  @override
  _CustomerSupportState createState() => _CustomerSupportState();
}

class _CustomerSupportState extends State<CustomerSupport> {
  String title;
  String from, to, description;

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          color: Theme.of(context).primaryColor,
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          t(context, 'support'),
          style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
        ),
        elevation: 1,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 30.0, top: 20, bottom: 20),
                  child: Text(
                    t(context, 'fill_the_forms'),
                    style: TextStyle(fontSize: 25, color: Theme.of(context).primaryColor),
                  ),
                ),
              ],
            ),
            Container(
              width: deviceWidth * 0.8,
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: t(context, 'subject'),
                  icon: Icon(Icons.report),
                ),
                keyboardType: TextInputType.text,
                onChanged: (String val) {},
              ),
            ),
            Container(
              width: deviceWidth * 0.8,
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: t(context, 'tell_about_issue'),
                  icon: Icon(Icons.report),
                ),
                keyboardType: TextInputType.text,
                onChanged: (String val) {},
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: RaisedButton(
                  color: Theme.of(context).primaryColor,

                  elevation: 2,
//                            color: Theme.of(context).primaryColor,
                  child: Container(
                    width: deviceWidth * 0.7,
                    child: Center(
                      child: Text(
                        t(context, 'submit'),
                        style: TextStyle(
                          fontSize: 19,
                          color: Colors.white,
//                                  fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
