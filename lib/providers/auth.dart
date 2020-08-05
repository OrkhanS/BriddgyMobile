import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:optisend/models/api.dart';
import 'package:optisend/models/user.dart';
import 'package:optisend/providers/messages.dart';
import 'package:optisend/providers/ordersandtrips.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/http_exception.dart';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;
  var user;
  bool isLoadingUserForMain = true;
  bool isLoadingUserDetails = true;
  String myTokenFromStorage;
  List _reviews = [];
  List _stats = [];
  bool statsNotReady = true;
  bool statsNotReadyForProfile = true;
  bool reviewsNotReady = true;
  bool reviewsNotReadyForProfile = true;
  bool verificationStatus = false;

  String get myToken {
    return myTokenFromStorage;
  }

  set myToken(string) {
    myTokenFromStorage = string;
  }

  bool get isNotLoadingUserDetails {
    return isLoadingUserDetails;
  }

  List get reviews => _reviews;
  List get stats => _stats;

  bool get isAuth {
    return _token != null;
  }

  String get token => _token;

  set token(String tokenlox) {
    _token = tokenlox;
  }

  String get userId {
    return _userId;
  }

  get userdetail {
    return user;
  }

  bool get isNotLoading {
    return isLoadingUserForMain;
  }

  Future fetchAndSetStatistics() async {
    const url = Api.myStats;
    if (_token != null) {
      statsNotReady = false;
      final response = await http.get(
        url,
        headers: {
          HttpHeaders.CONTENT_TYPE: "application/json",
          "Authorization": "Token " + _token,
        },
      );

      final dataOrders = json.decode(response.body) as Map<String, dynamic>;
      _stats = dataOrders["results"];
      statsNotReadyForProfile = false;
      notifyListeners();
    }
  }

  Future fetchAndSetReviews() async {
    const url = Api.myReviews;
    if (_token != null) {
      reviewsNotReady = false;
      final response = await http.get(
        url,
        headers: {
          HttpHeaders.CONTENT_TYPE: "application/json",
          "Authorization": "Token " + _token,
        },
      );

      final dataOrders = json.decode(response.body) as Map<String, dynamic>;
      _reviews = dataOrders["results"];
      reviewsNotReadyForProfile = false;
      notifyListeners();
    }
  }

  Future fetchAndSetUserDetails() async {
    // final prefs = await SharedPreferences.getInstance();
    // if (!prefs.containsKey('userData')) {
    //   return false;
    // }
    // final extractedUserData = json.decode(prefs.getString('userData')) as Map<String, Object>;
    isLoadingUserForMain = false;
    const url = Api.currentUserDetails;
    try {
      final response = await http.get(
        url,
        headers: {
          HttpHeaders.CONTENT_TYPE: "application/json",
          "Authorization": "Token " + myTokenFromStorage,
        },
      ).then((response) {
        Map<String, dynamic> data = json.decode(response.body) as Map<String, dynamic>;
        user = User.fromJson(data);
        isLoadingUserForMain = false;
        isLoadingUserDetails = false;
        notifyListeners();
      });
    } catch (e) {
      print(e);
      return;
    }
  }

  Future<void> _authenticate(String email, String password, String urlSegment) async {
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

  Future<bool> requestEmailVerification() async {
    const url = Api.requestEmailVerification;
    await http.get(url, headers: {
      HttpHeaders.contentTypeHeader: "application/json",
      "Authorization": "Token " + myTokenFromStorage,
    }).then((response) {
      if (response.statusCode == 200) {
        print("Requested");
        verificationStatus = false;
        return true;
      } else {
        print("Failed to send email");
        return false;
      }
    });
  }

  Future<bool> verifyEmailCode(key) async {
    const url = Api.verifyEmail;
    await http
        .post(
      url,
      headers: {
        HttpHeaders.contentTypeHeader: "application/json",
        "Authorization": "Token " + myTokenFromStorage,
      },
      body: json.encode(
        {
          'key': key,
        },
      ),
    )
        .then((response) {
      if (response.statusCode == 200) {
        print("Success");
        verificationStatus = true;
        fetchAndSetUserDetails();
        return true;
      } else {
        print("Incorrect Confirmation Key");
        return false;
      }
    });
  }

  Future<void> signup(String email, String password, String firstname, String lastname, String deviceID) async {
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
            'deviceToken': "deviceID",
          },
        ),
      );
      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        _token = responseData["token"];
        myToken = responseData["token"];
        myTokenFromStorage = responseData["token"];
        notifyListeners();
        final prefs = await SharedPreferences.getInstance();
        final userData = json.encode(
          {
            'token': _token,
          },
        );
        prefs.setString('userData', userData);
        verificationStatus = false;
        requestEmailVerification();
      }
    } catch (error) {
      throw error;
    }
  }

  Future<void> login(String email, String password, String deviceID) async {
    const url = Api.login;
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
      myTokenFromStorage = responseData;
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
    final extractedUserData = json.decode(prefs.getString('userData')) as Map<String, Object>;
    _token = extractedUserData['token'];
    myToken = extractedUserData['token'];
    myTokenFromStorage = extractedUserData['token'];
    fetchAndSetUserDetails();
    notifyListeners();
    return true;
  }

  Future<void> logout(context) async {
    const url = Api.login;
    http.patch(url,
        headers: {
          HttpHeaders.CONTENT_TYPE: "application/json",
          "Authorization": "Token " + _token,
        },
        body: json.encode({"token": _token}));
    Navigator.of(context).pop();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userData');
    prefs.commit();
    prefs.clear();
    Provider.of<OrdersTripsProvider>(context, listen: false).removeAllDataOfProvider();
    Provider.of<Messages>(context, listen: false).removeAllDataOfProvider();
    removeAllDataOfProvider();
    notifyListeners();
  }

  removeAllDataOfProvider() {
    _expiryDate = null;
    _userId = null;
    _token = null;
    user = null;
    isLoadingUserForMain = true;
    isLoadingUserDetails = true;
    myTokenFromStorage = null;
    _reviews = [];
    _stats = [];
    statsNotReady = true;
    reviewsNotReady = true;
  }
}
