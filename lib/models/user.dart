// To parse this JSON data, do
//
//     final user = userFromJson(jsonString);

import 'dart:convert';

User userFromJson(String str) => User.fromJson(json.decode(str));

String userToJson(User data) => json.encode(data.toJson());

class User {
  User(
      {this.id,
      this.firstName,
      this.lastName,
      this.email,
      this.isActive,
      this.isStaff,
      this.rating,
      this.isNumberVerified,
      this.isEmailVerified,
      this.isPhotoVerified,
      this.avatarpic,
      this.deviceToken,
      this.online,
      this.lastOnline,
      this.date_joined});

  int id;
  String firstName;
  String lastName;
  String email;
  bool isActive;
  bool isStaff;
  double rating;
  bool isNumberVerified;
  bool isEmailVerified;
  bool isPhotoVerified;
  dynamic avatarpic;
  String deviceToken;
  bool online;
  DateTime lastOnline;
  DateTime date_joined;

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        firstName: utf8.decode(json["first_name"].toString().codeUnits),
        lastName: utf8.decode(json["last_name"].toString().codeUnits),
        email: json["email"],
        isActive: json["is_active"],
        isStaff: json["is_staff"],
        rating: json["rating"] as double,
        isNumberVerified: json["is_number_verified"],
        isEmailVerified: json["is_email_verified"],
        isPhotoVerified: json["is_photo_verified"],
        avatarpic: json["avatarpic"],
        deviceToken: json["deviceToken"],
        online: json["online"],
        lastOnline: DateTime.parse(json["last_online"]),
        date_joined: DateTime.parse(json["date_joined"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "first_name": firstName,
        "last_name": lastName,
        "email": email,
        "is_active": isActive,
        "is_staff": isStaff,
        "rating": rating,
        "is_number_verified": isNumberVerified,
        "is_email_verified": isEmailVerified,
        "is_photo_verified": isPhotoVerified,
        "avatarpic": avatarpic,
        "deviceToken": deviceToken,
        "online": online,
        "last_online": lastOnline.toIso8601String(),
        "date_joined": date_joined.toIso8601String(),
      };
}
