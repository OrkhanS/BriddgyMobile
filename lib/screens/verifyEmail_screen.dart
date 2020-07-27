import 'package:flutter/material.dart';

class VerifyEmailScreen extends StatelessWidget {
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
                "Verify Email",
                style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
              ),
              elevation: 1,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 30.0),
              child: Text(
                "We'll help you recover your password and access your account, no worries.",
                style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w100),
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
                  } else
                    return null;
                },
                onSaved: (value) {
                  //Todo orxan
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
              onPressed: () {}, //todo orxan
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
