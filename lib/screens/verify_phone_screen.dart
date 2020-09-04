import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:optisend/localization/localization_constants.dart';
import 'package:optisend/models/api.dart';
import 'package:optisend/providers/auth.dart';
import 'package:optisend/widgets/progress_indicator_widget.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'package:pinput/pin_put/pin_put_state.dart';
import 'package:provider/provider.dart';
import 'package:argon_buttons_flutter/argon_buttons_flutter.dart';

class VerifyPhoneScreen extends StatefulWidget {
  @override
  _VerifyPhoneScreenState createState() => _VerifyPhoneScreenState();
}

class _VerifyPhoneScreenState extends State<VerifyPhoneScreen> {
  final TextEditingController _pinPutController = TextEditingController();
  final FocusNode _pinPutFocusNode = FocusNode();
  bool missCallmeButton = true;
  String phone;

  BoxDecoration get _pinPutDecoration {
    return BoxDecoration(
      border: Border.all(color: Colors.deepPurpleAccent),
      borderRadius: BorderRadius.circular(15),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: missCallmeButton
          ? RaisedButton(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    t(context, 'next'),
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  Icon(
                    Icons.navigate_next,
                    size: 24,
                  ),
                ],
              ),
              onPressed: () {
                if (phone == null) {
                  setState(() {
                    missCallmeButton = true;
                  });
                  Flushbar(
                    title: "${t(context, 'warning')}!",
                    message: t(context, 'fill_field'),
                    padding: const EdgeInsets.all(8),
                    borderRadius: 10,
                    duration: Duration(seconds: 3),
                  )..show(context);
                } else {
                  setState(() {
                    missCallmeButton = false;
                  });
                  var token = Provider.of<Auth>(context, listen: false).token;
                  String url = Api.requestPhoneVerification;
                  http
                      .post(url,
                          headers: {
                            HttpHeaders.contentTypeHeader: "application/json",
                            "Authorization": "Token " + token,
                          },
                          body: json.encode({
                            "phone": phone,
                          }))
                      .then((response) {
                    if (response.statusCode == 200) {
                      setState(() {
                        missCallmeButton = true;
                      });
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (__) => VerifyPhoneNextScreen()),
                      );
                    } else {
                      setState(() {
                        missCallmeButton = true;
                      });
                      Flushbar(
                        title: t(context, 'error'),
                        message: t(context, 'please_try_again'),
                        padding: const EdgeInsets.all(8),
                        borderRadius: 10,
                        duration: Duration(seconds: 3),
                      )..show(context);
                    }
                  });
                }
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10.0),
              color: Colors.green,
              textColor: Theme.of(context).primaryTextTheme.button.color,
            )
          : ProgressIndicatorWidget(show: true),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30.0),
                  child: Text(
                    t(context, 'verify_phone'),
                    style: TextStyle(fontSize: 30, color: Theme.of(context).primaryColor, fontWeight: FontWeight.w600),
                  ),
                ),
                Center(
                    child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      Container(
                        height: 200,
                        padding: EdgeInsets.all(10),
                        child: SvgPicture.asset(
                          "assets/photos/two_factor.svg",
                        ),
                      ),
                    ],
                  ),
                )),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.grey[400],
                      ),
                    ),
                    child: Column(
                      children: [
                        IntlPhoneField(
                          autoValidate: true,
                          decoration: InputDecoration(
                            labelText: t(context, 'phone_number'),

//                            border: InputBorder.,
                          ),
                          initialCountryCode: 'AZ',
                          onChanged: (value) {
                            phone = value.completeNumber.toString();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 5.0),
                  child: Text(
                    t(context, 'phone_enter_prompt'),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w300, fontSize: 20),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSnackBar(String pin, BuildContext context) {
    final snackBar = SnackBar(
      duration: Duration(seconds: 3),
      content: Container(
          height: 80.0,
          child: Center(
            child: Text(
              'Pin Submitted. Value: $pin',
              style: TextStyle(fontSize: 25.0),
            ),
          )),
      backgroundColor: Colors.deepPurpleAccent,
    );
  }
}

class VerifyPhoneNextScreen extends StatefulWidget {
  @override
  _VerifyPhoneNextScreenState createState() => _VerifyPhoneNextScreenState();
}

class _VerifyPhoneNextScreenState extends State<VerifyPhoneNextScreen> {
  final TextEditingController _pinPutController = TextEditingController();
  final FocusNode _pinPutFocusNode = FocusNode();
  bool verifymeButton = true;
  String number;
  BoxDecoration get _pinPutDecoration {
    return BoxDecoration(
      border: Border.all(color: Colors.deepPurpleAccent),
      borderRadius: BorderRadius.circular(15),
    );
  }

  Future verifyMe(pin) async {
    if (pin == null) {
      setState(() {
        verifymeButton = true;
      });
      Flushbar(
        title: "${t(context, 'warning')}!",
        message: t(context, 'fill_field'),
        padding: const EdgeInsets.all(8),
        borderRadius: 10,
        duration: Duration(seconds: 3),
      )..show(context);
    } else {
      setState(() {
        verifymeButton = false;
      });
      var token = Provider.of<Auth>(context, listen: false).token;
      String url = Api.verifyPhone;
      http
          .post(url,
              headers: {
                HttpHeaders.contentTypeHeader: "application/json",
                "Authorization": "Token " + token,
              },
              body: json.encode({
                "verification_phone": pin,
              }))
          .then((response) {
        if (response.statusCode == 200) {
          Provider.of<Auth>(context, listen: false).user.isNumberVerified = true;
          Navigator.of(context).pop();
          Navigator.of(context).pop();
          Flushbar(
            title: "Success!",
            backgroundColor: Colors.green[800],
            message: "You are now verified.",
            padding: const EdgeInsets.all(8),
            borderRadius: 10,
            duration: Duration(seconds: 3),
          )..show(context);
        } else {
          setState(() {
            verifymeButton = true;
          });
          Flushbar(
            title: t(context, 'error'),
            message: t(context, 'please_try_again'),
            padding: const EdgeInsets.all(8),
            borderRadius: 10,
            duration: Duration(seconds: 3),
          )..show(context);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 30.0),
                child: Text(
                  t(context, 'verify_phone'),
                  style: TextStyle(fontSize: 30, color: Theme.of(context).primaryColor, fontWeight: FontWeight.w600),
                ),
              ),
              Container(
                padding: EdgeInsets.all(30),
                decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).primaryColor,
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(200)),
                child: Icon(
                  Icons.phone,
                  size: 100,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 5.0),
                child: Text(
                  t(context, 'last_digits_complete_prompt'),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.w400, fontSize: 19),
                ),
              ),
              SizedBox(
                height: 50,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "+62-213-118- ",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey[400],
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 1),
                      child: PinPut(
                        fieldsCount: 4,
                        onSubmit: (String pin) {
                          verifyMe(pin);
                        },
                        onChanged: (value) {
                          number = value;
                        },
                        focusNode: _pinPutFocusNode,
                        controller: _pinPutController,
                        submittedFieldDecoration: _pinPutDecoration.copyWith(borderRadius: BorderRadius.circular(20)),
                        selectedFieldDecoration: _pinPutDecoration,
                        followingFieldDecoration: _pinPutDecoration.copyWith(
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: SizedBox(
                  width: 1,
                ),
              ),
              verifymeButton
                  ? RaisedButton.icon(
                      icon: Icon(
                        Icons.phone_in_talk,
                        size: 20,
                      ),
                      label: Text(
                        t(context, 'verify'),
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      onPressed: () {
                        verifyMe(number);
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15.0),
                      color: Theme.of(context).primaryColor,
                      textColor: Theme.of(context).primaryTextTheme.button.color,
                    )
                  : ProgressIndicatorWidget(show: true),
              SizedBox(
                height: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSnackBar(String pin, BuildContext context) {
    final snackBar = SnackBar(
      duration: Duration(seconds: 3),
      content: Container(
          height: 80.0,
          child: Center(
            child: Text(
              'Pin Submitted. Value: $pin',
              style: TextStyle(fontSize: 25.0),
            ),
          )),
      backgroundColor: Colors.deepPurpleAccent,
    );
  }
}
