import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class FilterBar extends StatefulWidget {
  var from, to, weight, price, orders;
  FilterBar({this.from, this.to, this.weight, this.price, this.orders});
  @override
  _FilterBarState createState() => _FilterBarState();
}

class _FilterBarState extends State<FilterBar> {
  final TextEditingController _typeAheadController = TextEditingController();
  final TextEditingController _typeAheadController2 = TextEditingController();
  final TextEditingController _typeAheadController3 = TextEditingController();
  final TextEditingController _typeAheadController4 = TextEditingController();

  String _searchBarFrom = "Anywhere";
  String _searchBarTo = "Anywhere";
  String _searchBarWeight = "Any";

  List _suggested = [];
  List _cities = [];
  bool isLoading = true;

  bool flagFrom = false;
  bool flagTo = false;
  bool flagWeight = false;
  String urlFilter = "";
  var _expanded = false;

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
          widget.orders = dataOrders["results"];isLoading = false;
          //itemCount = dataOrders["count"];
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
              highlightColor: Colors.yellow,
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 5),
                    child: Text(
                      _searchBarFrom +
                          " - " +
                          _searchBarTo +
                          " , " +
                          _searchBarWeight +
                          " kg ",
                      style: TextStyle(color: Colors.blue[800]
                          // Theme.of(context).primaryColor,
                          // fontWeight: FontWeight.bold,
                          // fontSize: 20
                          ),
                    ),
                  ),
                ),
                trailing: IconButton(
                  icon: Icon(
                      _expanded ? MdiIcons.filterVariantPlus : Icons.filter),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15)),
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 5),
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
                                title: Text(
                                    suggestion.toString().split(", ")[0] +
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
                              widget.from =
                                  suggestion.toString().split(", ")[2];
                              _searchBarFrom =
                                  suggestion.toString().split(", ")[0];
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
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 5),
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
                                title: Text(
                                    suggestion.toString().split(", ")[0] +
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
                              widget.to = suggestion.toString().split(", ")[2];
                              _searchBarTo =
                                  suggestion.toString().split(", ")[0];
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
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 5),
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
                              _searchBarWeight = val;
                              widget.weight = val;
                            },
                            onSaved: (value) {
//                        _authData['email'] = value;
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 30, right: 30, top: 5, bottom: 20),
                          child: TextFormField(
                            controller: _typeAheadController4,
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                MdiIcons.currencyUsd,
                              ),

                              labelText: 'Reward minimum (in usd):',
                              hintText: ' 10\$',
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
                                  widget.price = null;
                                },
                              ),
                              //icon: Icon(Icons.location_on),
                            ),

                            keyboardType: TextInputType.number,
//                      validator: (value) {
//                        if (value.isEmpty || !value.contains('@')) {
//                          return 'Invalid email!';
//                        } else
//                          return null; //Todo
//                      },
                            onChanged: (String val) {
                              widget.price = val;
                            },
                            onSaved: (value) {
//                        _authData['email'] = value;
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 15),
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
                                setState(() {
                                  _expanded = !_expanded;
                                });
//    filterAndSetOrders(from, to, weight, price);
                              },
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
