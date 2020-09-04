// To parse this JSON data, do
//
//     final trip = tripFromJson(jsonString);

import 'dart:convert';

import 'package:optisend/models/user.dart';

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
    this.description,
  });

  int id;
  User owner;
  Destination source;
  Destination destination;
  DateTime date;
  double weightLimit;
  int numberOfContracts;
  String description;

  factory Trip.fromJson(Map<String, dynamic> json) => Trip(
        id: json["id"],
        owner: User.fromJson(json["owner"]),
        source: Destination.fromJson(json["source"]),
        destination: Destination.fromJson(json["destination"]),
        date: DateTime.parse(json["date"]),
        weightLimit: json["weight_limit"].toDouble(),
        numberOfContracts: json["number_of_contracts"],
        description: utf8.decode(json["description"].toString().codeUnits),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "owner": owner.toJson(),
        "source": source.toJson(),
        "destination": destination.toJson(),
        "date": "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
        "weight_limit": weightLimit,
        "number_of_contracts": numberOfContracts,
        "description": description
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
        cityAscii: utf8.decode(json["city_ascii"].toString().codeUnits),
        country: utf8.decode(json["country"].toString().codeUnits),
        id: json["id"],
      );

  Map<String, dynamic> toJson() => {
        "city_ascii": cityAscii,
        "country": country,
        "id": id,
      };
}
