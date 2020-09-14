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
import 'package:briddgy/providers/auth.dart';
import 'package:briddgy/providers/ordersandtrips.dart';
import 'package:provider/provider.dart';

class OrderFilterBottomBar extends StatefulWidget {
  final OrdersTripsProvider ordersProvider;
  OrderFilterBottomBar({this.ordersProvider});
  @override
  _OrderFilterBottomBarState createState() => _OrderFilterBottomBarState();
}

class _OrderFilterBottomBarState extends State<OrderFilterBottomBar> {
  final TextEditingController _typeAheadController1 = TextEditingController();
  final TextEditingController _typeAheadController2 = TextEditingController();
  final TextEditingController _typeAheadController3 = TextEditingController();
  final TextEditingController _typeAheadController4 = TextEditingController();

  String from, to;
  String weight, price;

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
    print(from);
    print(urlFilter);
    if (urlFilter == null) urlFilter = Api.orders + "?";
    if (from != null && !urlFilter.contains("origin")) {
      flagWeight == false && flagTo == false && flagFrom == false
          ? urlFilter = urlFilter + "origin=" + from.toString()
          : urlFilter = urlFilter + "&origin=" + from.toString();
      flagFrom = true;
    }
    if (to != null && !urlFilter.contains("dest")) {
      flagWeight == false && flagTo == false && flagFrom == false
          ? urlFilter = urlFilter + "dest=" + to.toString()
          : urlFilter = urlFilter + "&dest=" + to.toString();
      flagTo = true;
    }
    if (weight != null && !urlFilter.contains("weight")) {
      flagWeight == false && flagTo == false && flagFrom == false
          ? urlFilter = urlFilter + "weight=" + weight.toString()
          : urlFilter = urlFilter + "&weight=" + weight.toString();
      flagWeight = true;
    }
    if (price != null && !urlFilter.contains("min_price")) {
      flagWeight == false && flagTo == false && flagFrom == false
          ? urlFilter = urlFilter + "min_price=" + price.toString()
          : urlFilter = urlFilter + "&min_price=" + price.toString();
    }
    print(urlFilter);

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
          print(data["results"].length);
          _suggested = [];
          for (var i = 0; i < data["results"].length; i++) {
            _suggested.add(Order.fromJson(data["results"][i]));
          }
          print("Suggested " + _suggested.length.toString());
          print("Orders before " + provider.orders.length.toString());
          provider.isLoadingOrders = false;
          provider.orders = [];
          provider.orders = _suggested;
          print("Orders after " + provider.orders.length.toString());
          provider.allOrdersDetails = {"next": data["next"], "count": data["count"]};
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
      duration: Duration(milliseconds: 250),
      curve: Curves.decelerate,
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
          if (_expanded)
            FutureBuilder(
                future: Future.delayed(const Duration(milliseconds: 250), () {
                  return "done";
                }),
                builder: (context, snapshot) {
                  if (snapshot.data == "done")
                    return Form(
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 15),
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
                                        from = null;
                                      },
                                      controller: this._typeAheadController1,
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
                                            setState(() {
                                              from = null;
                                              this._typeAheadController1.text = '';
                                            });
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
                                      this._typeAheadController1.text = suggestion.cityAscii + ", " + suggestion.country;
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
                                            setState(() {
                                              this._typeAheadController2.text = '';
                                              to = null;
                                            });
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
                            SizedBox(
                              height: _expanded ? 10 : 0,
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
                                          setState(() {
                                            this._typeAheadController3.text = '';
                                            weight = null;
                                          });
                                        },
                                      ),
                                    ),
                                    keyboardType: TextInputType.number,
//
                                    onChanged: (String val) {
                                      _searchBarWeight = val;
                                      weight = val;
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
                                          setState(() {
                                            this._typeAheadController4.text = '';
                                            price = null;
                                          });
                                        },
                                      ),
                                      //icon: Icon(Icons.location_on),
                                    ),
                                    keyboardType: TextInputType.number,
                                    onChanged: (String val) {
                                      price = val;
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

                                    provider.isLoadingOrders = true;
                                    provider.notify();
                                    provider.fetchAndSetOrders();
                                    _searchBarFrom = t(context, 'anywhere');
                                    _searchBarTo = t(context, 'anywhere');
                                    _searchBarWeight = t(context, 'any');
                                    setState(() {
                                      urlFilter = null;

                                      this._typeAheadController1.text = '';
                                      this._typeAheadController2.text = '';
                                      this._typeAheadController3.text = '';
                                      this._typeAheadController4.text = '';

                                      from = null;
                                      to = null;
                                      weight = null;
                                      price = null;
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
                    );
                  else
                    return SizedBox();
                })
        ],
      ),
    );
  }
}
