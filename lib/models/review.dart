// To parse this JSON data, do
//
//     final review = reviewFromJson(jsonString);

import 'dart:convert';

import 'package:briddgy/models/user.dart';

Review reviewFromJson(String str) => Review.fromJson(json.decode(str));

String reviewToJson(Review data) => json.encode(data.toJson());

class Review {
  Review({
    this.id,
    this.reviewFrom,
    this.reviewTo,
    this.comment,
    this.date,
  });

  int id;
  User reviewFrom;
  int reviewTo;
  String comment;
  DateTime date; 

  factory Review.fromJson(Map<String, dynamic> json) => Review(
        id: json["id"],
        reviewFrom: User.fromJson(json["reviewFrom"]),
        reviewTo: json["reviewTo"],
        comment: utf8.decode(json["comment"].toString().codeUnits),
        date: DateTime.parse(json["date"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "reviewFrom": reviewFrom.toJson(),
        "reviewTo": reviewTo,
        "comment": comment,
        "date": date.toIso8601String(),
      };
}
