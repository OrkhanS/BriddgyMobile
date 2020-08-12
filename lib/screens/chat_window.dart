import 'package:flutter/material.dart';
import 'package:optisend/models/api.dart';
import 'package:optisend/providers/auth.dart';
import 'package:web_socket_channel/io.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:optisend/providers/messages.dart';
import 'package:menu/menu.dart';
import 'dart:convert';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

class ChatWindow extends StatefulWidget {
  var provider, user, room, auth, token;
  ChatWindow({this.provider, this.user, this.room, this.auth, this.token});
  static const routeName = '/chats/chat_window';
  @override
  _ChatWindowState createState() => _ChatWindowState();
}

class _ChatWindowState extends State<ChatWindow> {
  List _messages = [];
  TextEditingController textEditingController;
  ScrollController scrollController;
  ObserverList<Function> _listeners = new ObserverList<Function>();
  bool enableButton = false;
  bool _isOn = false;
  IOWebSocketChannel _channelRoom;
  IOWebSocketChannel alertChannel;
  bool _isloading = false;
  bool newMessageMe = false;
  String id;
  String token;
  String nextMessagesURL = "FirstCall";
  var file;
  final String phpEndPoint = 'http://192.168.43.171/phpAPI/image.php';
  final String nodeEndPoint = 'http://192.168.43.171:3000/image';
  @override
  void initState() {
    textEditingController = TextEditingController();
    scrollController = ScrollController();
    id = widget.room.toString();
    token = widget.auth.myTokenFromStorage;
    initCommunication(id);
    super.initState();
  }

  initCommunication(String id) async {
    reset();
    try {
      _channelRoom = new IOWebSocketChannel.connect(
          Api.roomSocket + id.toString() + '/?token=' + token.toString());
      _channelRoom.stream.listen(_onReceptionOfMessageFromServer);
      print("Room Socket Connected");
    } catch (e) {}
  }

  addListener(Function callback) {
    _listeners.add(callback);
  }

  removeListener(Function callback) {
    _listeners.remove(callback);
  }

  _onReceptionOfMessageFromServer(message) {
    _isOn = true;
    _listeners.forEach((Function callback) {
      callback(message);
    });
  }

  reset() {
    if (_channelRoom != null) {
      if (_channelRoom.sink != null) {
        _channelRoom.sink.close();
        _isOn = false;
      }
    }
  }

  void handleSendMessage() {
    var text = textEditingController.value.text;
    textEditingController.clear();
    widget.provider.changeChatRoomPlace(widget.room);

    if (_channelRoom != null) {
      if (_channelRoom.sink != null) {
        _channelRoom.sink.add(text);
      }
    }
  }

  var triangle = CustomPaint(
    painter: Triangle(),
  );

  void _choose() async {
    file = await ImagePicker.pickImage(source: ImageSource.camera);
// file = await ImagePicker.pickImage(source: ImageSource.gallery);
  }

  void _upload() {
    if (file == null) return;
    String base64Image = base64Encode(file.readAsBytesSync());
    String fileName = file.path.split("/").last;
  }

