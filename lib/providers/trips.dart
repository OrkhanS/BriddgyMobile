import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

class TripsProvider with ChangeNotifier {
  
  List _trips = [];
  bool isLoading = true;
  // void addtrips(List mesaj){
  //   _trips.add(mesaj);
  // }

  bool get notLoaded {
    return isLoading;
  }

  List get trips{
    return _trips;
  }

  set trips(List temptrips){
    _trips = temptrips;
    notifyListeners();
  }
  
  Future fetchAndSetTrips() async {
    const url = "http://briddgy.herokuapp.com/api/trips/";
    http.get(
      url,
      headers: {HttpHeaders.CONTENT_TYPE: "application/json"},
    ).then((response) {
          final dataOrders = json.decode(response.body) as Map<String, dynamic>;
          trips = dataOrders["results"];
          isLoading = false;
        },
      );
  }

}
