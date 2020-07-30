import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:optisend/models/api.dart';
import 'package:optisend/models/order.dart';
import '../main.dart';

class ItemScreen extends StatefulWidget {
  Order order;
  ItemScreen({this.order});
  static const routeName = '/orders/item';
  @override
  _ItemScreenState createState() => _ItemScreenState();
}

class _ItemScreenState extends State<ItemScreen> {
  Order order;
  @override
  void initState() {
    order = widget.order;
    super.initState();
  }

//todo orxan
//  Future createRooms() async {
//    String tokenforROOM = widget.token;
//    if (tokenforROOM != null) {
//      String url = Api.itemConnectOwner + widget.owner["id"].toString();
//      await http.get(
//        url,
//        headers: {
//          HttpHeaders.CONTENT_TYPE: "application/json",
//          "Authorization": "Token " + tokenforROOM,
//        },
//      ).then((value) => print(value));
//      widget.room.fetchAndSetRooms(widget.auth);
//    }
//    return null;
//  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              AppBar(
                backgroundColor: Colors.white,
                centerTitle: true,
                leading: IconButton(
                  color: Theme.of(context).primaryColor,
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                title: Text(
                  order.title.toString(),
                  style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                ),
                elevation: 1,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(40)),
                      child: Image.network(
                        'https://images-na.ssl-images-amazon.com/images/I/81NIli1PuqL._AC_SL1500_.jpg',
                        height: 250,
                        width: 250,
                        fit: BoxFit.cover,
                        loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes
                                  : null,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 26.0, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    CircleAvatar(
                      radius: 24.0,
                      child: Image(
                        image: NetworkImage(
                            // "https://briddgy.herokuapp.com/media/" + _user["avatarpic"].toString() +"/"
                            "https://picsum.photos/250?image=9"), //Todo,
                      ),
                    ),

                    Text(
                      order.owner.firstName + " " + order.owner.lastName,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      width: 50,
                      height: 25,
                      decoration: BoxDecoration(
                        color: Colors.green[400],
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Icon(
                            Icons.star,
                            size: 15,
                            color: Colors.white,
                          ),
                          Text(
                            order.owner.rating.toString(),
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    )
//                  RatingBar(
//                    initialRating: 3,
//                    direction: Axis.horizontal,
//                    allowHalfRating: true,
//                    itemCount: 5,
//                    glowColor: Colors.amber,
//                    ratingWidget: RatingWidget(
//                      full: Icon(Icons.star),
//                      half: Icon(Icons.star_half),
//                      empty: Icon(Icons.star_border),
//                    ),
//                    itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
//                    onRatingUpdate: (rating) {
//                      print(rating);
//                    },
//                  ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Card(
                margin: EdgeInsets.symmetric(horizontal: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                elevation: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 2),
                      child: Text(
                        "Item Details",
                        style: TextStyle(
                          fontSize: 20,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
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
                        horizontal: 10,
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
                        horizontal: 10,
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
                            order.date.toString(),
                            style: TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
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
                        horizontal: 10,
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
                    // ListTile(
                    //   dense: true,
                    //   title: Text(
                    //     "Dimensions:",
                    //     style: TextStyle(
                    //       fontSize: 17,
                    //       color: Colors.grey[600],
                    //     ),
                    //   ),
                    //   trailing: Text(
                    //     '25x17x20', //todo: data
                    //     style: TextStyle(fontSize: 18),
                    //   ),
                    // ),
                  ],
                ),
              ), //
              SizedBox(
                height: 10,
              ),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                margin: EdgeInsets.symmetric(horizontal: 10),
                elevation: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 2),
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
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Text(
                        order.description,
                        style: TextStyle(fontSize: 17),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    RaisedButton(
                      color: Colors.blue[400],
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Text(
                            "Message",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 20,
                            color: Colors.white,
                          )
                        ],
                      ),
                      onPressed: () {
                        //todo orxan fix
                        //                        createRooms();

                        //Todo Toast message that Conversation has been started
                        Navigator.pop(context);
                      },
                    ),
                    // RaisedButton(
                    //   color: Theme.of(context).primaryColor,
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.spaceAround,
                    //     children: <Widget>[
                    //       Text(
                    //         "To Baggage",
                    //         style: TextStyle(
                    //           fontSize: 20,
                    //           fontWeight: FontWeight.bold,
                    //           color: Colors.white,
                    //         ),
                    //       ),
                    //       SizedBox(
                    //         width: 10,
                    //       ),
                    //       Icon(
                    //         Icons.add,
                    //         size: 20,
                    //         color: Colors.white,
                    //       )
                    //     ],
                    //   ),
                    //   onPressed: () {},
                    // ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ItemScreenOld extends StatefulWidget {
  var id, description, image, token, room, auth;
  var title, owner, destination, source, date, weight, price;
  ItemScreenOld({
    this.id,
    this.date,
    this.destination,
    this.weight,
    this.price,
    this.owner,
    this.title,
    this.description,
    this.source,
    this.image,
    this.token,
    this.room,
    this.auth,
  });
  static const routeName = '/orders/item';
  @override
  _ItemScreenOldState createState() => _ItemScreenOldState();
}

