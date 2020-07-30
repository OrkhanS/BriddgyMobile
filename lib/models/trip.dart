// To parse this JSON data, do
//
//     final trip = tripFromJson(jsonString);

import 'dart:convert';

Trip tripFromJson(String str) => Trip.fromJson(json.decode(str));

String tripToJson(Trip data) => json.encode(data.toJson());

class Trip {
  Trip({
    this.id,
    this.owner,
    this.source,
    this.destination,
    this.date,
    this.weightLimit,
    this.numberOfContracts,
  });

  int id;
  Owner owner;
  Destination source;
  Destination destination;
  DateTime date;
  double weightLimit;
  int numberOfContracts;

  factory Trip.fromJson(Map<String, dynamic> json) => Trip(
        id: json["id"],
        owner: Owner.fromJson(json["owner"]),
        source: Destination.fromJson(json["source"]),
        destination: Destination.fromJson(json["destination"]),
        date: DateTime.parse(json["date"]),
        weightLimit: json["weight_limit"],
        numberOfContracts: json["number_of_contracts"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "owner": owner.toJson(),
        "source": source.toJson(),
        "destination": destination.toJson(),
        "date":
            "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
        "weight_limit": weightLimit,
        "number_of_contracts": numberOfContracts,
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
  double rating;
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
