import 'dart:io';
import 'package:briddgy/models/trip.dart';
import 'package:briddgy/widgets/components.dart';
import 'package:briddgy/widgets/order_widget.dart';
import 'package:briddgy/widgets/trip_widget.dart';
import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:briddgy/localization/localization_constants.dart';
import 'package:briddgy/models/api.dart';
import 'package:briddgy/models/order.dart';
import 'package:briddgy/providers/auth.dart';
import 'package:briddgy/providers/messages.dart';
import 'package:briddgy/screens/chats_screen.dart';
import 'package:briddgy/widgets/progress_indicator_widget.dart';
import 'package:briddgy/providers/ordersandtrips.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:transparent_image/transparent_image.dart';

class OrderScreen extends StatefulWidget {
  final Order order;
  final int i;
  OrderScreen({@required this.order, @required this.i});
  static const routeName = '/orders/item';
  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  Future<List<Object>> _suggestions;
  var _current;
  Order order;
  bool messageDeliveryButton = true;
  List<Widget> imageList = [];

  bool isMine = false;

  @override
  void initState() {
    super.initState();
    order = widget.order;
    if (Provider.of<Auth>(context, listen: false).isAuth) if (order.owner.id == Provider.of<Auth>(context, listen: false).user.id) isMine = true;
    if (isMine)
      _suggestions = fetchTripSuggestions(order.source.id.toString(), order.destination.id.toString(), context);
    else
      _suggestions = fetchOrderSuggestions(order.source.id.toString(), order.destination.id.toString(), context);
    if (order.orderimage.isEmpty) {
//      imageList.add(FadeInImage.memoryNetwork(
//        placeholder: kTransparentImage,
//        image: Api.noPictureImage,
//      ));
    } else {
      for (var i = 0; i < order.orderimage.length; i++) {
        imageList.add(FadeInImage.memoryNetwork(
          placeholder: kTransparentImage,
          image: Api.storageBucket + order.orderimage[i].toString(),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            UserAppbarWidget(user: order.owner),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          if (imageList.isNotEmpty)
                            CarouselSlider(
                              options: CarouselOptions(
                                initialPage: 0,
                                enableInfiniteScroll: false,
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
                                margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 2.0),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _current == index ? Color.fromRGBO(0, 0, 0, 0.9) : Color.fromRGBO(0, 0, 0, 0.4),
                                ),
                              );
                            }).toList(),
                          ),
                          OrderInfoWidget(order: order),
                          messageDeliveryButton
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: <Widget>[
                                      Expanded(
                                        child: SizedBox(),
                                      ),
                                      if (isMine) DeleteButtonWidget(object: order) else MessageButton(context),
                                    ],
                                  ),
                                )
                              : ProgressIndicatorWidget(show: true),
                          Text(
                            isMine ? "Suggested Trips" : "Similar Orders:",
                            style: Theme.of(context).textTheme.headline6,
                          ),
                          FutureBuilder<List<Object>>(
                            future: _suggestions,
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                if (snapshot.data.length == 1 || snapshot.data.length == 0) {
                                  return Center(
                                      child: Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Column(
                                      children: [
                                        Container(
                                          height: MediaQuery.of(context).size.height * 0.2,
                                          padding: EdgeInsets.symmetric(horizontal: 40),
                                          child: SvgPicture.asset(
                                            "assets/photos/empty_order.svg",
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                          child: Text(
                                            //todo i18n
                                            "No results",
//                                    t(context, 'empty_results'),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 25,
                                              color: Colors.grey[500],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ));
                                } else
                                  for (var x in snapshot.data)
                                    if (x != order) {
                                      if (x is Trip) return TripWidget(trip: x);

                                      return OrderWidget(order: x);
                                    } else
                                      return SizedBox();
                              } else if (snapshot.hasError) {
                                return Text("${snapshot.error}");
                              }

                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            },
                          ),
                          SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  RaisedButton MessageButton(BuildContext context) {
    return RaisedButton.icon(
      padding: EdgeInsets.symmetric(horizontal: 20),
      color: Colors.green,
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0),
      ),
      icon: Icon(
        MdiIcons.chatOutline,
        color: Colors.white,
//                              color: Theme.of(context).primaryColor,
        size: 18,
      ),
      label: Text(
        " ${t(context, 'message')}",
        style: TextStyle(
          fontWeight: FontWeight.w800, color: Colors.white, fontSize: 17,
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
                    title: t(context, 'success'),
                    message: t(context, 'chat_with') + order.owner.firstName.toString() + t(context, "has_been_started"),
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
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
                    title: t(context, 'failure'),
                    message: t(context, 'please_try_again'),
                    padding: const EdgeInsets.all(8),
                    borderRadius: 10,
                    duration: Duration(seconds: 3),
                  )..show(context)
                }
            });
      },
    );
  }
}

class OrderInfoWidget extends StatelessWidget {
  OrderInfoWidget({@required this.order});
  final Order order;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: Colors.grey[300],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[500].withOpacity(.3),
            offset: Offset(2, 5),
            blurRadius: 5,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Text(
                    order.title,
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.share,
                    size: 19,
                  ),
                  onPressed: () {
                    Share.share("${t(context, 'earn')}\$" +
                        order.price.toString() +
                        " ${t(context, 'by_delivering')}" +
                        order.title +
                        "\n" +
                        Api.orderLink +
                        order.id.toString());
                  },
                ),
              ],
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t(context, 'from'),
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      order.source.cityAscii,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      order.source.country,
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                Icon(
                  MdiIcons.bagChecked,
                  color: Colors.grey[700],
                  size: 30,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      t(context, 'to'),
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      order.destination.cityAscii,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      order.destination.country,
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                )
              ],
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Icon(
                        Icons.date_range,
                        size: 20,
                        color: Colors.grey[700],
                      ),
                      Text(
                        t(context, 'posted_on'),
                        style: TextStyle(fontSize: 14),
                      ),
                      Text(
                        DateFormat("d MMM yyy").format(order.date),
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Icon(
                        MdiIcons.weightKilogram,
                        size: 20,
                        color: Colors.grey[700],
                      ),
                      Text(
                        t(context, 'weight'),
                        style: TextStyle(fontSize: 14),
                      ),
                      Text(
                        order.weight.toString() + " ${t(context, 'kg')}",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Icon(
                        MdiIcons.currencyUsdCircleOutline,
                        size: 20,
                        color: Colors.grey[700],
                      ),
                      Text(
                        t(context, 'reward'),
                        style: TextStyle(fontSize: 14),
                      ),
                      Text(
                        order.price.toString() + ' \$',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 2.0),
              child: Text(
                order.description,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 15,
                  height: 1.1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
