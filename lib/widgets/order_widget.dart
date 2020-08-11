import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:optisend/models/order.dart';
import 'package:optisend/screens/item_screen.dart';
import 'package:transparent_image/transparent_image.dart';

class OrderWidget extends StatefulWidget {
  Order order;
  var i;
  OrderWidget({@required this.order, @required this.i});

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
    imageUrl = order.orderimage.isEmpty
        ? 'https://st4.depositphotos.com/14953852/22772/v/450/depositphotos_227725020-stock-illustration-image-available-icon-flat-vector.jpg'
        : "https://storage.googleapis.com/briddgy-media/" +
            order.orderimage[0].toString();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (__) => ItemScreen(order: order),
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
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: NetworkImage(
                    imageUrl,
                  ),
                  onBackgroundImageError: (exception, stackTrace) {
                    imageUrl =
                        'https://st4.depositphotos.com/14953852/22772/v/450/depositphotos_227725020-stock-illustration-image-available-icon-flat-vector.jpg';
                  },
                ),
                // Container(
                //   child: FadeInImage.memoryNetwork(
                //     placeholder: kTransparentImage,
                //     image:
                //         'https://images-na.ssl-images-amazon.com/images/I/81NIli1PuqL._AC_SL1500_.jpg',
                //   ),
                // ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 4.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        width: 200,
                        child: Text(
//                                                    _orders[i]["title"].toString().length > 20
//                                                        ? _orders[i]["title"].toString().substring(0, 20) + "..."
//                                                        :
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
                            color: Theme.of(context).primaryColor,
                            size: 16,
                          ),
                          SizedBox(
                            width: 200,
                            child: Text(
                              order.source.cityAscii +
                                  "  >  " +
                                  order.destination.cityAscii,
                              maxLines: 1,
                              style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.normal),
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
                                color: Theme.of(context).primaryColor,
                                size: 16,
                              ),
                              Text(
                                DateFormat.yMMMd().format(order.date),
                                style: TextStyle(color: Colors.grey[600]),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
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
