import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:optisend/main.dart';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:provider/provider.dart';
import 'package:optisend/providers/messages.dart';

import 'dart:convert';

import 'package:web_socket_channel/status.dart' as status;
import 'package:responsive_text_field/responsive_text_field.dart';

class ChatWindow extends StatelessWidget {
  var provider, messages, user, room, token;
  ChatWindow({this.provider, this.messages, this.user, this.room, this.token});
  static const routeName = '/chats/chat_window';

  @override
  Widget build(BuildContext context) {
    print('state build called');
    return ChangeNotifierProvider(
      builder: (_) => Messages(),
      child: ChatWindowChange(
          provider: provider,
          messages: messages,
          room: room,
          user: user,
          token: token),
    );
  }
}

class ChatWindowChange extends StatefulWidget {
  var provider, messages, user, room, token;
  ChatWindowChange(
      {this.provider, this.messages, this.user, this.room, this.token});

  @override
  _ChatWindowState createState() => _ChatWindowState();
}

class _ChatWindowState extends State<ChatWindowChange> {
  List _messages = [];

  TextEditingController textEditingController;
  ScrollController scrollController;
  ObserverList<Function> _listeners = new ObserverList<Function>();
  bool enableButton = false;
  bool _isOn = false;
  IOWebSocketChannel _channelRoom;
  IOWebSocketChannel alertChannel;
  bool _isloading = true;
  bool newMessageMe = false;
  @override
  void initState() {
    textEditingController = TextEditingController();
    scrollController = ScrollController();
    String id = widget.room.toString();
    initCommunication(id);
    super.initState();
  }

  initCommunication(String id) async {
    reset();
    try {
      _channelRoom = new IOWebSocketChannel.connect(
          'ws://briddgy.herokuapp.com/ws/chatrooms/' +
              id.toString() +
              '/?token=' +
              widget.token);
      _channelRoom.stream.listen(_onReceptionOfMessageFromServer);
      print("Room Connected");
    } catch (e) {
      print("Error Occured");
    }
  }

  addListener(Function callback) {
    _listeners.add(callback);
  }

  removeListener(Function callback) {
    _listeners.remove(callback);
  }

  _onReceptionOfMessageFromServer(message) {
    _isOn = true;
    print(message);
    _listeners.forEach((Function callback) {
      callback(message);
    });
  }

  reset() {
    if (_channelRoom != null) {
      if (_channelRoom.sink != null) {
        print("Room Disconnected");
        _channelRoom.sink.close();
        _isOn = false;
      }
    }
  }

  void handleSendMessage() {
    var text = textEditingController.value.text;
    textEditingController.clear();
    var message = {
      "message_type": "text",
      'message': text,
      "room_id": widget.room,
      "sender": widget.user[0]["id"]
    };

    if (_channelRoom != null) {
      if (_channelRoom.sink != null) {
        _channelRoom.sink.add(jsonEncode(message));
      }
    }

    setState(() {
      message = {
        "message_type": "text",
        'text': text,
        "room_id": widget.room,
        "sender": "me",
      };
      _messages.insert(0, message);
      enableButton = false;
    });
//todo: configure scroll to end
    // Future.delayed(Duration(milliseconds: 100), () {
    //   scrollController.animateTo(scrollController.position.maxScrollExtent,
    //       curve: Curves.ease, duration: Duration(milliseconds: 500));
    // });
  }

  var triangle = CustomPaint(
    painter: Triangle(),
  );

  @override
  Widget build(BuildContext context) {
    widget.provider.addListener;
    _messages = widget.provider.messages[widget.room]["results"];
//    print(_messages[0]);

    var textInput = Row(
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: TextField(
              onChanged: (text) {
                setState(() {
                  enableButton = text.isNotEmpty;
                });
              },
              decoration: InputDecoration.collapsed(
                hintText: "Type a message",
              ),
              controller: textEditingController,
            ),
          ),
        ),
        enableButton
            ? IconButton(
                color: Theme.of(context).primaryColor,
                icon: Icon(
                  Icons.send,
                ),
                disabledColor: Colors.grey,
                onPressed: handleSendMessage,
              )
            : IconButton(
                color: Colors.blue,
                icon: Icon(
                  Icons.send,
                ),
                disabledColor: Colors.grey,
                onPressed: null,
              )
      ],
    );

    return Consumer<Messages>(
      builder: (context, mess, child) {
        //print(widget.provider.messages);

        return Scaffold(
          resizeToAvoidBottomPadding: true,
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: Colors.white,
            leading: IconButton(
              icon: Icon(Icons.keyboard_backspace,
                  color: Theme.of(context).primaryColor),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            title: Text(
              widget.user[0]["first_name"].toString(), //todo: name
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
          ),
          body: Column(
            children: <Widget>[
              Expanded(
                child:
                    //widget.messages == 0
                    //  ? Center(child: Text('Empty'))
                    //:
                    ListView.builder(
                  reverse: true,
                  controller: scrollController,
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    bool reverse = false;
                    if (widget.user[0]["id"] != _messages[index]["sender"] ||
                        _messages[index]["sender"] == "me") {
                      newMessageMe = false;
                      reverse = true;
                    }

                    var avatar = Padding(
                      padding: const EdgeInsets.only(
                          left: 8.0, bottom: 8.0, right: 8.0),
                      child: CircleAvatar(
                        child: Text(widget.user[0]["first_name"]
                            .toString()
                            .substring(0, 1)),
                      ),
                    );

                    var messagebody = DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          // Todo
                          // Warning
                          // Warning
                          child: Text(
                            _messages[index]["text"].toString().length > 20
                                ? _messages[index]["text"]
                                    .toString()
                                    .substring(0, 20)
                                : _messages[index]["text"].toString(),
                            softWrap: true,
                          ),
                        ),
                      ),
                    );

                    Widget message;

                    if (reverse) {
                      message = Stack(
                        children: <Widget>[
                          messagebody,
                          Positioned(right: 0, bottom: 0, child: triangle),
                        ],
                      );
                    } else {
                      message = Stack(
                        children: <Widget>[
                          Positioned(left: 0, bottom: 0, child: triangle),
                          messagebody,
                        ],
                      );
                    }

                    if (reverse) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: message,
                          ),
                          avatar,
                        ],
                      );
                    } else {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          avatar,
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: message,
                          ),
                        ],
                      );
                    }
                  },
                ),
              ),
              Divider(height: 2.0),
              textInput
            ],
          ),
        );
      },
    );
  }
}

class Triangle extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()..color = Colors.blue[100];

    var path = Path();
    path.lineTo(10, 0);
    path.lineTo(0, -10);
    path.lineTo(-10, 0);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

// ResponsiveTextField(
//                         availableWidth: MediaQuery.of(context).size.width,
//                         minLines: 1,
//                         maxLines: 5,
//                         style: TextStyle(fontSize: 16),
//                       ),
