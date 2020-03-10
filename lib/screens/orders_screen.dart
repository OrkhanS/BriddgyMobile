import 'dart:convert';
import 'dart:io';
import 'dart:async';
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
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:flutter/foundation.dart';
import 'package:dropdown_formfield/dropdown_formfield.dart';

import 'package:optisend/widgets/filter_bar.dart';

class OrdersScreen extends StatefulWidget {
  static const routeName = '/orders';
  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
//  var deviceSize = MediaQuery.of(context).size;
  bool expands = false;
  var filterColor = Colors.white;
  var _itemCount = 0;
  String _startDate = "Starting from";
  String _endDate = "Untill";
  String _time = "Not set";
  String _searchBarFrom = "Anywhere";
  String _searchBarTo = "Anywhere";
  String _searchBarWeight = "Any";
  DateTime startDate = DateTime.now();
  String imageUrl;
  bool isLoading = true;
  bool flagFrom = false;
  bool flagTo = false;
  bool flagWeight = false;
  String from, to;
  String _value = "Sort By";
  String weight, price;
  final formKey = new GlobalKey<FormState>();

  List _suggested = [];
  List _cities = [];
  final TextEditingController _typeAheadController = TextEditingController();
  final TextEditingController _typeAheadController2 = TextEditingController();
  final TextEditingController _typeAheadController3 = TextEditingController();
  final TextEditingController _typeAheadController4 = TextEditingController();

  @override
  void initState() {
    fetchAndSetOrders();
    super.initState();
  }

  String urlFilter = "";
  String _myActivity;
  String _myActivityResult;

  List _orders = [];

  // Todo fetch them in provider
  Future fetchAndSetOrders() async {
    const url = "http://briddgy.herokuapp.com/api/orders/";
    await http.get(
      url,
      headers: {HttpHeaders.CONTENT_TYPE: "application/json"},
    ).then((response) {
      setState(
        () {
          final dataOrders = json.decode(response.body) as Map<String, dynamic>;
          _orders = dataOrders["results"];
          isLoading = false;
          _itemCount = dataOrders["count"];
        },
      );
    });
  }

