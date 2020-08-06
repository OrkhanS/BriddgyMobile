// To parse this JSON data, do
//
//     final order = orderFromJson(jsonString);

import 'dart:convert';

import 'package:optisend/models/user.dart';

Order orderFromJson(String str) => Order.fromJson(json.decode(str));

String orderToJson(Order data) => json.encode(data.toJson());

class Order {
  Order({
    this.id,
    this.owner,
    this.dimensions,
    this.source,
    this.destination,
    this.date,
    this.address,
    this.weight,
    this.price,
    this.trip,
    this.description,
    this.title,
    this.deliverer,
    this.orderimage,
  });

  int id;
  User owner;
  double dimensions;
  Destination source;
  Destination destination;
  DateTime date;
  String address;
  double weight;
  double price;
  dynamic trip;
  String description;
  String title;
  dynamic deliverer;
  List<dynamic> orderimage;

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json["id"],
        owner: User.fromJson(json["owner"]),
        dimensions: json["dimensions"],
        source: Destination.fromJson(json["source"]),
        destination: Destination.fromJson(json["destination"]),
        date: DateTime.parse(json["date"]),
        address: json["address"],
        weight: json["weight"],
        price: json["price"],
        trip: json["trip"],
        description: json["description"],
        title: json["title"],
        deliverer: json["deliverer"],
        orderimage: List<dynamic>.from(json["orderimage"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "owner": owner.toJson(),
        "dimensions": dimensions,
        "source": source.toJson(),
        "destination": destination.toJson(),
        "date": "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
        "address": address,
        "weight": weight,
        "price": price,
        "trip": trip,
        "description": description,
        "title": title,
        "deliverer": deliverer,
        "orderimage": List<dynamic>.from(orderimage.map((x) => x)),
      };
}

class Destination {
  Destination({
    this.cityAscii,
    this.country,
    this.id,
  });

  String cityAscii;
  String country;
  int id;

  factory Destination.fromJson(Map<String, dynamic> json) => Destination(
        cityAscii: json["city_ascii"],
        country: json["country"],
        id: json["id"],
      );

  Map<String, dynamic> toJson() => {
        "city_ascii": cityAscii,
        "country": country,
        "id": id,
      };
}
