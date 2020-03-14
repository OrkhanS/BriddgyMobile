import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class Messages extends ChangeNotifier {
  Map _messages = {};
  List _chatRooms = [];
  Map tmp = {};
  int tmpIDofMessage = 0;

  set addMessages(Map mesaj) {
    for (var i = 0; i < _messages.length; i++) {
      if (_messages[mesaj["room_id"]].length > 0) {
        if(_messages[mesaj["room_id"]]["results"][0]["id"] != mesaj["id"]){ 
        _messages[mesaj["room_id"]]["results"].insert(0, mesaj);
        }
      }
    }
    notifyListeners();
  }

  Map allAddMessages(Map mesaj) {
    _messages[mesaj["room_id"]] = mesaj;
    notifyListeners();
    return _messages;
  }

  Map get messages => _messages;


  //______________________________________________________________________________________
  set addChats(Map mesaj) {
    //here goes new room
    notifyListeners();
  }

  List allAddChats(List rooms) {
    _chatRooms = rooms;
    //notifyListeners();
    return _chatRooms;
  }

  List get chats => _chatRooms;

}
