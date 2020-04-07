import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserDetails with ChangeNotifier {
  List<dynamic> _users = [];

  List get userDetails {
    return _users;
  }

  Future fetchAndSetUserDetails() async {
    // var token = Provider.of<Auth>(context, listen: false).token;
    var token = '40694c366ab5935e997a1002fddc152c9566de90';

    try {
      const url = "http://briddgy.herokuapp.com/api/users/me/";

      final response = await http.get(
        url,
        headers: {
          HttpHeaders.CONTENT_TYPE: "application/json",
          "Authorization": "Token " + token,
        },
      );

      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userDetails = json.decode(response.body);

      prefs.setString('userDetails', userDetails);
    } catch (error) {
      throw error;
    }
  }
}
