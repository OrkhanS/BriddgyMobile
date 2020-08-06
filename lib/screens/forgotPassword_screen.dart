import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:optisend/providers/auth.dart';
import 'package:provider/provider.dart';

class ForgotPasswordScreen extends StatelessWidget {
  String email;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            AppBar(
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
                "Forgot Password",
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold),
              ),
              elevation: 1,
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 50.0, vertical: 30.0),
              child: Text(
                "We'll help you recover your password and access your account, no worries.",
                style: TextStyle(
                    color: Colors.black87, fontWeight: FontWeight.w100),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'Email',
                  icon: Icon(Icons.alternate_email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value.isEmpty || !value.contains('@')) {
                    return 'Invalid email!';
                  } else {
                    email = value;
                  }
                },
                onSaved: (String value) {
                  email = value;
                },
                onChanged: (String val) {
                  email = val;
                },
              ),
            ),
            Expanded(
              child: SizedBox(),
            ),
            RaisedButton(
              child: Text(
                'Send Password Recovery',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Provider.of<Auth>(context, listen: false)
                    .requestPasswordReset(email)
                    .whenComplete(() {
                  if (Provider.of<Auth>(context, listen: false)
                      .passwordResetStatus) {
                    Provider.of<Auth>(context, listen: false)
                        .passwordResetStatus = false;
                    Navigator.pop(context);
                    Flushbar(
                      title: "Success",
                      message: "Instructions has been sent to your Email!",
                      padding: const EdgeInsets.all(8),
                      borderRadius: 10,
                      duration: Duration(seconds: 3),
                    )..show(context);
                  } else {
                    Flushbar(
                      title: "Failed",
                      message: "Please check the email you have provided!",
                      padding: const EdgeInsets.all(8),
                      borderRadius: 10,
                      duration: Duration(seconds: 3),
                    )..show(context);
                  }
                });
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15.0),
              color: Theme.of(context).primaryColor,
              textColor: Theme.of(context).primaryTextTheme.button.color,
            ),
            SizedBox(
              height: 40,
            ),
          ],
        ),
      ),
    );
  }
}
