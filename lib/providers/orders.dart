import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
class Orders with ChangeNotifier {
  
  List<dynamic> _orders = [];
  bool isLoading = true;
  // void addOrders(List mesaj){
  //   _orders.add(mesaj);
  // }

  bool get notLoaded {
    return isLoading;
  }

  List get orders{
    return _orders;
  }

   Future fetchAndSetOrders() async {
    const url = "http://briddgy.herokuapp.com/api/orders/";
    final response = http.get(
      url,
      headers: {HttpHeaders.CONTENT_TYPE: "application/json"},
    ).then((onValue){
      final dataOrders = json.decode(onValue.body) as Map<String, dynamic>;
          _orders = dataOrders["results"];
          isLoading = false;
    });
   
  }


}
