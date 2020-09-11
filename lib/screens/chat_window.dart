import 'dart:async';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:briddgy/localization/localization_constants.dart';
import 'package:briddgy/models/api.dart';
import 'package:briddgy/models/message.dart';
import 'package:briddgy/models/order.dart';
import 'package:briddgy/models/trip.dart';
import 'package:briddgy/models/user.dart';
import 'package:briddgy/providers/auth.dart';
import 'package:briddgy/screens/new_contract_screen.dart';
import 'package:briddgy/screens/profile_screen.dart';
import 'package:briddgy/screens/verify_phone_screen.dart';
import 'package:briddgy/widgets/generators.dart';
import 'package:briddgy/widgets/progress_indicator_widget.dart';
import 'package:web_socket_channel/io.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:briddgy/providers/messages.dart';
import 'package:menu/menu.dart';
import 'dart:convert';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'add_order_screen.dart';

Order _order;
Trip _trip;
User _requestingUser;

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
  var contract;
  bool firstEntry = true;
  final String phpEndPoint = 'http://192.168.43.171/phpAPI/image.php';
  final String nodeEndPoint = 'http://192.168.43.171:3000/image';
  @override
  void initState() {
    textEditingController = TextEditingController();
    scrollController = ScrollController();
    id = widget.room.id.toString();
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
      _channelRoom.stream
          .listen(
        _onReceptionOfMessageFromServer,
      )
          .onDone(() {
        reset();
        initCommunication(id);
      });
      print("Room Socket Connected");
    } catch (e) {
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


  void readMessageSockets(text){
    if (_channelRoom != null) {
        if (_channelRoom.sink != null) {
          try {
            _channelRoom.sink.add(text);
          } catch (e) {
    
          }   
        }
    }
  }

  void handleSendMessage() {
    var text = textEditingController.value.text.trim();
     if(text.length!=0){
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
          try {
            _channelRoom.sink.add(text);
          } catch (e) {
    
          }
          // widget.provider.messages[id].insert(0, tempMessage);
          // widget.provider.changeChatRoomPlace(id);
        }
      } catch (e) {

      }
    }

    setState(() {
      _messages.insert(0, tempMessage);
    });
    widget.provider.changeLastMessage(id,tempMessage.text);

  }
  }

  var triangle = CustomPaint(
    painter: Triangle(),
  );

  void _choose() async {
    file = await ImagePicker.pickImage(source: ImageSource.camera, maxHeight: 400, maxWidth: 400);
    //file = await ImagePicker.pickImage(source: ImageSource.gallery);
  }

  void _upload() {
    if (file == null) return;
    String base64Image = base64Encode(file.readAsBytesSync());
    String fileName = file.path.split("/").last;
  }

  Future<bool> _onWillPop() async {
    widget.provider.messages[widget.room.id.id]["data"] = _messages;
    widget.provider.isChatRoomPageActive = false;
    widget.provider.changeChatRoomPlace("ChangewithList");
    widget.provider.notifFun();
    return true;
  }

  void contractMessage() {
    var tempMessage = Message.fromJson({
      "id": 200,
      "date_created": DateTime.now().toString(),
      "date_modified": DateTime.now().toString(),
      "text": widget.provider.contractBody.toString(),
      "sender": widget.auth.user.id,
      "recipients": []
    });

    if (_channelRoom != null) {
      try {
        if (_channelRoom.sink != null) {
          _channelRoom.sink.add(widget.provider.contractBody);
          widget.provider.changeChatRoomPlace(id);
          widget.provider.contractBody = "";
        }
      } catch (e) {

      }
    }
    if (widget.provider.messages[widget.room.id] == null) {
      List<Message> temp = [];
      temp.add(tempMessage);
      widget.provider.messages[widget.room.id] = {"next": null, "data": temp};
    } else {
      widget.provider.messages[widget.room.id]["data"].insert(0, tempMessage);
    }
    widget.provider.changeLastMessage(id,"Contract");

  }

  @override
  Widget build(BuildContext context) {
    if(firstEntry){
      firstEntry = false;
        var a = json.encode({
        "briddgy_message_field_for_online":"True",
        "user_id":me.id,
        "room_id":id
      });
      Timer(Duration(milliseconds: 300), () {
        readMessageSockets(a);
      });
    }   

    if (widget.provider.isChatRoomPageActive == false) {
      widget.provider.isChatRoomPageActive = true;
      widget.provider.roomIDofActiveChatroom = id;
    }
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
                hintText: t(context, 'type_message'),
              ),
              controller: textEditingController,
            ),
          ),
        ),
        enableButton && !widget.provider.messagesLoading
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

          if (widget.provider.messages[widget.room.id] != null && !messageLoader) {
            if (widget.provider.messages[widget.room.id].isNotEmpty) {
              var a = json.encode({
                "briddgy_message_field_for_online":"True",
                "user_id":me.id,
                "room_id":id
              });
              readMessageSockets(a);
              _messages = widget.provider.messages[widget.room.id]["data"];
              if (nextMessagesURL == "FirstCall") {
                nextMessagesURL = widget.provider.messages[widget.room.id]["next"];
              }
              messageLoader = false;
            } else {
              messageLoader = true;
            }
          }
          if (widget.provider.contractBody != "") contractMessage();
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
                                builder: (__) => ProfileScreen(
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
                                widget.provider.messages[widget.room.id]["data"] = _messages;
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
                                      widget.user.online
                                          ? Icon(
                                              MdiIcons.circle,
                                              color: Colors.green,
                                              size: 14,
                                            )
                                          : Icon(
                                              MdiIcons.circle,
                                              color: Colors.grey[600],
                                              size: 14,
                                            ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                    child: widget.user.online
                                        ? Text(
                                            ('online'),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.green[500],
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          )
                                        : Text(
                                            t(context, 'last_online') + DateFormat.yMMMd().format(widget.user.lastOnline),
                                            style: TextStyle(
                                              color: Colors.grey[500],
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
                              child: imageUrlUser == Api.noPictureImage
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
                        : Stack(
                            children: [
                              NotificationListener<ScrollNotification>(
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
                                    } catch (e) {
                              
                                      iscontract=false;
                                    }


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
                                            child: imageUrlUser == Api.noPictureImage
                                                ? InitialsAvatarWidget(widget.user.firstName.toString(), widget.user.lastName.toString(), 50.0)
                                                : ClipRRect(
                                                    borderRadius: BorderRadius.circular(25.0),
                                                    child: Image.network(
                                                      imageUrlUser,
                                                      errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
                                                        return InitialsAvatarWidget(
                                                            widget.user.firstName.toString(), widget.user.lastName.toString(), 50.0);
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
                                    if (iscontract) {
                                      contract = json.decode(_messages[index].text);
                                      if (contract["type"] == "trip") {
                                        _order = Order.fromJson(contract["opp"]);
                                        _trip = Trip.fromJson(contract["my"]);
                                        _requestingUser = _trip.owner;
                                      } else {
                                        _order = Order.fromJson(contract["my"]);
                                        _trip = Trip.fromJson(contract["opp"]);
                                        _requestingUser = _order.owner;
                                      }
                                    }
                                    //For Rasul
                                    //use order and trip for filling below
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
                                              MenuItem(t(context, 'info'), () {
                                                Alert(
                                                  context: context,
                                                  type: AlertType.info,
                                                  title: t(context, 'sent_on') +
                                                      _messages[index].dateCreated.toString().substring(0, 10) +
                                                      ",  " +
                                                      _messages[index].dateCreated.toString().substring(11, 16) +
                                                      "\n",
                                                  buttons: [
                                                    DialogButton(
                                                      child: Text(
                                                        t(context, 'back'),
                                                        style: TextStyle(color: Colors.white, fontSize: 20),
                                                      ),
                                                      onPressed: () => Navigator.pop(context),
                                                      color: Color.fromRGBO(0, 179, 134, 1.0),
                                                    ),
                                                    DialogButton(
                                                      child: Text(
                                                        t(context, 'report'),
                                                        style: TextStyle(color: Colors.white, fontSize: 20),
                                                      ),
                                                      onPressed: () => {},
                                                      color: Color.fromRGBO(0, 179, 134, 1.0),
                                                    )
                                                  ],
                                                  content: Text(t(context, 'chats_cant_be_deleted')),
                                                ).show();
                                              }),
                                            ],
                                            decoration: MenuDecoration(),
                                          )
                                        : Container(
                                            width: MediaQuery.of(context).size.width,
                                            child: Row(
                                              children: [
                                                Expanded(child: SizedBox()),
                                                Container(
                                                  width: MediaQuery.of(context).size.width * 0.8,
                                                  padding: EdgeInsets.all(20),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[200],
//                                          color: Theme.of(context).scaffoldBackgroundColor,
                                                    borderRadius: BorderRadius.circular(10),
                                                    border: Border.all(color: Colors.grey[500]),
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      Padding(
                                                        padding: const EdgeInsets.symmetric(vertical: 4),
                                                        child: SvgPicture.asset(
                                                          "assets/photos/handshake.svg",
                                                          height: 100,
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets.all(8.0),
                                                        child: Text(
                                                          t(context, 'contract_details'),
                                                          style: TextStyle(
                                                            fontSize: 22,
                                                            color: Theme.of(context).primaryColor,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                      Row(
                                                        children: <Widget>[
                                                          Text(
                                                            t(context, 'contract_proposed_by'),
                                                            style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                                                          ),
                                                          Expanded(
                                                            child: SizedBox(
                                                              height: 1,
                                                            ),
                                                          ),
                                                          Text(
                                                            " ${_order.owner.firstName} ${_order.owner.lastName}",
                                                            style: TextStyle(fontSize: 15),
                                                          ),
                                                        ],
                                                      ),
                                                      Row(
                                                        children: <Widget>[
                                                          Text(
                                                            t(context, 'order_owner'),
                                                            style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                                                          ),
                                                          Expanded(child: SizedBox()),
                                                          Text(
                                                            " ${_order.owner.firstName} ${_order.owner.lastName}",
                                                            style: TextStyle(fontSize: 15),
                                                          ),
                                                        ],
                                                      ),
                                                      Row(
                                                        children: <Widget>[
                                                          Text(
                                                            "${t(context, 'order')}: ",
                                                            style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                                                          ),
                                                          Expanded(
                                                            child: SizedBox(),
                                                          ),
                                                          Expanded(
                                                            child: Text(
                                                              _order.title,
                                                              style: TextStyle(fontSize: 15),
                                                              textAlign: TextAlign.end,
                                                              softWrap: false,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Row(
                                                        children: <Widget>[
                                                          Text(
                                                            "${t(context, 'deliverer')}: ",
                                                            style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                                                          ),
                                                          Expanded(child: SizedBox()),
                                                          Text(
                                                            " ${_trip.owner.firstName} ${_trip.owner.lastName}",
                                                            style: TextStyle(fontSize: 15),
                                                          ),
                                                        ],
                                                      ),
                                                      Row(
                                                        children: <Widget>[
                                                          Text(
                                                            "${t(context, 'from')}:",
                                                            style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                                                          ),
                                                          Expanded(child: SizedBox()),
                                                          Text(
                                                            " ${_trip.source.cityAscii}",
                                                            style: TextStyle(fontSize: 15),
                                                          ),
                                                        ],
                                                      ),
                                                      Row(
                                                        children: <Widget>[
                                                          Text(
                                                            "${t(context, 'to')}:",
                                                            style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                                                          ),
                                                          Expanded(child: SizedBox()),
                                                          Text(
                                                            "${_trip.destination.cityAscii}",
                                                            style: TextStyle(fontSize: 15),
                                                          ),
                                                        ],
                                                      ),
                                                      Row(
                                                        children: <Widget>[
                                                          Text(
                                                            "${t(context, 'trip_date')}:",
                                                            style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                                                          ),
                                                          Expanded(child: SizedBox()),
                                                          Text(
                                                            DateFormat('d MMM yyyy').format(_trip.date),
                                                            style: TextStyle(fontSize: 15),
                                                          ),
                                                        ],
                                                      ),
                                                      Row(
                                                        children: <Widget>[
                                                          Text(
                                                            "${t(context, 'reward')}:",
                                                            style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                                                          ),
                                                          Expanded(child: SizedBox()),
                                                          Text(
                                                            "\$${_order.price}",
                                                            style: TextStyle(fontSize: 15),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(height: 5),
                                                      if (contract["complete"] == null)
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                          children: [
                                                            RaisedButton(
                                                              color: Colors.white,
                                                              child: Text(
                                                                t(context, 'reject'),
                                                                style: TextStyle(color: Colors.red),
                                                              ),
                                                              onPressed: () {
                                                                //todo orxan reject
                                                              },
                                                            ),
                                                            RaisedButton(
                                                              color: Colors.blue,
                                                              child: Text(
                                                                t(context, 'accept'),
                                                                style: TextStyle(color: Colors.white),
                                                              ),
                                                              onPressed: () {
                                                                final url = Api.applyForDelivery;
                                                                http
                                                                    .put(
                                                                  url,
                                                                  headers: {
                                                                    HttpHeaders.contentTypeHeader: "application/json",
                                                                    "Authorization":
                                                                        "Token " + Provider.of<Auth>(context, listen: false).myTokenFromStorage,
                                                                  },
                                                                  body: json.encode(
                                                                    {'order': _order.id, 'trip': _trip.id, 'idOfmessage': _messages[index].id},
                                                                  ),
                                                                )
                                                                    .then((response) {
                                                                  if (response.statusCode == 200) {
                                                                    print("Accepted");
                                                                    //todo Rasul
                                                                    // need to show that contract approved or how?

                                                                  } else {
                                                                    //todo Rasul
                                                                    // Here show an error message how you want
                                                                    // use  below code to give detailed

                                                                    print(json.decode(response.body)["detail"]);
                                                                  }
                                                                });
                                                              },
                                                            ),
                                                          ],
                                                        )
                                                      else
                                                        Row(
                                                          children: [
                                                            Expanded(child: SizedBox()),
                                                            Text(
                                                              "Contract Accepted",
                                                              style: TextStyle(color: Colors.green),
                                                            ),
                                                            Icon(Icons.check, color: Colors.green),
                                                          ],
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                                Expanded(child: SizedBox()),
                                              ],
                                            ),
                                          );

                                    Widget message;

                                    if (!iscontract) {
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
                                    } else {
                                      message = messagebody;
                                    }

                                    if (reverse) {
                                      return Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: <Widget>[
                                          Padding(
                                            padding: EdgeInsets.all(!iscontract ? 8.0 : 0),
                                            child: message,
                                          ),
                                          if (!iscontract) avatar,
                                        ],
                                      );
                                    } else {
                                      return Row(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: <Widget>[
                                          if (!iscontract) avatar,
                                          Padding(
                                            padding: EdgeInsets.all(!iscontract ? 8.0 : 0),
                                            child: message,
                                          ),
                                        ],
                                      );
                                    }
                                  },
                                ),
                              ),
                              Align(
                                alignment: Alignment.topCenter,
                                child: OpenContainer(
                                  openElevation: 5,
                                  transitionDuration: Duration(milliseconds: 500),
                                  transitionType: ContainerTransitionType.fadeThrough,
                                  openBuilder: (BuildContext context, VoidCallback _) {
                                    return me.isNumberVerified ? NewContactScreen(widget.user) : VerifyPhoneScreen();
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
                                            t(context, 'propose_contract'),
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
                              ),
                            ],
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
