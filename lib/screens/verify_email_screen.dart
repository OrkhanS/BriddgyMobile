import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:optisend/providers/auth.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'package:pinput/pin_put/pin_put_state.dart';
import 'package:provider/provider.dart';
import 'package:argon_buttons_flutter/argon_buttons_flutter.dart';

class VerifyEmailScreen extends StatefulWidget {
  @override
  _VerifyEmailScreenState createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final TextEditingController _pinPutController = TextEditingController();
  final FocusNode _pinPutFocusNode = FocusNode();

  BoxDecoration get _pinPutDecoration {
    return BoxDecoration(
      border: Border.all(color: Colors.deepPurpleAccent),
      borderRadius: BorderRadius.circular(15),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 50.0, vertical: 30.0),
              child: Text(
                "Verify your email",
                style: TextStyle(
                    fontSize: 30,
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w600),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 50.0, vertical: 5.0),
              child: Text(
                "Please enter the 5 digit code sent to your email address",
                style: TextStyle(
                    color: Colors.black87, fontWeight: FontWeight.w100),
              ),
            ),

            Container(
              margin: EdgeInsets.symmetric(horizontal: 30),
              padding: EdgeInsets.all(20),
              child: PinPut(
                fieldsCount: 4,
                onSubmit: (String pin) {
                  Provider.of<Auth>(context, listen: false)
                      .verifyEmailCode(pin)
                      .whenComplete(() {
                    if (Provider.of<Auth>(context, listen: false)
                        .verificationStatus) {
                          Provider.of<Auth>(context, listen: false).user.isEmailVerified = true;
                      Navigator.pop(context);
                      Flushbar(
                        title: "Success",
                        backgroundColor: Colors.green[800],
                        message: "You are now verified!",
                        padding: const EdgeInsets.all(8),
                        borderRadius: 10,
                        duration: Duration(seconds: 3),
                      )..show(context);
                    } else {
                      Flushbar(
                        title: "Failed",
                        message: "Wrong Verification Code, Try again!",
                        padding: const EdgeInsets.all(8),
                        borderRadius: 10,
                        duration: Duration(seconds: 3),
                      )..show(context);
                    }
                  });
                },
                focusNode: _pinPutFocusNode,
                controller: _pinPutController,
                submittedFieldDecoration: _pinPutDecoration.copyWith(
                    borderRadius: BorderRadius.circular(20)),
                selectedFieldDecoration: _pinPutDecoration,
                followingFieldDecoration: _pinPutDecoration.copyWith(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: Colors.deepPurpleAccent.withOpacity(0.5),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 50,
            ),
            ArgonTimerButton(
              height: 50,
              width: MediaQuery.of(context).size.width * 0.45,
              onTap: (startTimer, btnState) {
                if (btnState == ButtonState.Idle) {
                  Provider.of<Auth>(context, listen: false)
                      .requestEmailVerification();
                  startTimer(29);
                }
              },
              child: Text(
                "Resend Code",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700),
              ),
              loader: (timeLeft) {
                return Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(50)),
                  margin: EdgeInsets.all(5),
                  alignment: Alignment.center,
                  width: 40,
                  height: 40,
                  child: Text(
                    "$timeLeft",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                );
              },
              borderRadius: 5.0,
              color: Color(0xFF7866FE),
            ),
//            Padding(
//              padding: const EdgeInsets.symmetric(horizontal: 30.0),
//              child: TextFormField(
//                decoration: InputDecoration(
//                  labelText: 'Email',
//                  icon: Icon(Icons.alternate_email),
//                ),
//                keyboardType: TextInputType.emailAddress,
//                validator: (value) {
//                  if (value.isEmpty || !value.contains('@')) {
//                    return 'Invalid email!';
//                  } else
//                    return null;
//                },
//                onSaved: (value) {
//                  
//                },
//              ),
//            ),
            Expanded(
              child: SizedBox(),
            ),

            SizedBox(
              height: 40,
            ),
          ],
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
    // Scaffold.of(context).hideCurrentSnackBar();
    // Scaffold.of(context).showSnackBar(snackBar);
  }
}
