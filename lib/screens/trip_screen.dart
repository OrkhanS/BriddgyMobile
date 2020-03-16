import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:optisend/screens/chats_screen.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:optisend/providers/ordersandtrips.dart';
import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:optisend/screens/add_trip_screen.dart';
import 'package:optisend/widgets/filter_panel.dart';
import 'package:optisend/screens/item_screen.dart';
import 'package:optisend/main.dart';
import 'package:flutter/foundation.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:optisend/screens/FirebaseMessaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TripsScreen extends StatefulWidget {
  OrdersTripsProvider orderstripsProvider;
  var token;
  TripsScreen({this.orderstripsProvider, this.token});
  static const routeName = '/trip';
  @override
  _TripScreenState createState() => _TripScreenState();
}

class _TripScreenState extends State<TripsScreen> {
//  var deviceSize = MediaQuery.of(context).size;
  bool expands = true;
  String _startDate = "From";
  String _endtime = "Until";
  String _time = "Not set";
  DateTime startDate = DateTime.now();
  String imageUrl;

  List _suggested = [];
  List _cities = [];
  bool flagFrom = false;
  bool flagTo = false;
  bool flagWeight = false;
  bool flagStart = false;
  String from, to;
  String weight, price;
  final TextEditingController _typeAheadController = TextEditingController();
  final TextEditingController _typeAheadController2 = TextEditingController();
  String _value = "Sort By";
  final formKey = new GlobalKey<FormState>();
  String urlFilter = "";

  bool isLoading = true;
  @override
  void initState() {
    if(widget.orderstripsProvider.mytrips.isEmpty){
      widget.orderstripsProvider.fetchAndSetTrips();
    }
    super.initState();
  }

  List _trips = [];

  Future filterAndSetTrips(from, to, weight, _startDate, _endtime) async {
    var provider = widget.orderstripsProvider;
    _startDate = null;
    _endtime = null;
    urlFilter = "http://briddgy.herokuapp.com/api/trips/?";
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
    if (_startDate != null) {
      flagWeight == false && flagTo == false && flagFrom == false
          ? urlFilter = urlFilter + "start_date=" + _startDate.toString()
          : urlFilter = urlFilter + "&start_date=" + _startDate.toString();
      flagStart = true;
    }
    if (_endtime != null) {
      flagWeight == false &&
              flagTo == false &&
              flagFrom == false &&
              flagStart == false
          ? urlFilter = urlFilter + "end_date=" + _endtime.toString()
          : urlFilter = urlFilter + "&end_date=" + _endtime.toString();
      flagStart = true;
    }
    await http.get(
      urlFilter,
      headers: {HttpHeaders.CONTENT_TYPE: "application/json"},
    ).then((response) {
      setState(
        () {
          final dataOrders = json.decode(response.body) as Map<String, dynamic>;
          provider.trips = dataOrders["results"];
          provider.isLoading = false;
        },
      );
    });
  }

