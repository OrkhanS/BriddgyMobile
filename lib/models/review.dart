// To parse this JSON data, do
//
//     final review = reviewFromJson(jsonString);

import 'dart:convert';

import 'package:optisend/models/user.dart';

Review reviewFromJson(String str) => Review.fromJson(json.decode(str));

String reviewToJson(Review data) => json.encode(data.toJson());

class Review {
  Review({
    this.id,
    this.author,
    this.reviewTo,
    this.comment,
  });

  int id;
  User author;
  int reviewTo;
  String comment;

  factory Review.fromJson(Map<String, dynamic> json) => Review(
        id: json["id"],
        author: User.fromJson(json["author"]),
        reviewTo: json["reviewTo"],
        comment: utf8.decode(json["comment"].toString().codeUnits),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "author": author.toJson(),
        "reviewTo": reviewTo,
        "comment": comment,
      };
}
