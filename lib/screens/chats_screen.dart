import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './auth_screen.dart';
import '../providers/auth.dart';
import 'splash_screen.dart';

class ChatsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Center(
            child: Text(
              "Chats",
              style: TextStyle(
                  color: (Theme.of(context).primaryColor),
                  fontWeight: FontWeight.bold),
            ),
          ),
          elevation: 1,
        ),
        body: Center(
          child: Text("This is Chats Screen"),
        ));
  }
}
