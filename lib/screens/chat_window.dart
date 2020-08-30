import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:optisend/models/api.dart';
import 'package:optisend/models/message.dart';
import 'package:optisend/models/user.dart';
import 'package:optisend/providers/auth.dart';
import 'package:optisend/screens/new_contract_screen.dart';
import 'package:optisend/screens/profile_screen_another.dart';
import 'package:optisend/screens/verify_phone_screen.dart';
import 'package:optisend/widgets/generators.dart';
import 'package:optisend/widgets/progress_indicator_widget.dart';
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

import 'add_order_screen.dart';

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
  bool isMessageSent = false;
  var file;
  User me;
  String imageUrlMe, imageUrlUser;
  final String phpEndPoint = 'http://192.168.43.171/phpAPI/image.php';
  final String nodeEndPoint = 'http://192.168.43.171:3000/image';
  @override
  void initState() {
    textEditingController = TextEditingController();
    scrollController = ScrollController();
    id = widget.room.toString();
    token = widget.auth.myTokenFromStorage;
    me = widget.auth.user;
    widget.provider.isChatRoomPageActive = true;
    widget.provider.roomIDofActiveChatroom = id;
    imageUrlMe = me.avatarpic == null ? Api.noPictureImage : Api.storageBucket + me.avatarpic.toString();
    imageUrlUser = widget.user.avatarpic == null ? Api.noPictureImage : Api.storageBucket + widget.user.avatarpic.toString();
  
    initCommunication(id);
    super.initState();
  }

  initCommunication(String id) async {
    reset();
    try {
      _channelRoom = new IOWebSocketChannel.connect(Api.roomSocket + id.toString() + '/?token=' + token.toString());
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
    var tempMessage = Message.fromJson({
      "id": 200,
      "date_created": DateTime.now().toString(),
      "date_modified": DateTime.now().toString(),
      "text": text.toString(),
      "sender": widget.auth.user.id,
      "recipients": []
    });

    if (_channelRoom != null) {
      try {
        if (_channelRoom.sink != null) {
          _channelRoom.sink.add(text);
          // widget.provider.messages[id].insert(0, tempMessage);
          widget.provider.changeChatRoomPlace(id);
        }
      } catch (e) {
        print(e);
      }
    }

    setState(() {
      _messages.insert(0, tempMessage);
    });
  }

  var triangle = CustomPaint(
    painter: Triangle(),
  );

  void _choose() async {
    file = await ImagePicker.pickImage(source: ImageSource.camera,maxHeight: 400, maxWidth: 400);
    //file = await ImagePicker.pickImage(source: ImageSource.gallery);
  }

  void _upload() {
    if (file == null) return;
    String base64Image = base64Encode(file.readAsBytesSync());
    String fileName = file.path.split("/").last;
  }

  Future<bool> _onWillPop() async {
    // widget.provider.messages[widget.room]["data"] = _messages;
    widget.provider.isChatRoomPageActive = false;
    widget.provider.changeChatRoomPlace("ChangewithList");
    widget.provider.notifFun();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.provider.isChatRoomPageActive == false) {
      widget.provider.isChatRoomPageActive = true;
      widget.provider.roomIDofActiveChatroom = id;
    }
    var textInput = Row(
      children: <Widget>[
//        IconButton(
//          icon: Icon(Icons.camera_alt),
//          onPressed: () {
//            _choose();
//          },
//        ),
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
      if (nextMessagesURL.toString() != "null" && nextMessagesURL.toString() != "FirstCall") {
        String url = nextMessagesURL;
        try {
          await http.get(
            url,
            headers: {
              HttpHeaders.contentTypeHeader: "application/json",
              "Authorization": "Token " + token,
            },
          ).then((response) {
            Map<String, dynamic> data = json.decode(response.body) as Map<String, dynamic>;
            for (var i = 0; i < data["results"].length; i++) {
              _messages.add(Message.fromJson(data["results"][i]));
            }
            nextMessagesURL = data["next"];
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

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Consumer<Messages>(
        builder: (context, provider, child) {
          bool messageLoader = provider.messagesLoading;
          if (widget.provider.messages[widget.room] != null && !messageLoader) {
            if (widget.provider.messages[widget.room].isNotEmpty) {
              _messages = widget.provider.messages[widget.room]["data"];
              if (nextMessagesURL == "FirstCall") {
                nextMessagesURL = widget.provider.messages[widget.room]["next"];
              }
              messageLoader = false;
            } else {
              messageLoader = true;
            }
          }
          return Scaffold(
            resizeToAvoidBottomPadding: true,
            body: SafeArea(
              child: Column(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (__) => ProfileScreenAnother(
                                      user: widget.user,
                                    )),
                          );
                        },
                        child: Row(
                          children: <Widget>[
                            IconButton(
                              color: Theme.of(context).primaryColor,
                              icon: Icon(
                                Icons.chevron_left,
                                size: 24,
                              ),
                              onPressed: () {
                                // widget.provider.messages[widget.room]["data"] = _messages;
                                widget.provider.isChatRoomPageActive = false;
                                widget.provider.changeChatRoomPlace("ChangewithList");
                                widget.provider.notifFun();
                                Navigator.of(context).pop();
                              },
                            ),
                            Expanded(
                              child: Column(
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                        child: Text(
                                          widget.user.firstName + " " + widget.user.lastName,
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600,
                                          ),
//                                style: TextStyle(
//                                  fontStyle: ,
//                                  color: Colors.white,
//                                  fontWeight: FontWeight.bold,
//                                  fontSize: 20,
//                                ),
                                        ),
                                      ),
                                      Icon(
                                        MdiIcons.shieldCheck,
                                        color: Colors.green,
                                        size: 17,
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                    child: Text(
                                      "Last online " + DateFormat.yMMMd().format(widget.user.lastOnline),
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: 
                                    imageUrlUser == Api.noPictureImage
                                      ? InitialsAvatarWidget(widget.user.firstName.toString(), widget.user.lastName.toString(), 50.0)
                                      : ClipRRect(
                                          borderRadius: BorderRadius.circular(25.0),
                                          child: Image.network(
                                            imageUrlUser,
                                            errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
                                              return InitialsAvatarWidget(widget.user.firstName.toString(), widget.user.lastName.toString(), 50.0);
                                            },
                                            height: 50,
                                            width: 50,
                                            fit: BoxFit.fitWidth,
                                          ),
                                        ),
                            ),
                          ],
                        ),
                      ),
                      OpenContainer(
                        openElevation: 5,
                        transitionDuration: Duration(milliseconds: 500),
                        transitionType: ContainerTransitionType.fadeThrough,
                        openBuilder: (BuildContext context, VoidCallback _) {
                          return 
                              me.isNumberVerified ? NewContactScreen(widget.user) : VerifyPhoneScreen();
                        },
                        closedElevation: 6.0,
                        closedShape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(56 / 2),
                          ),
                        ),
                        closedColor: Colors.white,
                        closedBuilder: (BuildContext context, VoidCallback openContainer) {
                          return Container(
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Icon(
                                  MdiIcons.scriptTextOutline,
                                  color: Colors.green[600],
                                  size: 18,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  "Propose Contract",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  if (_isloading)
                    Container(
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
                              if (!_isloading && scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
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
                                bool iscontract = false;

                                try {
                                  var check = json.decode(_messages[index].text) as Map<String, dynamic>;
                                  iscontract = true;
                                } on FormatException catch (_) {
                                  iscontract = false;
                                }
                                //iscontract = false;

                                bool reverse = false;
                                if (widget.user.id != _messages[index].sender || _messages[index].sender == "me") {
                                  newMessageMe = false;
                                  reverse = true;
                                }

                                var avatar = reverse == false
                                    ? GestureDetector(
                                        onTap: () {
                                          //ToDo navigate to user profile
                                          print("check");
                                        },
                                        child: 
                                          imageUrlUser == Api.noPictureImage
                                              ? InitialsAvatarWidget(widget.user.firstName.toString(), widget.user.lastName.toString(), 50.0)
                                              : ClipRRect(
                                                  borderRadius: BorderRadius.circular(25.0),
                                                  child: Image.network(
                                                    imageUrlUser,
                                                    errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
                                                      return InitialsAvatarWidget(widget.user.firstName.toString(), widget.user.lastName.toString(), 50.0);
                                                    },
                                                    height: 50,
                                                    width: 50,
                                                    fit: BoxFit.fitWidth,
                                                  ),
                                                ),
                                            )
                                          : imageUrlMe == Api.noPictureImage
                                              ? InitialsAvatarWidget(me.firstName.toString(), me.lastName.toString(), 50.0)
                                              : ClipRRect(
                                                  borderRadius: BorderRadius.circular(25.0),
                                                  child: Image.network(
                                                    imageUrlMe,
                                                    errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
                                                      return InitialsAvatarWidget(me.firstName.toString(), me.lastName.toString(), 50.0);
                                                    },
                                                    height: 50,
                                                    width: 50,
                                                    fit: BoxFit.fitWidth,
                                                  ),
                                                );

                                var messagebody = !iscontract
                                    ? Menu(
                                        child: Container(
                                          width: _messages[index].text.toString().length * 9.0 + 20 > MediaQuery.of(context).size.width * 0.6
                                              ? MediaQuery.of(context).size.width * 0.6
                                              : _messages[index].text.toString().length * 9.0 + 20,
                                          decoration: BoxDecoration(
                                            color: Colors.blue[100],
                                            borderRadius: BorderRadius.circular(8.0),
                                          ),
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 10),
                                              child: Text(
                                                _messages[index].text.toString(),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 50,
                                              ),
                                            ),
                                          ),
                                        ),
                                        items: [
                                          MenuItem("Info", () {
                                            Alert(
                                              context: context,
                                              type: AlertType.info,
                                              title: "Sent on:  " +
                                                  _messages[index].dateCreated.toString().substring(0, 10) +
                                                  ",  " +
                                                  _messages[index].dateCreated.toString().substring(11, 16) +
                                                  "\n",
                                              buttons: [
                                                DialogButton(
                                                  child: Text(
                                                    "Back",
                                                    style: TextStyle(color: Colors.white, fontSize: 20),
                                                  ),
                                                  onPressed: () => Navigator.pop(context),
                                                  color: Color.fromRGBO(0, 179, 134, 1.0),
                                                ),
                                                DialogButton(
                                                  child: Text(
                                                    "Report",
                                                    style: TextStyle(color: Colors.white, fontSize: 20),
                                                  ),
                                                  onPressed: () => {},
                                                  color: Color.fromRGBO(0, 179, 134, 1.0),
                                                )
                                              ],
                                              content: Text(
                                                  "To keep our community more secure and as mentioned our Privacy&Policy, you cannot remove messages.\n"),
                                            ).show();
                                          }),
                                        ],
                                        decoration: MenuDecoration(),
                                      )
                                    : Container(
                                        width: MediaQuery.of(context).size.width * 0.6,
                                        decoration: BoxDecoration(
                                          color: Colors.blue[100],
//                                          color: Theme.of(context).scaffoldBackgroundColor,
                                          borderRadius: BorderRadius.circular(10),
//                                          border: Border.all(color: Colors.grey[500]),
                                        ),
                                        child: Column(
                                          children: [
                                            Text("I am traveling"),
                                            ListTile(
                                              leading: Text("From"),
                                              trailing: Text("Set"),
                                            ),
                                            RaisedButton(
                                              color: Colors.blue,
                                              child: Text(
                                                "Accept",
                                                style: TextStyle(color: Colors.white),
                                              ),
                                              onPressed: () {
                                                var contract = json.decode(_messages[index].text);
                                                var order,trip;
                                                if(contract["my"]["orderimage"] == null){
                                                    order = contract["opp"]; trip = contract["my"]; 
                                                } else{
                                                  order = contract["my"]; trip = contract["opp"];
                                                }
                                                final url = Api.applyForDelivery;
                                                http.put(
                                                url,
                                                headers: {
                                                    HttpHeaders.contentTypeHeader: "application/json",
                                                    "Authorization": "Token " + Provider.of<Auth>(context,listen:false).myTokenFromStorage,
                                                },
                                                body: json.encode(
                                                  {
                                                    'order': order["id"],
                                                    'trip': trip["id"],
                                                    'idOfmessage': _messages[index].id
                                                  },
                                                ),
                                              ).then((response) {
                                                  if(response.statusCode == 200){
                                                      print("Accepted");
                                                      //todo Rasul
                                                      //What should we do?
                                                       
                                                  }
                                                  else{
                                                    //todo Rasul                            
                                                    // Here show an error message how you want                        
                                                    print(json.decode(response.body)["detail"]);
                                                  }
                                              });

                                                
                                              },
                                            ),
                                            RaisedButton(
                                              color: Colors.red,
                                              child: Text(
                                                "Reject",
                                                style: TextStyle(color: Colors.white),
                                              ),
                                              onPressed: () {},
                                            ),
                                          ],
                                        ),
                                      );

                                Widget message;

                                if (reverse) {
                                  message = Stack(
                                    children: <Widget>[
                                      messagebody,
                                      !iscontract ? Positioned(right: 0, bottom: 0, child: triangle) : SizedBox(),
                                    ],
                                  );
                                } else {
                                  message = Stack(
                                    children: <Widget>[
                                      !iscontract ? Positioned(left: 0, bottom: 0, child: triangle) : SizedBox(),
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
      ),
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
