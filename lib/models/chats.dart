// To parse this JSON data, do
//
//     final chats = chatsFromJson(jsonString);

import 'dart:convert';
import 'package:briddgy/models/user.dart';

Chats chatsFromJson(String str) => Chats.fromJson(json.decode(str));

String chatsToJson(Chats data) => json.encode(data.toJson());

class Chats {
  Chats({
    this.id,
    this.dateCreated,
    this.dateModified,
    this.members,
    this.lastMessage,
  });

  String id;
  String lastMessage;
  DateTime dateCreated;
  DateTime dateModified;
  List<Member> members;

  factory Chats.fromJson(Map<String, dynamic> json) => Chats(
        id: json["id"],
        lastMessage: json["last_message"],
        dateCreated: DateTime.parse(json["date_created"]),
        dateModified: DateTime.parse(json["date_modified"]),
        members:
            List<Member>.from(json["members"].map((x) => Member.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "last_message": lastMessage,
        "date_created": dateCreated.toIso8601String(),
        "date_modified": dateModified.toIso8601String(),
        "members": List<dynamic>.from(members.map((x) => x.toJson())),
      };
}

class Member {
  Member({
    this.id,
    this.user,
    this.unreadCount,
    this.online,
    this.room,
  });

  int id;
  User user;
  int unreadCount;
  bool online;
  String room;

  factory Member.fromJson(Map<String, dynamic> json) => Member(
        id: json["id"],
        user: User.fromJson(json["user"]),
        unreadCount: json["unread_count"],
        online: json["online"],
        room: json["room"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user": user.toJson(),
        "unread_count": unreadCount,
        "online": online,
        "room": room,
      };
}
