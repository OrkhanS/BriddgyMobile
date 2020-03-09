import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class Messages extends ChangeNotifier {
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

  Map allAddMessages(Map mesaj) {
    _messages[mesaj["room_id"]] = mesaj;
    notifyListeners();
    return _messages;
  }

  Map get messages => _messages;
}