  Future sortData(value, OrdersTripsProvider provider) async {
    String url = "http://briddgy.herokuapp.com/api/trips/?order_by=";
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
          provider.trips = dataOrders["results"];
          provider.isLoading = false;
        },
      );
    });
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

  Future createRooms(id) async {
    String tokenforROOM = widget.token;
    if (tokenforROOM != null) {
      String url = "http://briddgy.herokuapp.com/api/chat/" + id.toString();
      final response = await http.get(
        url,
        headers: {
          HttpHeaders.CONTENT_TYPE: "application/json",
          "Authorization": "Token " + tokenforROOM,
        },
      );
    }
    return null;
  }

  @override //Todo: check
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Widget button() {
    return Padding(
      padding: const EdgeInsets.all(22.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: RaisedButton(
          color: Theme.of(context).primaryColor,

          elevation: 2,
//                            color: Theme.of(context).primaryColor,
          child: Container(
            decoration: BoxDecoration(),
            width: MediaQuery.of(context).size.width,
            child: Center(
              child: Text(
                "SEARCH",
                style: TextStyle(
                  fontSize: 19,
                  color: Colors.white,
//                                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          onPressed: () {
            filterAndSetTrips(from, to, weight, _startDate, _endtime);
            build(context);
          },
        ),
      ),
    );
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
                    "Tokyo - Paris, 25 May",
                    style: TextStyle(color: Colors.grey[400]
                        // Theme.of(context).primaryColor,
                        // fontWeight: FontWeight.bold,
                        // fontSize: 20
                        ),
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
                        child: TypeAheadFormField(
                          keepSuggestionsOnLoading: false,
                          debounceDuration: const Duration(milliseconds: 200),
                          textFieldConfiguration: TextFieldConfiguration(
                            onChanged: (value) {
                              from = null;
                            },
                            controller: this._typeAheadController,
                            decoration: InputDecoration(
                                labelText: 'From',
                                icon: Icon(
                                  Icons.location_on,
                                  size: 20,
                                )),
                          ),
                          suggestionsCallback: (pattern) {
                            return getSuggestions(pattern);
                          },
                          itemBuilder: (context, suggestion) {
                            return ListTile(
                              title: Text(suggestion.toString().split(", ")[0] +
                                  ", " +
                                  suggestion.toString().split(", ")[1]),
                            );
                          },
                          transitionBuilder:
                              (context, suggestionsBox, controller) {
                            return suggestionsBox;
                          },
                          onSuggestionSelected: (suggestion) {
                            this._typeAheadController.text =
                                suggestion.toString().split(", ")[0] +
                                    ", " +
                                    suggestion.toString().split(", ")[1];
                            from = suggestion.toString().split(", ")[2];
                          },
                          validator: (value) {
                            from = value;
                            if (value.isEmpty) {
                              return 'Please select a city';
                            }
                          },
                          onSaved: (value) => from = value,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 20, right: 20, bottom: 20),
                        child: TypeAheadFormField(
                          keepSuggestionsOnLoading: false,
                          debounceDuration: const Duration(milliseconds: 200),
                          textFieldConfiguration: TextFieldConfiguration(
                            onChanged: (value) {
                              to = null;
                            },
                            controller: this._typeAheadController2,
                            decoration: InputDecoration(
                                labelText: 'To',
                                icon: Icon(
                                  Icons.location_on,
                                  size: 20,
                                )),
                          ),
                          suggestionsCallback: (pattern) {
                            return getSuggestions(pattern);
                          },
                          itemBuilder: (context, suggestion) {
                            return ListTile(
                              title: Text(suggestion.toString().split(", ")[0] +
                                  ", " +
                                  suggestion.toString().split(", ")[1]),
                            );
                          },
                          transitionBuilder:
                              (context, suggestionsBox, controller) {
                            return suggestionsBox;
                          },
                          onSuggestionSelected: (suggestion) {
                            this._typeAheadController2.text =
                                suggestion.toString().split(", ")[0] +
                                    ", " +
                                    suggestion.toString().split(", ")[1];
                            to = suggestion.toString().split(", ")[2];
                          },
                          validator: (value) {
                            to = value;
                            if (value.isEmpty) {
                              return 'Please select a city';
                            }
                          },
                          onSaved: (value) => to = value,
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
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: RaisedButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0)),
                            elevation: 4.0,
                            onPressed: () {
                              DatePicker.showDatePicker(context,
                                  theme: DatePickerTheme(
                                    itemStyle:
                                        TextStyle(color: Colors.blue[800]),
                                    containerHeight: 300.0,
                                  ),
                                  showTitleActions: true,
                                  minTime: DateTime.now(),
                                  maxTime: DateTime(2025, 12, 31),
                                  onConfirm: (date) {
                                // _startDate =
                                //     '${date.day}/${date.month}/${date.year}  ';
                                _startDate = null;
                              },
                                  currentTime: DateTime.now(),
                                  locale: LocaleType.en);
                            },
                            child: Container(
                              alignment: Alignment.center,
                              height: 40.0,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Container(
                                        child: Row(
                                          children: <Widget>[
                                            Icon(
                                              Icons.date_range,
                                              size: 18.0,
                                              color: Colors.grey,
                                            ),
                                            Center(
                                              child: Text(
                                                " Date:  $_startDate",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15.0),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 20, right: 20, bottom: 20),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: RaisedButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0)),
                            elevation: 4.0,
                            onPressed: () {
                              DatePicker.showDatePicker(context,
                                  theme: DatePickerTheme(
                                    itemStyle:
                                        TextStyle(color: Colors.blue[800]),
                                    containerHeight: 300.0,
                                  ),
                                  showTitleActions: true,
                                  minTime: DateTime.now(),
                                  maxTime: DateTime(2025, 12, 31),
                                  onConfirm: (date) {
                                // _endtime =
                                //     '${date.day}/${date.month}/${date.year}  ';
                                _endtime = null;
                              },
                                  currentTime: DateTime.now(),
                                  locale: LocaleType.en);
                            },
                            child: Container(
                              alignment: Alignment.center,
                              height: 40.0,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Container(
                                        child: Row(
                                          children: <Widget>[
                                            Icon(
                                              Icons.date_range,
                                              size: 18.0,
                                              color: Colors.grey,
                                            ),
                                            Center(
                                              child: Text(
                                                " Date:  $_endtime",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15.0),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            color: Colors.white,
                          ),
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
                            labelText: 'Weight Limit (min)',
                            //icon: Icon(Icons.place),
                          ),
                          keyboardType: TextInputType.number,
//
                          onChanged: (String val) {
                            weight = val;
                          },
                          onSaved: (value) {
//                        _authData['email'] = value;
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                button(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrdersTripsProvider>(
      builder: (context, tripsProvider, child) {
        return Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (__) => AddTripScreen(
                          token: widget.token,
                          orderstripsProvider: widget.orderstripsProvider,
                        )),
              );
            },
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
              Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
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
                    sortData(value, tripsProvider);
                  },
                ),
              ]),
              Expanded(
                child: tripsProvider.notLoaded != false
                    ? Center(child: CircularProgressIndicator())
                    : ListView.builder(
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Image(
                                          image: NetworkImage(
                                              "https://img.icons8.com/wired/2x/passenger-with-baggage.png"),
                                          height: 60,
                                          width: 60,
                                        )

                                        // Image.network(
                                        //         getImageUrl(_trips[i]["orderimage"])
                                        // ),
                                        ),
                                    Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            tripsProvider.trips[i]["owner"]
                                                    ["first_name"] +
                                                " " +
                                                tripsProvider.trips[i]["owner"]
                                                    ["last_name"], //Todo: title
                                            style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.grey[600],
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: <Widget>[
                                              Icon(
                                                Icons.location_on,
                                                color: Theme.of(context)
                                                    .primaryColor,
                                              ),
                                              Text(
                                                "  " +
                                                    tripsProvider.trips[i]
                                                            ["source"]
                                                        ["city_ascii"] +
                                                    "  >  " +
                                                    tripsProvider.trips[i]
                                                            ["destination"][
                                                        "city_ascii"], //Todo: Source -> Destination
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.grey[600],
                                                    fontWeight:
                                                        FontWeight.normal),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: <Widget>[
                                              Icon(
                                                Icons.date_range,
                                                color: Theme.of(context)
                                                    .primaryColor,
                                              ),
                                              Text(
                                                "  " +
                                                    tripsProvider.trips[i]
                                                            ["date"]
                                                        .toString(), //Todo: date
                                                style: TextStyle(
                                                    color: Colors.grey[600]),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: <Widget>[
                                              Icon(
                                                MdiIcons
                                                    .weightKilogram, //todo: icon
//                                            (FontAwesome.suitcase),
                                                color: Theme.of(context)
                                                    .primaryColor,
                                              ),
                                              Text(
                                                "  " +
                                                    tripsProvider.trips[i]
                                                            ["weight_limit"]
                                                        .toString(),
                                                style: TextStyle(
                                                    color: Colors.grey[600]),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10.0),
                                      child: RaisedButton(
                                        color: Colors.white,
                                        onPressed: () {
                                          createRooms(tripsProvider.trips[i]
                                              ["owner"]["id"]);

                                          //Todo Toast message that Conversation has been started
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => MyApp()),
                                          );
                                          //Navigator.pop(context);
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 20.0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: <Widget>[
                                              Icon(
                                                MdiIcons
                                                    .messageArrowRightOutline,
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                size: 30,
                                              ),
                                              Text(
                                                "Message",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        itemCount: tripsProvider.trips == null
                            ? 0
                            : tripsProvider.trips.length,
                      ),
              )
            ],
          ),
        );
      },
    );
  }
}
