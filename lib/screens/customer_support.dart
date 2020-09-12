import 'dart:convert';
import 'dart:io';

import 'package:briddgy/models/api.dart';
import 'package:briddgy/providers/auth.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:briddgy/localization/localization_constants.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

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
                onChanged: (String val) {
                  title = val;
                },
              ),
            ),
            Container(
              width: deviceWidth * 0.8,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: 300.0,
                ),
                child: TextField(
                  maxLines: null,
                  decoration: InputDecoration(
                    labelText: t(context, 'description'),
                    icon: Icon(MdiIcons.informationOutline),
                  ),
                  onChanged: (String val) {
                    description = val;
                  },
                ),
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
                    description = "Subject:" + title + "<br>Content:" +description;
                    final url = Api.customerSupport;
                    http.post(
                      url,
                      headers: {
                          HttpHeaders.contentTypeHeader: "application/json",
                      },
                      body: json.encode({
                          "content": description,
                          "email": Provider.of<Auth>(context,listen: false).user.email,
                        })
                      
                    );
                    Navigator.pop(context);
                    Flushbar(
                      flushbarStyle: FlushbarStyle.GROUNDED,
                      titleText: Text(
                        "Success",
                        style: TextStyle(color: Colors.black, fontSize: 22),
                      ),
                      messageText: Text(
                        "Your message has been sent!",
                        style: TextStyle(color: Colors.black),
                      ),
                      icon: Icon(MdiIcons.login),
                      backgroundColor: Colors.white,
                      borderColor: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.all(10),
                      margin: EdgeInsets.only(left: 20, right: 20, bottom: 80),
                      borderRadius: 10,
                      duration: Duration(seconds: 2),
                    )..show(context);

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
