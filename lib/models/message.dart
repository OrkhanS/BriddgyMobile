// To parse this JSON data, do
//
//     final message = messageFromJson(jsonString);

import 'dart:convert';

Message messageFromJson(String str) => Message.fromJson(json.decode(str));

String messageToJson(Message data) => json.encode(data.toJson());

class Message {
  Message({
    this.id,
    this.dateCreated,
    this.dateModified,
    this.text,
    this.sender,
    this.recipients,
  });

  int id;
  DateTime dateCreated;
  DateTime dateModified;
  String text;
  int sender;
  List<dynamic> recipients;

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        id: json["id"],
        dateCreated: DateTime.parse(json["date_created"]),
        dateModified: DateTime.parse(json["date_modified"]),
        text: json["text"],
        sender: json["sender"],
        recipients: List<dynamic>.from(json["recipients"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "date_created": dateCreated.toIso8601String(),
        "date_modified": dateModified.toIso8601String(),
        "text": text,
        "sender": sender,
        "recipients": List<dynamic>.from(recipients.map((x) => x)),
      };
}
