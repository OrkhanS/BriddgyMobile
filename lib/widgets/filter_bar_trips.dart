import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:optisend/models/api.dart';
import 'package:optisend/models/trip.dart';
import 'package:optisend/providers/auth.dart';
import 'package:optisend/providers/ordersandtrips.dart';
import 'package:provider/provider.dart';

class FilterBarTrip extends StatefulWidget {
  var from, to, weight, date;
  OrdersTripsProvider ordersProvider;
  FilterBarTrip({this.ordersProvider, this.from, this.to, this.weight, this.date});
  @override
  _FilterBarStateTrip createState() => _FilterBarStateTrip();
}

class _FilterBarStateTrip extends State<FilterBarTrip> {
  final TextEditingController _typeAheadController = TextEditingController();
  final TextEditingController _typeAheadController2 = TextEditingController();
  final TextEditingController _typeAheadController3 = TextEditingController();
  final TextEditingController _typeAheadController4 = TextEditingController();

  String _searchBarFrom = "Anywhere";
  String _searchBarTo = "Anywhere";
  String _searchBarDate = "Any";

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
    provider.isLoadingTrips = true; provider.notify();

    if(urlFilter==null)urlFilter = Api.trips + "?";
    if (widget.from != null) {
      flagWeight == false && flagTo == false && flagFrom == false 
          ? urlFilter = urlFilter + "origin=" + widget.from 
          : urlFilter = urlFilter + "&origin=" + widget.from;
      flagFrom = true;
    }
    if (widget.to != null) {
      flagWeight == false && flagTo == false && flagFrom == false
          ? urlFilter = urlFilter + "dest=" + widget.to.toString()
          : urlFilter = urlFilter + "&dest=" + widget.to.toString();
      flagTo = true;
    }
    if (widget.weight != null) {
      flagWeight == false && flagTo == false && flagFrom == false
          ? urlFilter = urlFilter + "weight=" + widget.weight.toString()
          : urlFilter = urlFilter + "&weight=" + widget.weight.toString();
      flagWeight = true;
    }
      await http.get(
        urlFilter,
        headers: Provider.of<Auth>(context, listen: false).isAuth
          ? {
              HttpHeaders.contentTypeHeader: "application/json",
              "Authorization": "Token " + Provider.of<Auth>(context, listen: false).myTokenFromStorage,
            }
          : {
              HttpHeaders.contentTypeHeader: "application/json",
            }, 
      ).then((response) {
        setState(
          () {
            Map<String, dynamic> data =
                json.decode(response.body) as Map<String, dynamic>;
            _suggested=[];
            for (var i = 0; i < data["results"].length; i++) {
              _suggested.add(Trip.fromJson(data["results"][i]));
            }
            widget.ordersProvider.trips = []; widget.ordersProvider.trips = _suggested; 
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
    String url = "https://briddgy.herokuapp.com/api/cities/?search=" + pattern;
    await http.get(
      url,
      headers: {HttpHeaders.contentTypeHeader: "application/json"},
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
      _cities.add(_suggested[i]["city_ascii"].toString() + ", " + _suggested[i]["country"].toString() + ", " + _suggested[i]["id"].toString());
    }
    return _cities;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      height: _expanded ? 480 : 80,
      child: Card(
        margin: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            InkWell(
              highlightColor: Theme.of(context).primaryColor,
              onTap: () {
                setState(() {
                  _expanded = !_expanded;
                });
              },
              child: ListTile(
                title: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    color: Colors.white,
                    border: Border(),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
                    child: Text(
                      _searchBarFrom + " - " + _searchBarTo + " , " + _searchBarDate + " date ",
                      style: TextStyle(color: Colors.blue[800]
                          // Theme.of(context).primaryColor,
                          // fontWeight: FontWeight.bold,
                          // fontSize: 20
                          ),
                    ),
                  ),
                ),
                trailing: IconButton(
                  icon: Icon(MdiIcons.filterPlusOutline),
                  onPressed: () {
                    setState(() {
                      _expanded = !_expanded;
                    });
                  },
                ),
              ),
            ),
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
              height: _expanded ? 400 : 0,
              child: Form(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
                    child: Column(
                      children: <Widget>[
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
                            child: TypeAheadFormField(
                              keepSuggestionsOnLoading: false,
                              debounceDuration: const Duration(milliseconds: 200),
                              textFieldConfiguration: TextFieldConfiguration(
                                onChanged: (value) {
                                  widget.from = null;
                                },
                                controller: this._typeAheadController,
                                decoration: InputDecoration(
                                  labelText: 'From',
                                  hintText: ' Paris',
                                  hintStyle: TextStyle(color: Colors.grey[300]),
                                  prefixIcon: Icon(
                                    MdiIcons.mapMarkerRightOutline,
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
                                      widget.from = null;
                                    },
                                  ),
                                ),
                              ),
                              suggestionsCallback: (pattern) {
                                return getSuggestions(pattern);
                              },
                              itemBuilder: (context, suggestion) {
                                return ListTile(
                                  title: Text(suggestion.toString().split(", ")[0] + ", " + suggestion.toString().split(", ")[1]),
                                );
                              },
                              transitionBuilder: (context, suggestionsBox, controller) {
                                return suggestionsBox;
                              },
                              onSuggestionSelected: (suggestion) {
                                this._typeAheadController.text = suggestion.toString().split(", ")[0] + ", " + suggestion.toString().split(", ")[1];
                                widget.from = suggestion.toString().split(", ")[2];
                                _searchBarFrom = suggestion.toString().split(", ")[0];
                              },
                              validator: (value) {
                                widget.from = value;

                                if (value.isEmpty) {
                                  return 'Please select a city';
                                }
                              },
                              onSaved: (value) {
                                widget.from = value;
                              },
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
                            child: TypeAheadFormField(
                              keepSuggestionsOnLoading: false,
                              debounceDuration: const Duration(milliseconds: 200),
                              textFieldConfiguration: TextFieldConfiguration(
                                onChanged: (value) {
                                  widget.to = null;
                                },
                                controller: this._typeAheadController2,
                                decoration: InputDecoration(
                                  labelText: 'To',
                                  hintText: ' Berlin',
                                  hintStyle: TextStyle(color: Colors.grey[300]),
                                  prefixIcon: Icon(
                                    MdiIcons.mapMarkerCheckOutline,
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
                                      widget.to = null;
                                    },
                                  ),
                                ),
                              ),
                              suggestionsCallback: (pattern) {
                                return getSuggestions(pattern);
                              },
                              itemBuilder: (context, suggestion) {
                                return ListTile(
                                  title: Text(suggestion.toString().split(", ")[0] + ", " + suggestion.toString().split(", ")[1]),
                                );
                              },
                              transitionBuilder: (context, suggestionsBox, controller) {
                                return suggestionsBox;
                              },
                              onSuggestionSelected: (suggestion) {
                                this._typeAheadController2.text = suggestion.toString().split(", ")[0] + ", " + suggestion.toString().split(", ")[1];
                                widget.to = suggestion.toString().split(", ")[2];
                                _searchBarTo = suggestion.toString().split(", ")[0];
                              },
                              validator: (value) {
                                widget.to = value;
                                if (value.isEmpty) {
                                  return 'Please select a city';
                                }
                              },
                              onSaved: (value) => widget.to = value,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 30, right: 30, top: 5, bottom: 20),
                            child: TextFormField(
                              controller: _typeAheadController4,
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  MdiIcons.currencyUsd,
                                ),

                                labelText: 'Last Date:',
                                hintText: '2020-10-05',
                                hintStyle: TextStyle(color: Colors.grey[300]),

                                suffixIcon: IconButton(
                                  padding: EdgeInsets.only(
                                    top: 5,
                                  ),
                                  icon: Icon(
                                    Icons.close,
                                    size: 15,
                                  ),
                                  onPressed: () {
                                    this._typeAheadController4.text = '';
                                    widget.date = null;
                                  },
                                ),
                                //icon: Icon(Icons.location_on),
                              ),

                              keyboardType: TextInputType.number,
                              onChanged: (String val) {
                                widget.date = val;
                              },
                              onSaved: (value) {
//                        _authData['email'] = value;
                              },
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
                            child: TextFormField(
                              controller: _typeAheadController3,
                              decoration: InputDecoration(
                                prefixIcon: Icon(MdiIcons.weightKilogram),
                                labelText: 'Weight maximum (in kg):',
                                hintText: ' 3kg',
                                hintStyle: TextStyle(color: Colors.grey[300]),
                                suffixIcon: IconButton(
                                  padding: EdgeInsets.only(
                                    top: 5,
                                  ),
                                  icon: Icon(
                                    Icons.close,
                                    size: 15,
                                  ),
                                  onPressed: () {
                                    this._typeAheadController3.text = '';
                                    widget.weight = null;
                                  },
                                ),
                              ),
                              keyboardType: TextInputType.number,
//
                              onChanged: (String val) {
                                _searchBarDate = val;
                                widget.weight = val;
                              },
                              onSaved: (value) {
//                        _authData['email'] = value;
                              },
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
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
                                      "Search",
                                      style: TextStyle(
                                        fontSize: 19,
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
                          ),
                        ),
                         Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 15),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: RaisedButton(
                                color: Theme.of(context).primaryColor,
                                elevation: 2,
                                child: Container(
                                  decoration: BoxDecoration(),
                                  width: MediaQuery.of(context).size.width,
                                  child: Center(
                                    child: Text(
                                      "Reset",
                                      style: TextStyle(
                                        fontSize: 19,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                onPressed: () {
                                  var provider = Provider.of<OrdersTripsProvider>(context,listen:false);
                                  widget.from=null; widget.to=null;
                                  widget.weight=null; widget.date=null;
                                  provider.isLoadingTrips=true; provider.fetchAndSetTrips();
                                  urlFilter=null;
                                  setState(() {
                                    _expanded = !_expanded;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                    
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
