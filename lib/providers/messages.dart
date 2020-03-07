import 'package:flutter/material.dart';

class Messages with ChangeNotifier {
  Map _messages = {};

  void addMessages(Map mesaj) {
    print(mesaj);
    _messages.addAll(mesaj);
  }

//  List get messages{
//    return _messages;
//  }
}
