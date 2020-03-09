import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class Messages with ChangeNotifier {
  Map _messages = {};
  List<dynamic> mesajlar = [];
  set addMessages(Map mesaj) {
    print(mesaj);
    for (var i = 0; i < _messages.length; i++) {
      if (_messages[mesaj["room_id"]].length > 0) {
        _messages[mesaj["room_id"]]["results"].add(mesaj);
      }
    }
    print(_messages);
    notifyListeners();
  }

  set allAddMessages(Map mesaj) {
    _messages[mesaj["room_id"]] = mesaj;
    
    notifyListeners();
  }

  Map get messages => _messages;
}