class _ItemScreenOldState extends State<ItemScreenOld> {
  @override
  void initState() {
    super.initState();
  }

  Future createRooms() async {
    String tokenforROOM = widget.token;
    if (tokenforROOM != null) {
      String url = Api.itemConnectOwner + widget.owner["id"].toString();
      await http.get(
        url,
        headers: {
          HttpHeaders.CONTENT_TYPE: "application/json",
          "Authorization": "Token " + tokenforROOM,
        },
      ).then((value) => print(value));
      widget.room.fetchAndSetRooms(widget.auth);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              AppBar(
                backgroundColor: Colors.white,
                centerTitle: true,
                leading: IconButton(
                  color: Theme.of(context).primaryColor,
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                title: Text(
                  widget.title.toString(),
                  style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                ),
                elevation: 1,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(40)),
                      child: Image.network(
                        'https://images-na.ssl-images-amazon.com/images/I/81NIli1PuqL._AC_SL1500_.jpg',
                        height: 250,
                        width: 250,
                        fit: BoxFit.cover,
                        loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes
                                  : null,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 26.0, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    CircleAvatar(
                      radius: 24.0,
                      child: Image(
                        image: NetworkImage(
                            // "https://briddgy.herokuapp.com/media/" + _user["avatarpic"].toString() +"/"
                            "https://picsum.photos/250?image=9"), //Todo,
                      ),
                    ),

                    Text(
                      widget.owner["first_name"].toString() + " " + widget.owner["last_name"].toString(),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      width: 50,
                      height: 25,
                      decoration: BoxDecoration(
                        color: Colors.green[400],
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Icon(
                            Icons.star,
                            size: 15,
                            color: Colors.white,
                          ),
                          Text(
                            widget.owner["rating"].toString(),
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    )
//                  RatingBar(
//                    initialRating: 3,
//                    direction: Axis.horizontal,
//                    allowHalfRating: true,
//                    itemCount: 5,
//                    glowColor: Colors.amber,
//                    ratingWidget: RatingWidget(
//                      full: Icon(Icons.star),
//                      half: Icon(Icons.star_half),
//                      empty: Icon(Icons.star_border),
//                    ),
//                    itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
//                    onRatingUpdate: (rating) {
//                      print(rating);
//                    },
//                  ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Card(
                margin: EdgeInsets.symmetric(horizontal: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                elevation: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 2),
                      child: Text(
                        "Item Details",
                        style: TextStyle(
                          fontSize: 20,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
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
                            widget.source.toString(),
                            style: TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
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
                            widget.destination["city_ascii"].toString(),
                            style: TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
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
                            widget.date.toString(),
                            style: TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
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
                            widget.weight.toString() + " kg",
                            style: TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
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
                            widget.price.toString() + ' \$',
                            style: TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                    // ListTile(
                    //   dense: true,
                    //   title: Text(
                    //     "Dimensions:",
                    //     style: TextStyle(
                    //       fontSize: 17,
                    //       color: Colors.grey[600],
                    //     ),
                    //   ),
                    //   trailing: Text(
                    //     '25x17x20', //todo: data
                    //     style: TextStyle(fontSize: 18),
                    //   ),
                    // ),
                  ],
                ),
              ), //
              SizedBox(
                height: 10,
              ),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                margin: EdgeInsets.symmetric(horizontal: 10),
                elevation: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 2),
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
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Text(
                        widget.description.toString(),
                        style: TextStyle(fontSize: 17),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    RaisedButton(
                      color: Colors.blue[400],
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Text(
                            "Message",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 20,
                            color: Colors.white,
                          )
                        ],
                      ),
                      onPressed: () {
                        createRooms();

                        //Todo Toast message that Conversation has been started
                        Navigator.pop(context);
                      },
                    ),
                    // RaisedButton(
                    //   color: Theme.of(context).primaryColor,
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.spaceAround,
                    //     children: <Widget>[
                    //       Text(
                    //         "To Baggage",
                    //         style: TextStyle(
                    //           fontSize: 20,
                    //           fontWeight: FontWeight.bold,
                    //           color: Colors.white,
                    //         ),
                    //       ),
                    //       SizedBox(
                    //         width: 10,
                    //       ),
                    //       Icon(
                    //         Icons.add,
                    //         size: 20,
                    //         color: Colors.white,
                    //       )
                    //     ],
                    //   ),
                    //   onPressed: () {},
                    // ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
