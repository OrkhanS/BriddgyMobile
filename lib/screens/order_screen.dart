import 'dart:io';
import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:optisend/models/api.dart';
import 'package:optisend/models/order.dart';
import 'package:optisend/providers/auth.dart';
import 'package:optisend/providers/messages.dart';
import 'package:optisend/screens/chats_screen.dart';
import 'package:optisend/screens/profile_screen_another.dart';
import 'package:optisend/widgets/progress_indicator_widget.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import '../main.dart';
import 'package:transparent_image/transparent_image.dart';

class OrderScreen extends StatefulWidget {
  Order order;
  OrderScreen({this.order});
  static const routeName = '/orders/item';
  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  var _current;
  Order order;
  var imageUrl;
  bool messageDeliveryButton = true;
  List<Widget> imageList = [];
  @override
  void initState() {
    order = widget.order;
    if (order.orderimage.isEmpty) {
      imageList.add(FadeInImage.memoryNetwork(
        placeholder: kTransparentImage,
        image: 'https://cdn2.iconfinder.com/data/icons/outlined-set-1/29/no_camera-512.png',
      ));
    } else {
      for (var i = 0; i < order.orderimage.length; i++) {
        imageList.add(FadeInImage.memoryNetwork(
          placeholder: kTransparentImage,
          image: "https://storage.googleapis.com/briddgy-media/" + order.orderimage[i].toString(),
        ));
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 4),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (__) => ProfileScreenAnother(
                              user: order.owner,
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
                                  order.owner.firstName + " " + order.owner.lastName,
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
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
                              "Last online " + DateFormat.yMMMd().format(order.owner.lastOnline),
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
                      child: Stack(
                        children: <Widget>[
                          CircleAvatar(
                            radius: 35,
                            backgroundColor: Colors.grey[100],
                            backgroundImage: NetworkImage(
                              "https://cdn2.iconfinder.com/data/icons/outlined-set-1/29/no_camera-512.png",
                            ),
                          ),
                          Positioned(
                            left: 0,
                            bottom: 5,
                            child: Container(
                              width: 35,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Color.fromRGBO(255, 255, 255, 80),
                                border: Border.all(color: Colors.green, width: 1),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(20),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  Icon(
                                    Icons.star,
                                    size: 12,
                                    color: Colors.green,
                                  ),
                                  Text(
                                    order.owner.rating.toString(),
                                    style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
//            Padding(
//              padding: EdgeInsets.symmetric(horizontal: 10),
//              child: AppBar(
//                backgroundColor: Colors.white,
//                centerTitle: true,
//                leading: IconButton(
//                  color: Theme.of(context).primaryColor,
//                  icon: Icon(
//                    Icons.chevron_left,
//                    size: 24,
//                  ),
//                  onPressed: () {
//                    Navigator.of(context).pop();
//                  },
//                ),
//                title: Text(
//                  order.title.toString(),
//                  style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
//                ),
//                elevation: 1,
//              ),
//            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          CarouselSlider(
                            options: CarouselOptions(
                              height: 380,
                              initialPage: 0,
                              enableInfiniteScroll: true,
                              reverse: false,
                              autoPlay: true,
                              autoPlayInterval: Duration(seconds: 5),
                              autoPlayAnimationDuration: Duration(milliseconds: 800),
                              autoPlayCurve: Curves.fastOutSlowIn,
                              enlargeCenterPage: true,
                              onPageChanged: (index, reason) {
                                setState(() {
                                  _current = index;
                                });
                              },
                              scrollDirection: Axis.horizontal,
                            ),
                            items: imageList,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: imageList.map((url) {
                              int index = imageList.indexOf(url);
                              return Container(
                                width: 8.0,
                                height: 8.0,
                                margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _current == index ? Color.fromRGBO(0, 0, 0, 0.9) : Color.fromRGBO(0, 0, 0, 0.4),
                                ),
                              );
                            }).toList(),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                order.title,
                                style: TextStyle(
                                  fontSize: 22,
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.share),
                                onPressed: () {
                                  Share.share("Earn \$" +
                                      order.price.toString() +
                                      " by delivering " +
                                      order.title +
                                      "\n" +
                                      Api.orderLink +
                                      order.id.toString());
                                },
                              ),
                            ],
                          ),
                          Divider(),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 4,
                            ),
                            child: Row(
                              children: <Widget>[
                                Text(
                                  "Departure city:",
                                  style: TextStyle(
                                    fontSize: 17,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Expanded(
                                  child: SizedBox(
                                    height: 1,
                                  ),
                                ),
                                Text(
                                  order.source.cityAscii,
                                  style: TextStyle(fontSize: 18),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 4,
                            ),
                            child: Row(
                              children: <Widget>[
                                Text(
                                  "Arrival city:",
                                  style: TextStyle(
                                    fontSize: 17,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Expanded(
                                  child: SizedBox(
                                    height: 1,
                                  ),
                                ),
                                Text(
                                  order.destination.cityAscii,
                                  style: TextStyle(fontSize: 18),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 4,
                            ),
                            child: Row(
                              children: <Widget>[
                                Text(
                                  "Request date:",
                                  style: TextStyle(fontSize: 17, color: Colors.grey[600]),
                                ),
                                Expanded(
                                  child: SizedBox(
                                    height: 1,
                                  ),
                                ),
                                Text(
                                  DateFormat.yMMMd().format(order.date),
                                  style: TextStyle(fontSize: 18),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 4,
                            ),
                            child: Row(
                              children: <Widget>[
                                Text(
                                  "Weight:",
                                  style: TextStyle(
                                    fontSize: 17,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Expanded(
                                  child: SizedBox(
                                    height: 1,
                                  ),
                                ),
                                Text(
                                  order.weight.toString() + " kg",
                                  style: TextStyle(fontSize: 18),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 4,
                            ),
                            child: Row(
                              children: <Widget>[
                                Text(
                                  "Item cost:",
                                  style: TextStyle(
                                    fontSize: 17,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Expanded(
                                  child: SizedBox(
                                    height: 1,
                                  ),
                                ),
                                Text(
                                  order.price.toString() + ' \$',
                                  style: TextStyle(fontSize: 18),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              children: <Widget>[
                                Text(
                                  "Description",
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Divider(),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 15.0),
                            child: Text(
                              order.description,
                              style: TextStyle(fontSize: 17),
                            ),
                          ),
                        ],
                      ),
                    ),
                    messageDeliveryButton
                        ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                RaisedButton.icon(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
//                            color: Theme.of(context).scaffoldBackgroundColor,
                                  color: Colors.white,

                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                  ),
                                  icon: Icon(
                                    MdiIcons.scriptTextOutline,
//                              color: Colors.white,
                                    color: Theme.of(context).primaryColor,
                                    size: 18,
                                  ),
                                  label: Text(
                                    " Apply for Delivery",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
//                                color: Colors.white,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  onPressed: () {
//                               var auth =
//                                   Provider.of<Auth>(context, listen: false);
//                               Provider.of<Messages>(context, listen: false)
//                                   .createRooms(order.owner.id, auth);
// //                                Flushbar(
// //                                  title: "Chat with " + trip.owner.firstName.toString() + " has been started!",
// //                                  message: "Check Chats to see more.",
// //                                  padding: const EdgeInsets.all(8),
// //                                  borderRadius: 10,
// //                                  duration: Duration(seconds: 5),
// //                                )..show(context);
                                  },
                                ),
                                RaisedButton.icon(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
//                            color: Theme.of(context).scaffoldBackgroundColor,
                                  color: Colors.green,

                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                  ),
                                  icon: Icon(
                                    MdiIcons.chatOutline,
                                    color: Colors.white,
//                              color: Theme.of(context).primaryColor,
                                    size: 18,
                                  ),
                                  label: Text(
                                    " Message",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
//                                    color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      messageDeliveryButton = false;
                                    });
                                    var auth = Provider.of<Auth>(context, listen: false);
                                    var messageProvider = Provider.of<Messages>(context, listen: false);

                                    messageProvider.createRooms(order.owner.id, auth).whenComplete(() => {
                                          if (messageProvider.isChatRoomCreated)
                                            {
                                              setState(() {
                                                messageDeliveryButton = true;
                                              }),
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(builder: (__) => ChatsScreen(provider: messageProvider, auth: auth)),
                                              ),
                                              Flushbar(
                                                title: "Success",
                                                message: "Chat with " + order.owner.firstName.toString() + " has been started!",
                                                padding: const EdgeInsets.all(8),
                                                borderRadius: 10,
                                                duration: Duration(seconds: 3),
                                              )..show(context)
                                            }
                                          else
                                            {
                                              setState(() {
                                                messageDeliveryButton = true;
                                              }),
                                              Flushbar(
                                                title: "Failure",
                                                message: "Please try again",
                                                padding: const EdgeInsets.all(8),
                                                borderRadius: 10,
                                                duration: Duration(seconds: 3),
                                              )..show(context)
                                            }
                                        });
                                  },
                                ),
                              ],
                            ),
                          )
                        : ProgressIndicatorWidget(show: true),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _current {}
