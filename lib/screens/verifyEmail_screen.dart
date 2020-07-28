import 'package:flutter/material.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'package:pinput/pin_put/pin_put_state.dart';

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
              padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 30.0),
              child: Text(
                "Verify your email",
                style: TextStyle(fontSize: 30, color: Theme.of(context).primaryColor, fontWeight: FontWeight.w600),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 5.0),
              child: Text(
                "Please enter the 4 digit code sent to your email address",
                style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w100),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 30),
              padding: EdgeInsets.all(20),
              child: PinPut(
                fieldsCount: 5,
                onSubmit: (String pin) => _showSnackBar(pin, context),
                focusNode: _pinPutFocusNode,
                controller: _pinPutController,
                submittedFieldDecoration: _pinPutDecoration.copyWith(borderRadius: BorderRadius.circular(20)),
                selectedFieldDecoration: _pinPutDecoration,
                followingFieldDecoration: _pinPutDecoration.copyWith(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: Colors.deepPurpleAccent.withOpacity(0.5),
                  ),
                ),
              ),
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
//                  //Todo orxan
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
    Scaffold.of(context).hideCurrentSnackBar();
    Scaffold.of(context).showSnackBar(snackBar);
  }
}
