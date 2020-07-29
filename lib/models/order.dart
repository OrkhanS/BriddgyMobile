// To parse this JSON data, do
//
//     final order = orderFromJson(jsonString);

import 'dart:convert';

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
  Owner owner;
  int dimensions;
  Destination source;
  Destination destination;
  DateTime date;
  String address;
  int weight;
  int price;
  dynamic trip;
  String description;
  String title;
  dynamic deliverer;
  List<dynamic> orderimage;

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json["id"],
        owner: Owner.fromJson(json["owner"]),
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

class Owner {
  Owner({
    this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.isNumberVerified,
    this.isEmailVerified,
    this.isPhotoVerified,
    this.lastLogin,
    this.rating,
    this.avatarpic,
    this.lastOnline,
    this.online,
  });

  int id;
  String firstName;
  String lastName;
  String email;
  String isNumberVerified;
  bool isEmailVerified;
  bool isPhotoVerified;
  DateTime lastLogin;
  int rating;
  dynamic avatarpic;
  DateTime lastOnline;
  bool online;

  factory Owner.fromJson(Map<String, dynamic> json) => Owner(
        id: json["id"],
        firstName: json["first_name"],
        lastName: json["last_name"],
        email: json["email"],
        isNumberVerified: json["is_number_verified"],
        isEmailVerified: json["is_email_verified"],
        isPhotoVerified: json["is_photo_verified"],
        lastLogin: DateTime.parse(json["last_login"]),
        rating: json["rating"],
        avatarpic: json["avatarpic"],
        lastOnline: DateTime.parse(json["last_online"]),
        online: json["online"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "first_name": firstName,
        "last_name": lastName,
        "email": email,
        "is_number_verified": isNumberVerified,
        "is_email_verified": isEmailVerified,
        "is_photo_verified": isPhotoVerified,
        "last_login": lastLogin.toIso8601String(),
        "rating": rating,
        "avatarpic": avatarpic,
        "last_online": lastOnline.toIso8601String(),
        "online": online,
      };
}
