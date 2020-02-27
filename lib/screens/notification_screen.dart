import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './auth_screen.dart';
import '../providers/auth.dart';
import 'splash_screen.dart';

class NotificationScreen extends StatelessWidget {
  Widget notif() {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
      leading: Icon(Icons.notifications),
      trailing: SizedBox(
        width: 50,
        child: Image.network(
          'https://images-na.ssl-images-amazon.com/images/I/81NIli1PuqL._AC_SL1500_.jpg',
          fit: BoxFit.cover,
          loadingBuilder: (BuildContext context, Widget child,
              ImageChunkEvent loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes
                    : null,
              ),
            );
          },
        ),
      ),
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
