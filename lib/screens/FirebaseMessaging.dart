import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:optisend/local_notications_helper.dart';

import 'orders_screen.dart';

class FirebaseMessagingDemo extends StatefulWidget{
  FirebaseMessagingDemo() : super();
  final String title = 'FireBase Messaging';
  @override
  State<StatefulWidget> createState() => FirebaseMessagingState();
}

class FirebaseMessagingState extends State<FirebaseMessagingDemo>{
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final notifications = FlutterLocalNotificationsPlugin();

  _getToken(){
    _firebaseMessaging.getToken().then((deviceToken){
      print("Token is: $deviceToken");
    });
  }

_configureFirebaseListerners(){
  _firebaseMessaging.configure(
    onMessage: (Map<String, dynamic> message) async {
      print('onMessage: $message[\'notification\'][\'title\']');
      
      // showOngoingNotification(notifications,
      //             title: message['notification']['title'], body: message['notification']['body']);
    },
    onLaunch: (Map<String, dynamic> message) async {
      print('onLaunch: $message');
    },
    onResume: (Map<String, dynamic> message) async {
      print('onResume: $message');
    },
  );
}

  @override
  void initState(){
    super.initState();
    _getToken();
    _configureFirebaseListerners();
   final settingsAndroid = AndroidInitializationSettings('app_icon');
    final settingsIOS = IOSInitializationSettings(
        onDidReceiveLocalNotification: (id, title, body, payload) =>
            onSelectNotification(payload));

    notifications.initialize(
        InitializationSettings(settingsAndroid, settingsIOS),
        onSelectNotification: onSelectNotification);
  }
  Future onSelectNotification(String payload) async => await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => OrdersScreen()),
      );
  @override
  Widget build(BuildContext context){
    return Scaffold(appBar: AppBar(
      title: Text(widget.title),
    ),);
  }
}