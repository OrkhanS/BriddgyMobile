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
      body: SafeArea(
        child: ListView.builder(
          itemCount: 20,
          itemBuilder: (context, int i) {
            return notif();
          },
        ),
      ),
    );
  }
}
