import 'dart:io';
import 'package:flushbar/flushbar.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:briddgy/models/api.dart';
import 'package:briddgy/models/order.dart';
import 'package:briddgy/models/review.dart';
import 'package:briddgy/providers/auth.dart';
import 'package:briddgy/providers/ordersandtrips.dart';
import 'package:briddgy/screens/order_screen.dart';
import 'package:provider/provider.dart';
import 'package:transparent_image/transparent_image.dart';

class ReviewWidget extends StatefulWidget {
  final Review review;
  ReviewWidget({@required this.review});

  @override
  _ReviewWidgetState createState() => _ReviewWidgetState();
}

class _ReviewWidgetState extends State<ReviewWidget> {
  Review review;

  var imageUrl;
  @override
  void initState() {
    review = widget.review;
    imageUrl = review.reviewFrom.avatarpic == null ? Api.noPictureImage : Api.storageBucket + review.reviewFrom.avatarpic.toString();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Row(
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(25.0),
                child: Image.network(
                  imageUrl,
                  errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
                    return SizedBox();
                  },
                  height: 50,
                  width: 50,
                  fit: BoxFit.fitWidth,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        review.reviewFrom.firstName + " " + review.reviewFrom.lastName,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[800],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        review.comment,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
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
                              order.source.cityAscii + "  >  " + order.destination.cityAscii,
                              maxLines: 1,
                              style: TextStyle(fontSize: 15, color: Colors.grey[600], fontWeight: FontWeight.normal),
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
//                                color: Colors.grey[700],
                                color: Theme.of(context).primaryColor,
                                size: 16,
                              ),
                              Text(
                                DateFormat("d MMMM").format(order.date),
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          SizedBox(
                            width: 100,
                          ),
                          Row(
                            children: <Widget>[
                              Icon(
                                Icons.attach_money,
//                                color: Colors.grey[700],
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