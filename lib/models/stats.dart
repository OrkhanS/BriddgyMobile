// To parse this JSON data, do
//
//     final stats = statsFromJson(jsonString);

import 'dart:convert';

import 'package:optisend/models/user.dart';

Stats statsFromJson(String str) => Stats.fromJson(json.decode(str));

String statsToJson(Stats data) => json.encode(data.toJson());

class Stats {
  Stats({
    this.totalearnings,
    this.totalcontracts,
    this.totaltrips,
    this.owner,
    this.totalspent,
    this.totalorders,
  });

  int totalearnings;
  int totalcontracts;
  int totaltrips;
  User owner;
  int totalspent;
  int totalorders;

  factory Stats.fromJson(Map<String, dynamic> json) => Stats(
        totalearnings: json["totalearnings"],
        totalcontracts: json["totalcontracts"],
        totaltrips: json["totaltrips"],
        owner: User.fromJson(json["owner"]),
        totalspent: json["totalspent"],
        totalorders: json["totalorders"],
      );

  Map<String, dynamic> toJson() => {
        "totalearnings": totalearnings,
        "totalcontracts": totalcontracts,
        "totaltrips": totaltrips,
        "owner": owner.toJson(),
        "totalspent": totalspent,
        "totalorders": totalorders,
      };
}
