import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:optisend/widgets/filter_panel.dart';
import 'package:optisend/screens/item_screen.dart';
import 'package:optisend/main.dart';
import 'package:optisend/screens/add_item_screen.dart';

import 'package:flutter/foundation.dart';

class OrdersScreen extends StatefulWidget {
  static const routeName = '/orders';
  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
//  var deviceSize = MediaQuery.of(context).size;
  bool expands = true;
  String _startDate = "Starting from";
  String _endDate = "Untill";
  String _time = "Not set";
  DateTime startDate = DateTime.now();
  String imageUrl;
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
  }

  List _orders = [];

  // Todo fetch them in provider
  Future fetchAndSetOrders() async {
    const url = "http://briddgy.herokuapp.com/api/orders/";
    http.get(
      url,
      headers: {HttpHeaders.CONTENT_TYPE: "application/json"},
    ).then((response) {
      setState(
        () {
          final dataOrders = json.decode(response.body) as Map<String, dynamic>;
          _orders = dataOrders["results"];
          isLoading = false;
        },
      );
    });
  }

  @override //todo: check for future
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Widget filterBar() {
    return Form(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15), topRight: Radius.circular(15)),
          child: Card(
            elevation: 5,
            color: Theme.of(context).primaryColor,
            child: FilterPanel(
              backgroundColor: Colors.white,
              initiallyExpanded: false, //todo
              onExpansionChanged: (val) {
                val = !val;
              },
//              subtitle: Text("Source:  Destination: "),
              title: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  color: Colors.white,
                  border: Border(),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
                  child: Text(
                    "Filters:",
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                  ),
                ),
              ),
              trailing: Icon(
                MdiIcons.filterPlusOutline,
                color: Colors.white,
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    fetchAndSetOrders();

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.pushNamed(context, AddItemScreen.routeName);
        },
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Center(
          child: Text(
            "Items",
            style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold),
          ),
        ),
        elevation: 1,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: <Widget>[
                filterBar(),
                Expanded(
                  child: ListView.builder(
                    itemBuilder: (context, int i) {
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            new MaterialPageRoute(
                              builder: (__) => new ItemScreen(
                                id: _orders[i]["id"],
                                owner: _orders[i]["owner"],
                                title: _orders[i]["title"],
                                destination: _orders[i]["destination"],
                                source: _orders[i]["source"]["city_ascii"],
                                weight: _orders[i]["weight"],
                                price: _orders[i]["price"],
                                date: _orders[i]["date"],
                                description: _orders[i]["description"],
                                image: _orders[i]["orderimage"],
                              ),
                            ),
                          );
                        },
                        child: Container(
                          height: 140,
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Card(
                            elevation: 4,
                            child: Row(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: ClipRRect(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(15)),
                                    child: Image(
                                      image: NetworkImage(
                                          // "https://briddgy.herokuapp.com/media/" + _user["avatarpic"].toString() +"/"
                                          "https://picsum.photos/250?image=9"), //Todo,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        _orders[i]["title"], //Todo: title
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.grey[800],
//                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          Icon(
                                            MdiIcons.mapMarkerMultipleOutline,
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                          Text(
                                            _orders[i]["source"]["city_ascii"] +
                                                "  >  " +
                                                _orders[i]["destination"][
                                                    "city_ascii"], //Todo: Source -> Destination
                                            style: TextStyle(
                                                fontSize: 15,
                                                color: Colors.grey[600],
                                                fontWeight: FontWeight.normal),
                                          ),
                                        ],
                                      ),
                                      Row(
//                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: <Widget>[
                                          Row(
                                            children: <Widget>[
                                              Icon(
                                                MdiIcons.calendarRange,
                                                color: Theme.of(context)
                                                    .primaryColor,
                                              ),
                                              Text(
                                                _orders[i]["date"]
                                                    .toString(), //Todo: date
                                                style: TextStyle(
                                                    color: Colors.grey[600]),
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
                                                color: Theme.of(context)
                                                    .primaryColor,
                                              ),
                                              Text(
                                                _orders[i]["price"]
                                                    .toString(), //Todo: date
                                                style: TextStyle(
                                                    color: Colors.grey[600]),
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
                        ),
                      );
                    },
                    itemCount: _orders == null ? 0 : _orders.length,
                  ),
                )
              ],
            ),
    );
  }
}
