import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './auth_screen.dart';
import '../providers/auth.dart';
import 'splash_screen.dart';

class NotificationScreen extends StatelessWidget {
  Widget notif() {
    return ListTile(
      leading: Icon(Icons.notifications),
      trailing: Image.network(
          'https://images-na.ssl-images-amazon.com/images/I/81NIli1PuqL._AC_SL1500_.jpg'),
      title: Text("Notifying you about something somewhere"),
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
              style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold),
            ),
          ),
          elevation: 1,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[for (var i = 0; i < 25; i++) notif()],
          ),
        ));
  }
}
