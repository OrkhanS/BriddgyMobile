import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:optisend/widgets/filter_panel.dart';
import 'package:optisend/screens/item_screen.dart';
import 'package:optisend/main.dart';
import 'package:flutter/foundation.dart';

class TripsScreen extends StatefulWidget {
  static const routeName = '/trip';
  @override
  _TripScreenState createState() => _TripScreenState();
}

class _TripScreenState extends State<TripsScreen> {
//  var deviceSize = MediaQuery.of(context).size;
  bool expands = true;
  String _startDate = "Starting from";
  String _endDate = "Untill";
  String _time = "Not set";
  DateTime startDate = DateTime.now();
  String imageUrl;
  @override
  void initState() {
    super.initState();
  }

  List _trips = [];

  Future fetchAndSetOrders() async {
    const url = "http://briddgy.herokuapp.com/api/trips/";
    http.get(
      url,
      headers: {HttpHeaders.CONTENT_TYPE: "application/json"},
    ).then((response) {
      setState(
        () {
          final dataOrders = json.decode(response.body) as Map<String, dynamic>;
          _trips = dataOrders["results"];
        },
      );
    });
  }

  @override //Todo: check
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Widget filterBar() {
    return Form(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15), topRight: Radius.circular(15)),
          child: Card(
            elevation: 5,
            color: Colors.blue[50],
            child: FilterPanel(
              backgroundColor: Colors.white,
              initiallyExpanded: false, // todo
              onExpansionChanged: (val) {
                val = !val;
              },
              subtitle: Text("Source:  Destination: "),
              title: Text(
                "Filters:",
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 20, right: 20, bottom: 20),
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'From',
                            //icon: Icon(Icons.place),
                          ),
                          keyboardType: TextInputType.text,
//
                          onSaved: (value) {
//                        _authData['email'] = value;
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 20, right: 20, bottom: 20),
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'To',
                            //icon: Icon(Icons.location_on),
                          ),

                          keyboardType: TextInputType.text,
//                      validator: (value) {
//                        if (value.isEmpty || !value.contains('@')) {
//                          return 'Invalid email!';
//                        } else
//                          return null; //Todo
//                      },
                          onSaved: (value) {
//                        _authData['email'] = value;
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 20, right: 20, bottom: 20),
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Weight(max)',
                            //icon: Icon(Icons.place),
                          ),
                          keyboardType: TextInputType.number,
//
                          onSaved: (value) {
//                        _authData['email'] = value;
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 20, right: 20, bottom: 20),
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Reward(min)',
                            //icon: Icon(Icons.location_on),
                          ),

                          keyboardType: TextInputType.number,
//                      validator: (value) {
//                        if (value.isEmpty || !value.contains('@')) {
//                          return 'Invalid email!';
//                        } else
//                          return null; //Todo
//                      },
                          onSaved: (value) {
//                        _authData['email'] = value;
                          },
                        ),
                      ),
                    ),
                  ],
                )
//
              ],
            ),
          ),
        ),
      ),
    );
  }

  getImageUrl(String a) {
    imageUrl = 'https://img.icons8.com/wired/2x/passenger-with-baggage.png';
    if (a != null) {
      imageUrl = 'https://briddgy.herokuapp.com/media/' + a + "/";
    }
    return imageUrl;
  }

  @override
  Widget build(BuildContext context) {
    fetchAndSetOrders();

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: null,
        backgroundColor: Theme.of(context).primaryColor,
        child: Icon(Icons.add),
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Center(
          child: Text(
            "Trips",
            style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold),
          ),
        ),
        elevation: 1,
      ),
      body: Column(
        children: <Widget>[
          filterBar(),
          Expanded(
            child: ListView.builder(
              itemBuilder: (context, int i) {
                return InkWell(
                  onTap: () => null
                  //             //Navigator.pushNamed(context, ItemScreen.routeName);
                  //             Navigator.push(
                  // context,
                  // new MaterialPageRoute(
                  //     builder: (__) => new ItemScreen(
                  //                 id:_trips[i]["id"],
                  //                 owner:_trips[i]["owner"],
                  //                 title:_trips[i]["title"],
                  //                 destination: _trips[i]["destination"],
                  //                 source: _trips[i]["source"]["city_ascii"],
                  //                 weight: _trips[i]["weight"],
                  //                 price: _trips[i]["price"],
                  //                 date: _trips[i]["date"],
                  //                 description: _trips[i]["description"],
                  //                 image: _trips[i]["orderimage"],
                  //              )));
                  ,
                  child: Container(
                    height: 140,
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Card(
                      elevation: 4,
                      child: Row(
                        children: <Widget>[
//                          Padding(
//                              padding: const EdgeInsets.all(10.0),
//                              child: FadeInImage(
//                                image: NetworkImage(
//                                    "https://img.icons8.com/wired/2x/passenger-with-baggage.png"),
//                                placeholder: NetworkImage(
//                                    "https://img.icons8.com/wired/2x/passenger-with-baggage.png"),
//                                height: 60,
//                                width: 60,
//                              )
//
//                              // Image.network(
//                              //         getImageUrl(_trips[i]["orderimage"])
//                              // ),
//                              ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  _trips[i]["owner"]["first_name"] +
                                      " " +
                                      _trips[i]["owner"]
                                          ["last_name"], //Todo: title
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.bold),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Icon(
                                      Icons.location_on,
                                      color: Colors.blue[200],
                                    ),
                                    Text(
                                      "  " +
                                          _trips[i]["source"]["city_ascii"] +
                                          "  -  " +
                                          _trips[i]["destination"][
                                              "city_ascii"], //Todo: Source -> Destination
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.normal),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: <Widget>[
                                    Icon(
                                      Icons.date_range,
                                      color: Colors.blue[200],
                                    ),
                                    Text(
                                      "  " +
                                          _trips[i]["date"]
                                              .toString(), //Todo: date
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: <Widget>[
                                    Icon(
                                      Icons.check_box, //todo: icon
//                                            (FontAwesome.suitcase),
                                      color: Colors.blue[200],
                                    ),
                                    Text(
                                      "  " +
                                          _trips[i]["weight_limit"]
                                              .toString(), //Todo: date
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                    Text(
                                        "                                                    Write    "),
                                    Icon(
                                      Icons.check_box, //todo: icon
//                                      (FontAwesome.envelope),
                                      color: Colors.blue[200],
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              itemCount: _trips == null ? 0 : _trips.length,
            ),
          )
        ],
      ),
    );
  }
}
