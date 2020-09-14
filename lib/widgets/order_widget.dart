import 'dart:io';
import 'package:briddgy/localization/localization_constants.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:briddgy/models/api.dart';
import 'package:briddgy/models/order.dart';
import 'package:briddgy/providers/auth.dart';
import 'package:briddgy/providers/ordersandtrips.dart';
import 'package:briddgy/screens/order_screen.dart';
import 'package:provider/provider.dart';

class OrderWidget extends StatefulWidget {
  final Order order;
  final int i;
  final bool modeProfile;
  OrderWidget({@required this.order, @required this.i, this.modeProfile = false});

  @override
  _OrderWidgetState createState() => _OrderWidgetState();
}

class _OrderWidgetState extends State<OrderWidget> {
  Order order;
  var imageUrl;
  var i;
  @override
  void initState() {
    i = widget.i;
    order = widget.order;
    imageUrl = order.orderimage.isEmpty ? Api.noPictureImage : Api.storageBucket + order.orderimage[0].toString();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (__) => OrderScreen(
              order: order,
              i: i,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Card(
          child: Row(
            children: <Widget>[
              SizedBox(width: 5),
              widget.modeProfile
                  ? Container(
                      width: 80,
                      child: Column(
                        children: order.trip == null
                            ? [
                                SvgPicture.asset(
                                  "assets/photos/empty_order.svg",
                                  fit: BoxFit.fitHeight,
                                  height: 50,
                                ),
                                Text(
                                  "No Contract",
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.grey[800]),
                                  textAlign: TextAlign.center,
                                ),
                              ]
                            : [
                                SvgPicture.asset(
                                  "assets/photos/handshake.svg",
                                  fit: BoxFit.fitHeight,
                                  height: 50,
                                ),
                                Text(
                                  "Contract Settled",
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.grey[800]),
                                  textAlign: TextAlign.center,
                                )
                              ],
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(5.0),
                      child: Image.network(
                        imageUrl,
                        errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
                          return SizedBox();
                        },
                        height: 80,
                        width: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
              Container(
                margin: const EdgeInsets.only(left: 5),
                color: Colors.grey[200],
                width: 1,
                height: 80,
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              order.title,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Divider(
                        height: 5,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
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
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
//                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                Text(
                                  order.source.country,
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            MdiIcons.bagChecked,
//                            color: Theme.of(context).primaryColor,
                            color: Colors.grey[700],

                            size: 30,
                          ),
                          Expanded(
                            child: Column(
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
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
//                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                Text(
                                  order.destination.country,
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
//                                Text(
//                                  t(context, 'weight'),
//                                ),
                          Text(
                            order.weight.toString() + " " + t(context, 'kg'),
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                          ),
//                          Icon(
//                            MdiIcons.weightKilogram,
//                            size: 20,
//                            color: Colors.grey[700],
//                          ),
                          Spacer(),

//                                Text(
//                                  t(context, 'reward'),
//                                  style: TextStyle(fontSize: 14),
//                                ),
                          Text(
                            order.price.toString() + ' \$',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                          ),
//                          Icon(
//                            MdiIcons.currencyUsdCircleOutline,
//                            size: 20,
//                            color: Colors.grey[700],
////                            color: Colors.amber,
//                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
//                Expanded(
//                  child: Padding(
//                    padding: const EdgeInsets.symmetric(vertical: 4.0),
//                    child: Column(
//                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                      crossAxisAlignment: CrossAxisAlignment.start,
//                      children: <Widget>[
//                        SizedBox(
//                          child: Text(
//                            order.title,
//                            overflow: TextOverflow.ellipsis,
//                            maxLines: 1,
//                            style: TextStyle(
//                              fontSize: 20,
//                              color: Colors.grey[800],
//                            ),
//                          ),
//                        ),
//                        Row(
//                          mainAxisAlignment: MainAxisAlignment.start,
//                          children: <Widget>[
//                            Icon(
//                              MdiIcons.mapMarkerMultipleOutline,
////                            color: Colors.grey[700],
//                              color: Theme.of(context).primaryColor,
//                              size: 16,
//                            ),
//                            Expanded(
//                              child: Text(
//                                order.source.cityAscii +
//                                    ", " +
//                                    order.source.country.substring(0, 3) +
//                                    "  -  " +
//                                    order.destination.cityAscii +
//                                    ", " +
//                                    order.destination.country,
//                                softWrap: false,
//                                overflow: TextOverflow.fade,
//                                style: TextStyle(fontSize: 15, color: Colors.grey[600], fontWeight: FontWeight.normal),
//                              ),
//                            ),
//                          ],
//                        ),
//                        Row(
//                          mainAxisAlignment: MainAxisAlignment.spaceAround,
//                          children: <Widget>[
//                            Icon(
//                              MdiIcons.calendarRange,
//                              color: Theme.of(context).primaryColor,
//                              size: 16,
//                            ),
//                            Text(
//                              DateFormat("d MMM yyy").format(order.date),
//                              style: TextStyle(color: Colors.grey[600]),
//                            ),
//                            Spacer(),
//                            Icon(
//                              MdiIcons.weightKilogram,
//                              color: Theme.of(context).primaryColor,
//                              size: 16,
//                            ),
//                            SizedBox(
//                              width: 50,
//                              child: Text(
//                                order.weight.toString(),
//                                maxLines: 1,
//                                style: TextStyle(color: Colors.grey[600]),
//                              ),
//                            ),
//                            Spacer(),
//                            Icon(
//                              Icons.attach_money,
//                              color: Theme.of(context).primaryColor,
//                              size: 16,
//                            ),
//                            Text(
//                              order.price.toString(),
//                              maxLines: 1,
//                              style: TextStyle(color: Colors.grey[600]),
//                            ),
//                          ],
//                        ),
//                      ],
//                    ),
//                  ),
//                ),
            ],
          ),
        ),
      ),
    );
  }
}

class OrderSimpleWidget extends StatefulWidget {
  Order order;
  var i;
  OrderSimpleWidget({@required this.order, @required this.i});

  @override
  _OrderSimpleWidgetState createState() => _OrderSimpleWidgetState();
}

class _OrderSimpleWidgetState extends State<OrderSimpleWidget> {
  Order order;
  var imageUrl;
  var i;
  @override
  void initState() {
    i = widget.i;
    order = widget.order;
    imageUrl = order.orderimage.isEmpty ? Api.noPictureImage : Api.storageBucket + order.orderimage[0].toString();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (__) => OrderScreen(order: order),
          ),
        );
      },
      child: Column(
        children: <Widget>[
          Container(
            height: 100,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(
              children: <Widget>[
                Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(25.0),
                      child: Image.network(
                        imageUrl,
                        errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
                          return SizedBox();
                        },
                        height: 80,
                        width: 80,
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                  ],
                ),
//                CircleAvatar(
//                  radius: 40,
//                  backgroundColor: Colors.grey[100],
//                  backgroundImage: NetworkImage(
//                    imageUrl,
//                  ),
//                  onBackgroundImageError: (exception, stackTrace) {
//                    imageUrl = Api.noPictureImage;
//                  },
//                ),
                // Container(
                //   child: FadeInImage.memoryNetwork(
                //     placeholder: kTransparentImage,
                //     image:
                //         'https://images-na.ssl-images-amazon.com/images/I/81NIli1PuqL._AC_SL1500_.jpg',
                //   ),
                // ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        width: 200,
                        child: Text(
                          order.title,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.grey[800],
//                                          fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Icon(
                            MdiIcons.mapMarkerMultipleOutline,
//                            color: Colors.grey[700],
                            color: Theme.of(context).primaryColor,
                            size: 16,
                          ),
                          SizedBox(
                            width: 200,
                            child: Text(
                              order.source.cityAscii + "  -  " + order.destination.cityAscii,
                              maxLines: 1,
                              style: TextStyle(fontSize: 15, color: Colors.grey[600], fontWeight: FontWeight.normal),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Icon(
                            MdiIcons.calendarRange,
                            color: Theme.of(context).primaryColor,
                            size: 16,
                          ),
                          Text(
                            DateFormat("d MMMM").format(order.date),
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          Spacer(),
                          Icon(
                            Icons.attach_money,
                            color: Theme.of(context).primaryColor,
                            size: 16,
                          ),
                          SizedBox(
                            width: 50,
                            child: Text(
                              order.price.toString(),
                              maxLines: 1,
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Divider(
              height: 4,
              color: Colors.black45,
            ),
          ),
        ],
      ),
    );
  }
}

class OrderFadeWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          height: 100,
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Row(
            children: <Widget>[
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.grey[300],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      width: 200,
                      height: 10,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.grey[200],
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Icon(
                          MdiIcons.mapMarkerMultipleOutline,
                          color: Colors.grey[200],
                          size: 16,
                        ),
                        SizedBox(
                          width: 200,
                          height: 10,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.grey[200],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
//                                        mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Icon(
                              MdiIcons.calendarRange,
                              color: Colors.grey[200],
                              size: 16,
                            ),
                            Container(
                              height: 10,
                              width: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.grey[200],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          width: 50,
                        ),
                        Row(
                          children: <Widget>[
                            Icon(
                              Icons.attach_money,
                              color: Colors.grey[200],
                              size: 16,
                            ),
                            SizedBox(
                              width: 50,
                              height: 10,
                              child: Container(
                                width: 60,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.grey[200],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Divider(
            height: 4,
            color: Colors.black45,
          ),
        ),
      ],
    );
  }
}
