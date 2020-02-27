import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:optisend/screens/chat_window.dart';
import 'package:provider/provider.dart';
import './auth_screen.dart';
import '../providers/auth.dart';
import 'splash_screen.dart';

import 'package:flutter/material.dart';
import 'dart:math';
import 'package:optisend/main.dart';
import 'chat_window.dart';

class ChatsScreen extends StatefulWidget {
  var rooms, messages, alertChannel;
  ChatsScreen({this.rooms, this.messages, this.alertChannel});
  @override
  _ChatsScreenState createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  PageController pageController;
  int numberOfPages = 6;
  double viewportFraction = 0.75;
  String imageUrl;
  Map _details = {};

  @override
  void initState() {
    pageController = PageController(viewportFraction: viewportFraction);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    getAvatarUrl(String a) {
      String helper = 'https://briddgy.herokuapp.com/media/';
      imageUrl =
          'https://moonvillageassociation.org/wp-content/uploads/2018/06/default-profile-picture1.jpg';
      if (a != null) {
        imageUrl = 'https://briddgy.herokuapp.com/media/' + a.toString() + "/";
      }

      return imageUrl;
    }

    List<MaterialColor> colors = [
      Colors.amber,
      Colors.red,
      Colors.green,
      Colors.lightBlue,
    ];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Center(
          child: Text(
            "Chats",
            style: TextStyle(
                color: (Theme.of(context).primaryColor),
                fontWeight: FontWeight.bold),
          ),
        ),
        elevation: 1,
      ),
      body: Container(
        child: ListView.builder(
          itemCount: widget.rooms.length,
          itemBuilder: (context, int index) {
            return Column(
              children: <Widget>[
                Divider(
                  height: 12.0,
                ),
                ListTile(
                  leading: CircleAvatar(
                      radius: 24.0,
                      child: FadeInImage(
                        image: NetworkImage(getAvatarUrl(
                            widget.rooms[index]["members"][0]["avatarpic"])),
                        placeholder: NetworkImage(
                            'https://moonvillageassociation.org/wp-content/uploads/2018/06/default-profile-picture1.jpgs'),
                      )),
                  title: Row(
                    children: <Widget>[
                      Text(widget.rooms[index]["members"][0]["first_name"]
                          .toString()),
                      SizedBox(
                        width: 16.0,
                      ),
                      Text(
                        widget.rooms[index]["date_modified"]
                            .toString()
                            .substring(0, 10),
                        style: TextStyle(fontSize: 12.0),
                      ),
                    ],
                  ),
                  subtitle: Text(widget.rooms[index]["members"][0]["last_name"]
                      .toString()),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 14.0,
                  ),
                  onTap: () {
                    // Navigator.of(context).pushNamed('/chats/chat_window');
                    Navigator.push(
                      context,
                      new MaterialPageRoute(
                          builder: (__) => new ChatWindow(
                              messages: widget.messages[index],
                              roomID: widget.rooms[index]["id"],
                              user: widget.rooms[index]["members"],
                              alertChannel: widget.alertChannel)),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// class ChatModel {
//   final String avatarUrl;
//   final String name;
//   final String datetime;
//   final String message;

//   ChatModel({this.avatarUrl, this.name, this.datetime, this.message});
//   static final List<ChatModel> dummyData = [
//     for (var member in rooms){

//     }
//     ChatModel(
//       avatarUrl: "https://randomuser.me/api/portraits/women/34.jpg",
//       name: "Laurent",
//       datetime: "20:18",
//       message: "How about meeting tomorrow?",
//     ),
//     // ChatModel(
//     //   avatarUrl: "https://randomuser.me/api/portraits/women/49.jpg",
//     //   name: "Tracy",
//     //   datetime: "19:22",
//     //   message: "I love that idea, it's great!",
//     // ),
//     // ChatModel(
//     //   avatarUrl: "https://randomuser.me/api/portraits/women/77.jpg",
//     //   name: "Claire",
//     //   datetime: "14:34",
//     //   message: "I wasn't aware of that. Let me check",
//     // ),
//     // ChatModel(
//     //   avatarUrl: "https://randomuser.me/api/portraits/men/81.jpg",
//     //   name: "Joe",
//     //   datetime: "11:05",
//     //   message: "Flutter just release 1.0 officially. Should I go for it?",
//     // ),
//     // ChatModel(
//     //   avatarUrl: "https://randomuser.me/api/portraits/men/83.jpg",
//     //   name: "Mark",
//     //   datetime: "09:46",
//     //   message: "It totally makes sense to get some extra day-off.",
//     // ),
//     // ChatModel(
//     //   avatarUrl: "https://randomuser.me/api/portraits/men/85.jpg",
//     //   name: "Williams",
//     //   datetime: "08:15",
//     //   message: "It has been re-scheduled to next Saturday 7.30pm",
//     // ),
//   ];
// }