  Future sortData(value) async {
    String url = "http://briddgy.herokuapp.com/api/orders/?order_by=";
    if (urlFilter.isNotEmpty) {
      url = urlFilter + "&order_by=";
    }
    if (value.toString().compareTo("WeightLow") == 0) {
      url = url + "weight";
    } else if (value.toString().compareTo("WeightMax") == 0) {
      url = url + "-weight";
    } else if (value.toString().compareTo("Price") == 0) {
      url = url + "-price";
    } else if (value.toString().compareTo("Ranking") == 0) {
      url = url + "-price";
    }
    await http.get(
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

  _saveForm() {
    var form = formKey.currentState;
    if (form.validate()) {
      form.save();
      setState(() {
        _myActivityResult = _myActivity;
      });
    }
  }

  @override //todo: check for future
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  FutureOr<Iterable> getSuggestions(String pattern) async {
    String url = "https://briddgy.herokuapp.com/api/cities/?search=" + pattern;
    await http.get(
      url,
      headers: {HttpHeaders.CONTENT_TYPE: "application/json"},
    ).then((response) {
      setState(
        () {
          final dataOrders = json.decode(response.body) as Map<String, dynamic>;
          _suggested = dataOrders["results"];
          isLoading = false;
        },
      );
    });
    _cities = [];
    for (var i = 0; i < _suggested.length; i++) {
      _cities.add(_suggested[i]["city_ascii"].toString() +
          ", " +
          _suggested[i]["country"].toString() +
          ", " +
          _suggested[i]["id"].toString());
    }
    return _cities;
  }

//  Widget filterBar() {

//      child: Padding(
//        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
//        child: ClipRRect(
//          borderRadius: BorderRadius.only(
//              topLeft: Radius.circular(15), topRight: Radius.circular(15)),
//          child: Card(
//            elevation: 5,
//            color: Theme.of(context).primaryColor,
//            child: FilterPanel(
//              backgroundColor: Colors.white,
//              initiallyExpanded: expands,
//              onExpansionChanged: (val) {
//                val = !val;
//                if (val)
//                  setState(() {
//                    filterColor = Colors.white;
//                  });
//                else
//                  setState(() {
//                    filterColor = Theme.of(context).primaryColor;
//                  });
//              },
////              subtitle: Text("Source:  Destination: "),
//              title: Container(
//                decoration: BoxDecoration(
//                  borderRadius: BorderRadius.all(Radius.circular(5)),
//                  color: Colors.white,
//                  border: Border(),
//                ),
//                child: Padding(
//                  padding:
//                      const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
//                  child: Text(
//                    _searchBarFrom +
//                        " - " +
//                        _searchBarTo +
//                        " , " +
//                        _searchBarWeight +
//                        " kg ",
//                    style: TextStyle(color: Colors.grey[400]
//                        // Theme.of(context).primaryColor,
//                        // fontWeight: FontWeight.bold,
//                        // fontSize: 20
//                        ),
//                  ),
//                ),
//              ),
//              children: <Widget>[
//                Padding(
//                  padding:
//                      const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
//                  child: TypeAheadFormField(
//                    keepSuggestionsOnLoading: false,
//                    debounceDuration: const Duration(milliseconds: 200),
//                    textFieldConfiguration: TextFieldConfiguration(
//                      onChanged: (value) {
//                        from = null;
//                      },
//                      controller: this._typeAheadController,
//                      decoration: InputDecoration(
//                        labelText: 'From',
//                        hintText: ' Paris',
//                        hintStyle: TextStyle(color: Colors.grey[300]),
//                        prefixIcon: Icon(
//                          MdiIcons.mapMarkerRightOutline,
//                        ),
//                        suffixIcon: IconButton(
//                          padding: EdgeInsets.only(
//                            top: 5,
//                          ),
//                          icon: Icon(
//                            Icons.close,
//                            size: 15,
//                          ),
//                          onPressed: () {
//                            this._typeAheadController.text = '';
//                            from = null;
//                          },
//                        ),
//                      ),
//                    ),
//                    suggestionsCallback: (pattern) {
//                      return getSuggestions(pattern);
//                    },
//                    itemBuilder: (context, suggestion) {
//                      return ListTile(
//                        title: Text(suggestion.toString().split(", ")[0] +
//                            ", " +
//                            suggestion.toString().split(", ")[1]),
//                      );
//                    },
//                    transitionBuilder: (context, suggestionsBox, controller) {
//                      return suggestionsBox;
//                    },
//                    onSuggestionSelected: (suggestion) {
//                      this._typeAheadController.text =
//                          suggestion.toString().split(", ")[0] +
//                              ", " +
//                              suggestion.toString().split(", ")[1];
//                      from = suggestion.toString().split(", ")[2];
//                      _searchBarFrom = suggestion.toString().split(", ")[0];
//                    },
//                    validator: (value) {
//                      from = value;
//
//                      if (value.isEmpty) {
//                        return 'Please select a city';
//                      }
//                    },
//                    onSaved: (value) {
//                      from = value;
//                    },
//                  ),
//                ),
//                Padding(
//                  padding:
//                      const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
//                  child: TypeAheadFormField(
//                    keepSuggestionsOnLoading: false,
//                    debounceDuration: const Duration(milliseconds: 200),
//                    textFieldConfiguration: TextFieldConfiguration(
//                      onChanged: (value) {
//                        to = null;
//                      },
//                      controller: this._typeAheadController2,
//                      decoration: InputDecoration(
//                        labelText: 'To',
//                        hintText: ' Berlin',
//                        hintStyle: TextStyle(color: Colors.grey[300]),
//                        prefixIcon: Icon(
//                          MdiIcons.mapMarkerCheckOutline,
//                        ),
//                        suffixIcon: IconButton(
//                          padding: EdgeInsets.only(
//                            top: 5,
//                          ),
//                          icon: Icon(
//                            Icons.close,
//                            size: 15,
//                          ),
//                          onPressed: () {
//                            this._typeAheadController2.text = '';
//                            to = null;
//                          },
//                        ),
//                      ),
//                    ),
//                    suggestionsCallback: (pattern) {
//                      return getSuggestions(pattern);
//                    },
//                    itemBuilder: (context, suggestion) {
//                      return ListTile(
//                        title: Text(suggestion.toString().split(", ")[0] +
//                            ", " +
//                            suggestion.toString().split(", ")[1]),
//                      );
//                    },
//                    transitionBuilder: (context, suggestionsBox, controller) {
//                      return suggestionsBox;
//                    },
//                    onSuggestionSelected: (suggestion) {
//                      this._typeAheadController2.text =
//                          suggestion.toString().split(", ")[0] +
//                              ", " +
//                              suggestion.toString().split(", ")[1];
//                      to = suggestion.toString().split(", ")[2];
//                      _searchBarTo = suggestion.toString().split(", ")[0];
//                    },
//                    validator: (value) {
//                      to = value;
//                      if (value.isEmpty) {
//                        return 'Please select a city';
//                      }
//                    },
//                    onSaved: (value) => to = value,
//                  ),
//                ),
//                Padding(
//                  padding:
//                      const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
//                  child: TextFormField(
//                    controller: _typeAheadController3,
//                    decoration: InputDecoration(
//                      prefixIcon: Icon(MdiIcons.weightKilogram),
//                      labelText: 'Weight maximum (in kg):',
//                      hintText: ' 3kg',
//                      hintStyle: TextStyle(color: Colors.grey[300]),
//                      suffixIcon: IconButton(
//                        padding: EdgeInsets.only(
//                          top: 5,
//                        ),
//                        icon: Icon(
//                          Icons.close,
//                          size: 15,
//                        ),
//                        onPressed: () {
//                          this._typeAheadController3.text = '';
//                          weight = null;
//                        },
//                      ),
//                    ),
//                    keyboardType: TextInputType.number,
////
//                    onChanged: (String val) {
//                      _searchBarWeight = val;
//                      weight = val;
//                    },
//                    onSaved: (value) {
////                        _authData['email'] = value;
//                    },
//                  ),
//                ),
//                Padding(
//                  padding: const EdgeInsets.only(
//                      left: 30, right: 30, top: 5, bottom: 20),
//                  child: TextFormField(
//                    controller: _typeAheadController4,
//                    decoration: InputDecoration(
//                      prefixIcon: Icon(
//                        MdiIcons.currencyUsd,
//                      ),
//
//                      labelText: 'Reward minimum (in usd):',
//                      hintText: ' 10\$',
//                      hintStyle: TextStyle(color: Colors.grey[300]),
//
//                      suffixIcon: IconButton(
//                        padding: EdgeInsets.only(
//                          top: 5,
//                        ),
//                        icon: Icon(
//                          Icons.close,
//                          size: 15,
//                        ),
//                        onPressed: () {
//                          this._typeAheadController4.text = '';
//                          price = null;
//                        },
//                      ),
//                      //icon: Icon(Icons.location_on),
//                    ),
//
//                    keyboardType: TextInputType.number,
////                      validator: (value) {
////                        if (value.isEmpty || !value.contains('@')) {
////                          return 'Invalid email!';
////                        } else
////                          return null; //Todo
////                      },
//                    onChanged: (String val) {
//                      price = val;
//                    },
//                    onSaved: (value) {
////                        _authData['email'] = value;
//                    },
//                  ),
//                ),
//                button(),
//              ],
//            ),
//          ),
//        ),
//      ),
//    );
//  }
//
//
  @override
  void dispose() {
    super.dispose();
  }

  Future filterAndSetOrders(from, to, weight, price) async {
    urlFilter = "http://briddgy.herokuapp.com/api/orders/?";
    if (from != null) {
      urlFilter = urlFilter + "origin=" + from;
      flagFrom = true;
    }
    if (to != null) {
      flagFrom == false
          ? urlFilter = urlFilter + "dest=" + to.toString()
          : urlFilter = urlFilter + "&dest=" + to.toString();
      flagTo = true;
    }
    if (weight != null) {
      flagTo == false && flagFrom == false
          ? urlFilter = urlFilter + "weight=" + weight.toString()
          : urlFilter = urlFilter + "&weight=" + weight.toString();
      flagWeight = true;
    }
    if (price != null) {
      flagWeight == false && flagTo == false && flagFrom == false
          ? urlFilter = urlFilter + "min_price=" + price.toString()
          : urlFilter = urlFilter + "&min_price=" + price.toString();
    }
    await http.get(
      urlFilter,
      headers: {HttpHeaders.CONTENT_TYPE: "application/json"},
    ).then((response) {
      setState(
        () {
          final dataOrders = json.decode(response.body) as Map<String, dynamic>;
          _orders = dataOrders["results"];
          isLoading = false;
          _itemCount = dataOrders["count"];
        },
      );
    });
  }
//    return Form(

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: true,
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
          : GestureDetector(
              child: SingleChildScrollView(
                child: Container(
                  height: MediaQuery.of(context).size.height * .83,
                  child: Column(
                    children: <Widget>[
                      FilterBar(
                          orders: _orders,
                          from: from,
                          to: to,
                          weight: weight,
                          price: price),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                "Results: " + _itemCount.toString(),
                                style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey[500],
                                    fontWeight: FontWeight.bold),
                              ),
                              DropdownButton(
                                hint: Text(_value),
                                items: [
                                  DropdownMenuItem(
                                    value: "Ranking",
                                    child: Text(
                                      "Highest Ranking",
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: "Price",
                                    child: Text(
                                      "Highest Reward",
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: "WeightLow",
                                    child: Text(
                                      "Lowest Weight",
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: "WeightMax",
                                    child: Text(
                                      "Highest Weight",
                                    ),
                                  ),
                                ],
                                onChanged: (value) {
                                  sortData(value);
                                },
                              ),
                            ]),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemBuilder: (context, int i) {
                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (__) => new ItemScreen(
                                      id: _orders[i]["id"],
                                      owner: _orders[i]["owner"],
                                      title: _orders[i]["title"],
                                      destination: _orders[i]["destination"],
                                      source: _orders[i]["source"]
                                          ["city_ascii"],
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
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(15)),
                                          child: Stack(
                                            children: <Widget>[
                                              Image(
                                                image: NetworkImage(
                                                    // "https://briddgy.herokuapp.com/media/" + _user["avatarpic"].toString() +"/"
                                                    "https://picsum.photos/250?image=9"), //Todo,
                                              ),
                                            ],
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
                                              _orders[i]["title"]
                                                          .toString()
                                                          .length >
                                                      20
                                                  ? _orders[i]["title"]
                                                          .toString()
                                                          .substring(0, 20) +
                                                      "..."
                                                  : _orders[i]["title"]
                                                      .toString(), //Todo: title
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
                                                  MdiIcons
                                                      .mapMarkerMultipleOutline,
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                ),
                                                Text(
                                                  _orders[i]["source"]
                                                          ["city_ascii"] +
                                                      "  >  " +
                                                      _orders[i]["destination"]
                                                          ["city_ascii"],
                                                  //Todo: Source -> Destination
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.grey[600],
                                                      fontWeight:
                                                          FontWeight.normal),
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
                                                          .toString(),
                                                      //Todo: date
                                                      style: TextStyle(
                                                          color:
                                                              Colors.grey[600]),
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
                                                          .toString(),
                                                      //Todo: date
                                                      style: TextStyle(
                                                          color:
                                                              Colors.grey[600]),
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
                ),
              ),
            ),
    );
  }
}
