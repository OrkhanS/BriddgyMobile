import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:async';

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

  List _suggested = [];
  List _cities = [];
  bool flagFrom = false;
  bool flagTo = false; bool flagWeight = false;
  String from, to;
  String weight, price;
  final TextEditingController _typeAheadController = TextEditingController();
  final TextEditingController _typeAheadController2 = TextEditingController();

  bool isLoading = true;
  @override
  void initState() {
    super.initState();
  }

  List _trips = [];

 Future filterAndSetTrips(from, to, weight, price) async {
    String url = "http://briddgy.herokuapp.com/api/orders/?";
    if (from != null) {
      url = url + "origin=" + from;
      flagFrom = true;
    }
    if (to != null) {
      flagFrom == false ? url = url + "dest=" + to.toString() : url = url + "&dest=" + to.toString();
      flagTo=true;
    }
    if(weight!=null){
      flagTo == false && flagFrom==false ? url = url + "weight=" + weight.toString() : url = url + "&weight=" + weight.toString();
      flagWeight=true;
    }
    if(price!=null){
      flagWeight == false && flagTo == false && flagFrom==false ? url = url + "min_price=" + price.toString() : url = url + "&min_price=" + price.toString();
    }
    await http.get(
      url,
      headers: {HttpHeaders.CONTENT_TYPE: "application/json"},
    ).then((response) {
      setState(
        () {
          final dataOrders = json.decode(response.body) as Map<String, dynamic>;
          _trips = dataOrders["results"];
          isLoading = false;
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

  Future fetchAndSetTrips() async {
    const url = "http://briddgy.herokuapp.com/api/trips/";
    http.get(
      url,
      headers: {HttpHeaders.CONTENT_TYPE: "application/json"},
    ).then((response) {
      setState(
        () {
          final dataOrders = json.decode(response.body) as Map<String, dynamic>;
          _trips = dataOrders["results"];
          isLoading = false;
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
            filterAndSetTrips(from, to, weight, price);
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
                          onChanged: (String val) {
                            price = val;
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

  
//   Widget filterBar() {
//     return Form(
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
//         child: ClipRRect(
//           borderRadius: BorderRadius.only(
//               topLeft: Radius.circular(15), topRight: Radius.circular(15)),
//           child: Card(
//             elevation: 5,
//             color: Theme.of(context).primaryColor,
//             child: FilterPanel(
//               backgroundColor: Colors.white,
//               initiallyExpanded: false, //todo
//               onExpansionChanged: (val) {
//                 val = !val;
//               },
// //              subtitle: Text("Source:  Destination: "),
//               title: Container(
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.all(Radius.circular(5)),
//                   color: Colors.white,
//                   border: Border(),
//                 ),
//                 child: Padding(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
//                   child: Text(
//                     "Filters:",
//                     style: TextStyle(
//                         color: Theme.of(context).primaryColor,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 20),
//                   ),
//                 ),
//               ),
//               trailing: Icon(
//                 MdiIcons.filterPlusOutline,
//                 color: Colors.white,
//               ),
//               children: <Widget>[
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceAround,
//                   children: <Widget>[
//                     Expanded(
//                       child: Padding(
//                         padding: const EdgeInsets.only(
//                             left: 20, right: 20, bottom: 20),
//                         child: TextFormField(
//                           decoration: InputDecoration(
//                             labelText: 'From',
//                             //icon: Icon(Icons.place),
//                           ),
//                           keyboardType: TextInputType.text,
// //
//                           onSaved: (value) {
// //                        _authData['email'] = value;
//                           },
//                         ),
//                       ),
//                     ),
//                     Expanded(
//                       child: Padding(
//                         padding: const EdgeInsets.only(
//                             left: 20, right: 20, bottom: 20),
//                         child: TextFormField(
//                           decoration: InputDecoration(
//                             labelText: 'To',
//                             //icon: Icon(Icons.location_on),
//                           ),

//                           keyboardType: TextInputType.text,
// //                      validator: (value) {
// //                        if (value.isEmpty || !value.contains('@')) {
// //                          return 'Invalid email!';
// //                        } else
// //                          return null; //Todo
// //                      },
//                           onSaved: (value) {
// //                        _authData['email'] = value;
//                           },
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceAround,
//                   children: <Widget>[
//                     Expanded(
//                       child: Padding(
//                         padding: const EdgeInsets.only(
//                             left: 20, right: 20, bottom: 20),
//                         child: TextFormField(
//                           decoration: InputDecoration(
//                             labelText: 'Weight(max)',
//                             //icon: Icon(Icons.place),
//                           ),
//                           keyboardType: TextInputType.number,
// //
//                           onSaved: (value) {
// //                        _authData['email'] = value;
//                           },
//                         ),
//                       ),
//                     ),
//                     Expanded(
//                       child: Padding(
//                         padding: const EdgeInsets.only(
//                             left: 20, right: 20, bottom: 20),
//                         child: TextFormField(
//                           decoration: InputDecoration(
//                             labelText: 'Reward(min)',
//                             //icon: Icon(Icons.location_on),
//                           ),

//                           keyboardType: TextInputType.number,
// //                      validator: (value) {
// //                        if (value.isEmpty || !value.contains('@')) {
// //                          return 'Invalid email!';
// //                        } else
// //                          return null; //Todo
// //                      },
//                           onSaved: (value) {
// //                        _authData['email'] = value;
//                           },
//                         ),
//                       ),
//                     ),
//                   ],
//                 )
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

  getImageUrl(String a) {
    imageUrl = 'https://img.icons8.com/wired/2x/passenger-with-baggage.png';
    if (a != null) {
      imageUrl = 'https://briddgy.herokuapp.com/media/' + a + "/";
    }
    return imageUrl;
  }

  @override
  Widget build(BuildContext context) {
    fetchAndSetTrips();

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.pushNamed(context, AddTripScreen.routeName);
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
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
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
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          Icon(
                                            Icons.location_on,
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                          Text(
                                            "  " +
                                                _trips[i]["source"]
                                                    ["city_ascii"] +
                                                "  >  " +
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
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                          Text(
                                            "  " +
                                                _trips[i]["date"]
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
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                          Text(
                                            "  " +
                                                _trips[i]["weight_limit"]
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
                                    onPressed: () {},
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 20.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: <Widget>[
                                          Icon(
                                            MdiIcons.messageArrowRightOutline,
                                            color:
                                                Theme.of(context).primaryColor,
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
                    itemCount: _trips == null ? 0 : _trips.length,
                  ),
                )
              ],
            ),
    );
  }
}
