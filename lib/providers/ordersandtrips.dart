import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

class OrdersTripsProvider with ChangeNotifier {
  List _orders = [];
  List _myorders = [];
  List _trips = [];
  List _mytrips = [];
  bool isLoadingOrders = true;
  bool isLoading;
  bool isLoadingMyOrders = true;
  String token;
  Map allTripsDetails = {};
  Map allOrdersDetails = {};
  Map allMyOrderDetails = {};
  Map allMyTripsDetails = {};

  bool get notLoadingOrders {
    return isLoadingOrders;
  }
  
  bool get notLoadedMyorders{
    return isLoadingMyOrders;
  }
  
  bool get notLoaded {
    return isLoading;
  }
  
  List get orders {
    return _orders;
  }

  List get myorders {
    return _myorders;
  }
  Map get detailsOrder {
    return allOrdersDetails;
  }
  Map get detailsMyOrder {
    return allMyOrderDetails;
  }

  set orders(List temporders) {
    _orders = temporders;
    notifyListeners();
  }

  set myorders(List temporders) {
    _myorders = temporders;
    notifyListeners();
  }


  Future fetchAndSetOrders() async {
    const url = "http://briddgy.herokuapp.com/api/orders/";
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      http.get(
        url,
        headers: {
          HttpHeaders.CONTENT_TYPE: "application/json",
        },
      ).then((onValue) {
        final dataOrders = json.decode(onValue.body) as Map<String, dynamic>;
        orders = dataOrders["results"];
        allOrdersDetails = dataOrders;
        isLoadingOrders = false;
      });
    } else {
      final extractedUserData =
          json.decode(prefs.getString('userData')) as Map<String, Object>;
      token = extractedUserData['token'];

      http.get(
        url,
        headers: {
          HttpHeaders.CONTENT_TYPE: "application/json",
          "Authorization": "Token " + token,
        },
      ).then((onValue) {
        final dataOrders = json.decode(onValue.body) as Map<String, dynamic>;
        orders = dataOrders["results"];
        allOrdersDetails = dataOrders;
        isLoadingOrders = false;
      });
    }

    //notifyListeners();
    return _orders;
  }

  Future fetchAndSetMyOrders(myToken) async {
    var token = myToken;
    const url = "http://briddgy.herokuapp.com/api/my/orders/";
    http.get(
      url,
      headers: {
        HttpHeaders.CONTENT_TYPE: "application/json",
        "Authorization": "Token " + token,
      },
    ).then((onValue) {
      final dataOrders = json.decode(onValue.body) as Map<String, dynamic>;
      myorders = dataOrders["results"];
      allMyOrderDetails = dataOrders;
      isLoadingMyOrders = false;
    });
  }

  //_________________________________________________________TRIPS__________________________________________________________
  set trips(List temptrips) {
    _trips = temptrips;
    notifyListeners();
  }

  List get trips {
    return _trips;
  }

  List get mytrips {
    return _mytrips;
  }
  Map get detailsTrip {
    return allTripsDetails;
  }
  Map get detailsMyTrip {
    return allMyTripsDetails;
  }

  set mytrips(List temporders) {
    _mytrips = temporders;
    notifyListeners();
  }

  Future fetchAndSetTrips() async {
    const url = "http://briddgy.herokuapp.com/api/trips/";
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      http.get(
        url,
        headers: {HttpHeaders.CONTENT_TYPE: "application/json"},
      ).then(
        (response) {
          final dataTrips = json.decode(response.body) as Map<String, dynamic>;
          trips = dataTrips["results"];
          allTripsDetails = dataTrips;
          isLoading = false;
          return;
        },
      );
    } else {
      final extractedUserData =
          json.decode(prefs.getString('userData')) as Map<String, Object>;
      token = extractedUserData['token'];

      if (token != null) {
        http.get(
          url,
          headers: {
            HttpHeaders.CONTENT_TYPE: "application/json",
            "Authorization": "Token " + token,
          },
        ).then(
          (response) {
            final dataTrips =
                json.decode(response.body) as Map<String, dynamic>;
            trips = dataTrips["results"];
            allTripsDetails = dataTrips;
            isLoading = false;
          },
        );
      }
    }
  }

  Future fetchAndSetMyTrips(myToken) async {
    var token = myToken;
    const url = "http://briddgy.herokuapp.com/api/my/trips/";
    http.get(
      url,
      headers: {
        HttpHeaders.CONTENT_TYPE: "application/json",
        "Authorization": "Token " + token,
      },
    ).then((onValue) {
      final dataTrips = json.decode(onValue.body) as Map<String, dynamic>;
      mytrips = dataTrips["results"];
      allMyTripsDetails = dataTrips;
      isLoading = false;
    });
  }
}
