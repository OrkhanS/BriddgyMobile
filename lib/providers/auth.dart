import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:optisend/models/api.dart';
import 'package:optisend/models/users.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/http_exception.dart';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;
  Map user = {};
  bool isLoadingUser = true;
  bool isLoadingUserDetails = true;
  String myTokenFromStorage;

  String get myToken {
    return myTokenFromStorage;
  }

  set myToken(string) {
    myTokenFromStorage = string;
  }

  bool get isNotLoadingUserDetails {
    return isLoadingUserDetails;
  }

  bool get isAuth {
    return _token != null;
  }

  String get token {
    if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  set token(String tokenlox) {
    _token = tokenlox;
  }

  String get userId {
    return _userId;
  }

  Map get userdetail {
    return user;
  }

  bool get isNotLoading {
    return isLoadingUser;
  }

  Future fetchAndSetUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractedUserData =
        json.decode(prefs.getString('userData')) as Map<String, Object>;

    const url = Api.currentUserDetails;
    try {
      final response = await http.get(
        url,
        headers: {
          HttpHeaders.CONTENT_TYPE: "application/json",
          "Authorization": "Token " + extractedUserData['token'],
        },
      ).then((response) {
        final dataOrders = json.decode(response.body) as Map<String, dynamic>;
        user = dataOrders;
        isLoadingUser = false;
        isLoadingUserDetails = false;
        notifyListeners();
        User(
            email: user["email"],
            id: user["id"],
            name: user["first_name"],
            lastname: user["last_name"],
            token: extractedUserData['token']);
      });
    } catch (e) {
      return;
    }
  }

  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    const url = "http://briddgy.herokuapp.com/api/auth/";
    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'email': email,
            'password': password,
            'returnSecureToken': true,
          },
        ),
      );
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(
            responseData['expiresIn'],
          ),
        ),
      );
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode(
        {
          'token': _token,
          'userId': _userId,
          'expiryDate': _expiryDate.toIso8601String(),
        },
      );
      prefs.setString('userData', userData);
    } catch (error) {
      throw error;
    }
  }

  Future<void> signup(String email, String password, String firstname,
      String lastname, String deviceID) async {
    const url = Api.signUp;
    try {
      final response = await http.post(
        url,
        headers: {HttpHeaders.CONTENT_TYPE: "application/json"},
        body: json.encode(
          {
            'email': email,
            'password': password,
            'password2': password,
            'first_name': firstname,
            'last_name': lastname,
            'deviceToken': deviceID,
          },
        ),
      );
      final responseData = json.decode(response.body);
      _token = responseData;
      myToken = responseData;
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode(
        {
          'token': _token,
        },
      );
      prefs.setString('userData', userData);
    } catch (error) {
      throw error;
    }
  }

  Future<void> login(String email, String password, String deviceID) async {
    const url = Api.login;
    print(url);
    try {
      final response = await http.post(
        url,
        headers: {HttpHeaders.CONTENT_TYPE: "application/json"},
        body: json.encode(
          {
            'username': email,
            'password': password,
            'deviceToken': deviceID,
          },
        ),
      );
      final responseData = json.decode(response.body);
      _token = responseData;
      myToken = responseData;
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode(
        {
          'token': _token,
        },
      );
      prefs.setString('userData', userData);
      fetchAndSetUserDetails();
    } catch (error) {
      throw error;
    }
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractedUserData =
        json.decode(prefs.getString('userData')) as Map<String, Object>;
    _token = extractedUserData['token'];
    fetchAndSetUserDetails();
    notifyListeners();
    return true;
  }

  Future<void> logout(context) async {
    print(_token);
    const url = Api.login;
    http.patch(url,
        headers: {
          HttpHeaders.CONTENT_TYPE: "application/json",
          "Authorization": "Token " + _token,
        },
        body: json.encode({"token": _token}));
    _token = null;
    Navigator.of(context).pop();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('userData');
    prefs.clear();
  }
}
