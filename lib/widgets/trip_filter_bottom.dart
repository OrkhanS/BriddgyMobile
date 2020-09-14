import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:briddgy/localization/localization_constants.dart';
import 'package:briddgy/models/api.dart';
import 'package:briddgy/models/city.dart';
import 'package:briddgy/models/order.dart';
import 'package:briddgy/models/trip.dart';
import 'package:briddgy/providers/auth.dart';
import 'package:briddgy/providers/ordersandtrips.dart';
import 'package:provider/provider.dart';

class TripFilterBottomBar extends StatefulWidget {
  OrdersTripsProvider ordersProvider;
  TripFilterBottomBar({this.ordersProvider});
  @override
  _TripFilterBottomBarState createState() => _TripFilterBottomBarState();
}

class _TripFilterBottomBarState extends State<TripFilterBottomBar> {
  final TextEditingController _typeAheadController = TextEditingController();
  final TextEditingController _typeAheadController2 = TextEditingController();
  final TextEditingController _typeAheadController3 = TextEditingController();
  final TextEditingController _typeAheadController4 = TextEditingController();

  String _searchBarFrom = "Anywhere";
  String _searchBarTo = "Anywhere";
  String _searchBarDate = "Any";

  String from, to, weight, date;

  List _suggested = [];
  List _cities = [];
  bool isLoading = true;

  bool flagFrom = false;
  bool flagTo = false;
  bool flagWeight = false;
  String urlFilter;
  var _expanded = false;

  Future filterAndSetTrips() async {
    var provider = widget.ordersProvider;
    provider.isLoadingTrips = true;
    provider.notify();

    if (urlFilter == null) urlFilter = Api.trips + "?";
    if (from != null) {
      flagWeight == false && flagTo == false && flagFrom == false
          ? urlFilter = urlFilter + "origin=" + from.toString()
          : urlFilter = urlFilter + "&origin=" + from.toString();
      flagFrom = true;
    }
    if (to != null) {
      flagWeight == false && flagTo == false && flagFrom == false
          ? urlFilter = urlFilter + "dest=" + to.toString()
          : urlFilter = urlFilter + "&dest=" + to.toString();
      flagTo = true;
    }
    if (weight != null) {
      flagWeight == false && flagTo == false && flagFrom == false
          ? urlFilter = urlFilter + "weight=" + weight.toString()
          : urlFilter = urlFilter + "&weight=" + weight.toString();
      flagWeight = true;
    }
    await http
        .get(
      urlFilter,
      headers: Provider.of<Auth>(context, listen: false).isAuth
          ? {
              HttpHeaders.contentTypeHeader: "application/json",
              "Authorization": "Token " + Provider.of<Auth>(context, listen: false).myTokenFromStorage,
            }
          : {
              HttpHeaders.contentTypeHeader: "application/json",
            },
    )
        .then((response) {
      setState(
        () {
          Map<String, dynamic> data = json.decode(response.body) as Map<String, dynamic>;
          _suggested = [];
          for (var i = 0; i < data["results"].length; i++) {
            _suggested.add(Trip.fromJson(data["results"][i]));
          }

          widget.ordersProvider.trips = [];
          widget.ordersProvider.trips = _suggested;
          widget.ordersProvider.allTripsDetails = {"next": data["next"], "count": data["count"]};
          widget.ordersProvider.isLoadingTrips = false;
          widget.ordersProvider.notify();
        },
      );
    });

    // await http.get(
    //   urlFilter,
    //   headers: {HttpHeaders.contentTypeHeader: "application/json"},
    // ).then((response) {
    //   setState(
    //     () {
    //       final dataOrders = json.decode(response.body) as Map<String, dynamic>;
    //       widget.ordersProvider.orders = dataOrders["results"];
    //       isLoading = false;
    //       //itemCount = dataOrders["count"];
    //     },
    //   );
    // });
  }

  FutureOr<Iterable> getSuggestions(String pattern) async {
    String url = Api.getCities + pattern;
    await http.get(
      url,
      headers: {HttpHeaders.contentTypeHeader: "application/json"},
    ).then((response) {
      setState(
        () {
          Map<String, dynamic> data = json.decode(response.body) as Map<String, dynamic>;
          _suggested = data["results"];
          isLoading = false;
          _cities = [];
          for (var i = 0; i < data["results"].length; i++) {
            _cities.add(City.fromJson(data["results"][i]));
          }
        },
      );
    });

    return _cities;
  }

