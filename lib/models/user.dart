// To parse this JSON data, do
//
//     final user = userFromJson(jsonString);

import 'dart:convert';

User userFromJson(String str) => User.fromJson(json.decode(str));

String userToJson(User data) => json.encode(data.toJson());

class User {
  User({
    this.id,
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
  });

  int id;
  String firstName;
  String lastName;
  String email;
  bool isActive;
  bool isStaff;
  int rating;
  String isNumberVerified;
  bool isEmailVerified;
  bool isPhotoVerified;
  dynamic avatarpic;
  String deviceToken;
  bool online;
  DateTime lastOnline;

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        firstName: json["first_name"],
        lastName: json["last_name"],
        email: json["email"],
        isActive: json["is_active"],
        isStaff: json["is_staff"],
        rating: json["rating"],
        isNumberVerified: json["is_number_verified"],
        isEmailVerified: json["is_email_verified"],
        isPhotoVerified: json["is_photo_verified"],
        avatarpic: json["avatarpic"],
        deviceToken: json["deviceToken"],
        online: json["online"],
        lastOnline: DateTime.parse(json["last_online"]),
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
      };
}
