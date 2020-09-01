import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:optisend/localization/localization_constants.dart';
import 'package:optisend/models/api.dart';
import 'package:optisend/models/city.dart';
import 'package:optisend/models/order.dart';
import 'package:optisend/providers/auth.dart';
import 'package:optisend/providers/ordersandtrips.dart';
import 'package:provider/provider.dart';

class FilterBottomBar extends StatefulWidget {
  var from, to, weight, price;
  OrdersTripsProvider ordersProvider;
  FilterBottomBar({this.ordersProvider, this.from, this.to, this.weight, this.price});
  @override
  _FilterBottomBarState createState() => _FilterBottomBarState();
}

class _FilterBottomBarState extends State<FilterBottomBar> {
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
  String urlFilter;
  var _expanded = false;

  Future filterAndSetOrders() async {
    var provider = widget.ordersProvider;
    provider.isLoadingOrders = true;
    provider.notify();
    if (urlFilter == null) urlFilter = Api.orders + "?";
    if (widget.from != null) {
      flagWeight == false && flagTo == false && flagFrom == false
          ? urlFilter = urlFilter + "origin=" + widget.from.toString()
          : urlFilter = urlFilter + "&origin=" + widget.from.toString();
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
    if (widget.price != null) {
      flagWeight == false && flagTo == false && flagFrom == false
          ? urlFilter = urlFilter + "min_price=" + widget.price.toString()
          : urlFilter = urlFilter + "&min_price=" + widget.price.toString();
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
            _suggested.add(Order.fromJson(data["results"][i]));
          }
          provider.orders = [];
          provider.orders = _suggested;
          provider.allOrdersDetails = {"next": data["next"], "count": data["count"]};
          provider.isLoadingOrders = false;
          provider.notify();
        },
      );
    });
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
    _searchBarWeight = t(context, 'any');
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      height: _expanded ? 265 : 55,
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
                            _searchBarFrom + " - " + _searchBarTo + " , " + _searchBarWeight + " ${t(context, 'kg')} ",
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
            duration: Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(horizontal: 15),
            height: _expanded ? 210 : 0,
            child: Form(
              child: Column(
                children: <Widget>[
                  Row(
                    children: [
                      Expanded(
                        child: TypeAheadFormField(
                          keepSuggestionsOnLoading: false,
                          debounceDuration: const Duration(milliseconds: 200),
                          textFieldConfiguration: TextFieldConfiguration(
                            onChanged: (value) {
                              widget.from = null;
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
                              title: Text(suggestion.cityAscii + ", " + suggestion.country),
                            );
                          },
                          transitionBuilder: (context, suggestionsBox, controller) {
                            return suggestionsBox;
                          },
                          onSuggestionSelected: (suggestion) {
                            this._typeAheadController.text = suggestion.cityAscii + ", " + suggestion.country;
                            widget.from = suggestion.id.toString();
                            _searchBarFrom = suggestion.cityAscii;
                          },
                          validator: (value) {
                            widget.from = value.toString();

                            if (value.isEmpty) {
                              return t(context, 'select_city');
                            }
                          },
                          onSaved: (value) {
                            widget.from = value;
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
                              widget.to = null;
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
                              title: Text(suggestion.cityAscii + ", " + suggestion.country),
                            );
                          },
                          transitionBuilder: (context, suggestionsBox, controller) {
                            return suggestionsBox;
                          },
                          onSuggestionSelected: (suggestion) {
                            this._typeAheadController2.text = suggestion.cityAscii + ", " + suggestion.country;
                            widget.to = suggestion.id.toString();
                            _searchBarTo = suggestion.cityAscii;
                          },
                          validator: (value) {
                            widget.to = value.toString();
                            if (value.isEmpty) {
                              return t(context, 'select_city');
                            }
                          },
                          onSaved: (value) => widget.to = value,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: _expanded ? 20 : 0,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _typeAheadController3,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            prefixIcon: Icon(MdiIcons.weightKilogram),
                            labelText: t(context, 'max_weight'),
                            hintText: ' 3 ${t(context, 'kg')}',
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
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: _typeAheadController4,
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              MdiIcons.currencyUsd,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),

                            labelText: t(context, 'reward_usd'),
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
                          onChanged: (String val) {
                            widget.price = val;
                          },
                          onSaved: (value) {
//                        _authData['email'] = value;
                          },
                        ),
                      ),
                    ],
                  ),
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
                          widget.from = null;
                          widget.to = null;
                          widget.weight = null;
                          widget.price = null;
                          provider.isLoadingOrders = true;
                          provider.notify();
                          provider.fetchAndSetOrders();
                          _searchBarFrom = t(context, 'anywhere');
                          _searchBarTo = t(context, 'anywhere');
                          _searchBarWeight = t(context, 'any');
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
                                t(context, 'find_orders'),
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
                            filterAndSetOrders();
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