  @override
  void didChangeDependencies() {
    _searchBarFrom = t(context, 'anywhere');
    _searchBarTo = t(context, 'anywhere');
    _searchBarDate = t(context, 'any');
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      height: _expanded ? 195 : 55,
      child: Column(
        children: <Widget>[
          Container(
            height: 55,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _expanded = !_expanded;
                      });
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.75,
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          border: Border.all(
                            width: 1,
                            color: Colors.grey[200],
                          ),
                          borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: Theme.of(context).primaryColor),
                          SizedBox(width: 10),
                          Text(
                            _searchBarFrom + " - " + _searchBarTo + " , " + _searchBarDate,
                            style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                // fontWeight: FontWeight.bold,
                                fontSize: 17),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          AnimatedContainer(
            duration: Duration(milliseconds: 250),
            curve: Curves.decelerate,
            padding: EdgeInsets.symmetric(horizontal: 15),
            height: _expanded ? 140 : 0,
            child: Form(
              child: Column(
                children: <Widget>[
                  Row(
                    children: [
                      Expanded(
                        child: TypeAheadFormField(
                          keepSuggestionsOnLoading: false,
                          debounceDuration: const Duration(milliseconds: 250),
                          textFieldConfiguration: TextFieldConfiguration(
                            onChanged: (value) {
                              from = null;
                            },
                            controller: this._typeAheadController,
                            decoration: InputDecoration(
                              labelText: t(context, 'from'),
                              hintText: ' ${t(context, 'paris')}',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              hintStyle: TextStyle(color: Colors.grey[300]),
                              prefixIcon: Icon(
                                MdiIcons.bridge,
                              ),
                              suffixIcon: IconButton(
                                padding: EdgeInsets.only(
                                  top: 5,
                                ),
                                icon: Icon(
                                  Icons.close,
                                  size: 15,
                                ),
                                onPressed: () {
                                  this._typeAheadController.text = '';
                                  from = null;
                                },
                              ),
                            ),
                          ),
                          suggestionsCallback: (pattern) {
                            return getSuggestions(pattern);
                          },
                          itemBuilder: (context, suggestion) {
                            return ListTile(
                              title: Text(suggestion.cityAscii + ", " + suggestion.country),
                            );
                          },
                          transitionBuilder: (context, suggestionsBox, controller) {
                            return suggestionsBox;
                          },
                          onSuggestionSelected: (suggestion) {
                            this._typeAheadController.text = suggestion.cityAscii + ", " + suggestion.country;
                            from = suggestion.id.toString();
                            _searchBarFrom = suggestion.cityAscii;
                          },
                          validator: (value) {
                            from = value.toString();

                            if (value.isEmpty) {
                              return t(context, 'select_city');
                            }
                          },
                          onSaved: (value) {
                            from = value;
                          },
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: TypeAheadFormField(
                          keepSuggestionsOnLoading: false,
                          debounceDuration: const Duration(milliseconds: 200),
                          textFieldConfiguration: TextFieldConfiguration(
                            onChanged: (value) {
                              to = null;
                            },
                            controller: this._typeAheadController2,
                            decoration: InputDecoration(
                              labelText: t(context, 'to'),
                              hintText: ' ${t(context, 'berlin')}',
                              hintStyle: TextStyle(color: Colors.grey[300]),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              prefixIcon: Icon(
                                MdiIcons.mapMarkerMultipleOutline,
                              ),
                              suffixIcon: IconButton(
                                padding: EdgeInsets.only(
                                  top: 5,
                                ),
                                icon: Icon(
                                  Icons.close,
                                  size: 15,
                                ),
                                onPressed: () {
                                  this._typeAheadController2.text = '';
                                  to = null;
                                },
                              ),
                            ),
                          ),
                          suggestionsCallback: (pattern) {
                            return getSuggestions(pattern);
                          },
                          itemBuilder: (context, suggestion) {
                            return ListTile(
                              title: Text(suggestion.cityAscii + ", " + suggestion.country),
                            );
                          },
                          transitionBuilder: (context, suggestionsBox, controller) {
                            return suggestionsBox;
                          },
                          onSuggestionSelected: (suggestion) {
                            this._typeAheadController2.text = suggestion.cityAscii + ", " + suggestion.country;
                            to = suggestion.id.toString();
                            _searchBarTo = suggestion.cityAscii;
                          },
                          validator: (value) {
                            to = value.toString();
                            if (value.isEmpty) {
                              return t(context, 'select_city');
                            }
                          },
                          onSaved: (value) => to = value,
                        ),
                      ),
                    ],
                  ),
//                  SizedBox(
//                    height: _expanded ? 20 : 0,
//                  ),
//                  Row(
//                    children: [
//                      Expanded(
//                        child: TextFormField(
//                          controller: _typeAheadController3,
//                          decoration: InputDecoration(
//                            border: OutlineInputBorder(
//                              borderRadius: BorderRadius.circular(20),
//                            ),
//                            prefixIcon: Icon(MdiIcons.weightKilogram),
//                            labelText: 'Weight Limit (in kg):',
//                            hintText: ' 3kg',
//                            hintStyle: TextStyle(color: Colors.grey[300]),
//                            suffixIcon: IconButton(
//                              padding: EdgeInsets.only(
//                                top: 5,
//                              ),
//                              icon: Icon(
//                                Icons.close,
//                                size: 15,
//                              ),
//                              onPressed: () {
//                                this._typeAheadController3.text = '';
//                                weight = null;
//                              },
//                            ),
//                          ),
//                          keyboardType: TextInputType.number,
////
//                          onChanged: (String val) {
//                            weight = val;
//                          },
//                          onSaved: (value) {
////                        _authData['email'] = value;
//                          },
//                        ),
//                      ),
//                      SizedBox(
//                        width: 10,
//                      ),
//                      Expanded(
//                        child: TextFormField(
//                          controller: _typeAheadController4,
//                          decoration: InputDecoration(
//                            prefixIcon: Icon(
//                              Icons.calendar_today,
//                            ),
//                            border: OutlineInputBorder(
//                              borderRadius: BorderRadius.circular(20),
//                            ),
//
//                            labelText: 'Date:',
//                            hintText: ' 1 January',
//                            hintStyle: TextStyle(color: Colors.grey[300]),
//
//                            suffixIcon: IconButton(
//                              padding: EdgeInsets.only(
//                                top: 5,
//                              ),
//                              icon: Icon(
//                                Icons.close,
//                                size: 15,
//                              ),
//                              onPressed: () {
//                                this._typeAheadController4.text = '';
//                                date = null;
//                              },
//                            ),
//                            //icon: Icon(Icons.location_on),
//                          ),
//                          keyboardType: TextInputType.number,
//                          onChanged: (String val) {
//                            _searchBarDate = val;
//                            date = val;
//                          },
//                          onSaved: (value) {
////                        _authData['email'] = value;
//                          },
//                        ),
//                      ),
//                    ],
//                  ),
                  Row(
                    children: [
                      GestureDetector(
                        child: Container(
                          height: _expanded ? 40 : 0,
                          width: 40,
                          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.red[200],
                            ),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Icon(
                            Icons.close,
                            color: Colors.red[400],
                          ),
                        ),
                        onTap: () {
                          var provider = Provider.of<OrdersTripsProvider>(context, listen: false);
                          from = null;
                          to = null;
                          weight = null;
                          date = null;
                          provider.isLoadingTrips = true;
                          provider.notify();
                          provider.fetchAndSetTrips();
                          urlFilter = null;
                          setState(() {
                            _expanded = !_expanded;
                          });
                        },
                      ),
                      Expanded(flex: 2, child: SizedBox()),
                      Expanded(
                        flex: 3,
                        child: RaisedButton(
//                          color: Theme.of(context).primaryColor,
                          color: Colors.green,
                          elevation: 2,
                          child: Container(
                            decoration: BoxDecoration(),
                            width: MediaQuery.of(context).size.width,
                            child: Center(
                              child: Text(
                                t(context, 'find_trips'),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
//                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          onPressed: () {
                            filterAndSetTrips();
                            setState(() {
                              _expanded = !_expanded;
                            });
//    filterAndSetOrders(from, to, weight, price);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