  @override
  Widget build(BuildContext context) {
    var textInput = Row(
      children: <Widget>[
        IconButton(
          icon: Icon(Icons.camera_alt),
          onPressed: () {
            _choose();
          },
        ),
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

    Future _loadData() async {
      if (nextMessagesURL.toString() != "null") {
        String url = nextMessagesURL;
        try {
          await http.get(
            url,
            headers: {
              HttpHeaders.CONTENT_TYPE: "application/json",
              "Authorization": "Token " + token,
            },
          ).then((response) {
            var dataOrders = json.decode(response.body) as Map<String, dynamic>;
            _messages.addAll(dataOrders["results"]);
            nextMessagesURL = dataOrders["next"];
          });
        } catch (e) {}
        setState(() {
//        items.addAll( ['item 1']);
//        print('items: '+ items.toString());
          _isloading = false;
        });
      } else {
        _isloading = false;
      }
    }

    return Consumer<Messages>(
      builder: (context, provider, child) {
        bool messageLoader = true;
        if (widget.provider.messages[widget.room] != null) {
          _messages = widget.provider.messages[widget.room];
          if (nextMessagesURL == "FirstCall") {
            // nextMessagesURL = widget.provider.messages[widget.room]["next"];
          }
          messageLoader = false;
        } else {
          messageLoader = true;
        }
        return Scaffold(
          resizeToAvoidBottomPadding: true,
          body: SafeArea(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: AppBar(
                    centerTitle: true,
                    backgroundColor: Colors.white,
                    leading: IconButton(
                      icon: Icon(Icons.chevron_left,
                          color: Theme.of(context).primaryColor),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    title: Text(
                      widget.user.firstName + " " + widget.user.lastName,
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                  ),
                ),
                Container(
                  height: _isloading ? 50.0 : 0.0,
                  color: Colors.transparent,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                Expanded(
                  child: messageLoader
                      ? Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              CircularProgressIndicator(
                                strokeWidth: 3,
                              )
                            ],
                          ),
                        )
                      : NotificationListener<ScrollNotification>(
                          onNotification: (ScrollNotification scrollInfo) {
                            if (!_isloading &&
                                scrollInfo.metrics.pixels ==
                                    scrollInfo.metrics.maxScrollExtent) {
                              // start loading data
                              setState(() {
                                _isloading = true;
                              });
                              _loadData();
                            }
                          },
                          child: ListView.builder(
                            reverse: true,
                            controller: scrollController,
                            itemCount: _messages.length,
                            itemBuilder: (context, index) {
                              bool reverse = false;
                              if (widget.user.id != _messages[index].sender ||
                                  _messages[index].sender == "me") {
                                newMessageMe = false;
                                reverse = true;
                              }

                              var avatar = reverse == false
                                  ? GestureDetector(
                                      onTap: () {
                                        //todo navigate to user profile
                                        print("check");
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 5),
                                        child: CircleAvatar(
                                          backgroundColor: Colors.teal,
                                          child: Text(
                                            widget.user.firstName.toString()[0],
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    )
                                  : Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      child: CircleAvatar(
                                        child: Text(widget.user.firstName
                                            .toString()[0]),
                                      ),
                                    );

                              var messagebody = Menu(
                                child: Container(
                                    child: DecoratedBox(
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
                                      // RASUL
                                      child: Text(
                                        _messages[index].text.toString(),
                                        softWrap: true,
                                      ),
                                    ),
                                  ),
                                )),
                                items: [
                                  MenuItem("Info", () {
                                    Alert(
                                      context: context,
                                      type: AlertType.info,
                                      title: "Sent on:  " +
                                          _messages[index]
                                              .dateCreated
                                              .toString()
                                              .substring(0, 10) +
                                          ",  " +
                                          _messages[index]
                                              .dateCreated
                                              .toString()
                                              .substring(11, 16) +
                                          "\n",
                                      buttons: [
                                        DialogButton(
                                          child: Text(
                                            "Back",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 20),
                                          ),
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          color:
                                              Color.fromRGBO(0, 179, 134, 1.0),
                                        ),
                                        DialogButton(
                                          child: Text(
                                            "Report",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 20),
                                          ),
                                          onPressed: () => {},
                                          color:
                                              Color.fromRGBO(0, 179, 134, 1.0),
                                        )
                                      ],
                                      content: Text(
                                          "To keep our community more secure and as mentioned our Privacy&Policy, you cannot remove messages.\n"),
                                    ).show();
                                  }),
                                ],
                                decoration: MenuDecoration(),
                              );

                              Widget message;

                              if (reverse) {
                                message = Stack(
                                  children: <Widget>[
                                    messagebody,
                                    Positioned(
                                        right: 0, bottom: 0, child: triangle),
                                  ],
                                );
                              } else {
                                message = Stack(
                                  children: <Widget>[
                                    Positioned(
                                        left: 0, bottom: 0, child: triangle),
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
                ),
                Divider(height: 2.0),
                textInput
              ],
            ),
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
