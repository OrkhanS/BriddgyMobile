import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  Widget notif() {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
      leading: Icon(Icons.notifications),
      title: Text("Notifying you about something some where"),
      subtitle: Text("21:45, 24 April 2020"),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Center(
            child: Text(
              "Notifications",
              style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
            ),
          ),
          elevation: 1,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[for (var i = 0; i < 5; i++) notif()],
          ),
        ));
  }
}
