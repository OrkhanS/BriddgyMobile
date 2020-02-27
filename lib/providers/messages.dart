import 'package:flutter/material.dart';

class Messages with ChangeNotifier {
  
  List<dynamic> _messages = [];
  
  void addMessages(List mesaj){
    _messages.add(mesaj);
  }

  List get messages{
    return _messages;
  }
}
