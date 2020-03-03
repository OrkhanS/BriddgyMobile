import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:optisend/screens/my_trips.dart';
import 'package:optisend/screens/orders_screen.dart';
import 'package:optisend/main.dart';

class AddTripScreen extends StatefulWidget {
  static const routeName = '/trip/add_trip';

  @override
  _AddTripScreenState createState() => _AddTripScreenState();
}

class _AddTripScreenState extends State<AddTripScreen> {
  String departureDate = DateTime.now().toString().substring(0, 11);
  String from, to;
  String weight;
  String _selectedCity;
  List _suggested = [];
  List _cities = [];
  bool isLoading = true;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _typeAheadController = TextEditingController();
  final TextEditingController _typeAheadController2 = TextEditingController();

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
    final deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          color: Theme.of(context).primaryColor,
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          "Add Trip", //Todo: item name
          style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold),
        ),
        elevation: 1,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding:
                      const EdgeInsets.only(left: 20.0, top: 20, bottom: 20),
                  child: Text(
                    "Trip Details",
                    style: TextStyle(
                        fontSize: 25, color: Theme.of(context).primaryColor),
                  ),
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 10),
              width: deviceWidth * 0.8,
              child: RaisedButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0)),
                elevation: 4.0,
                onPressed: () {
                  DatePicker.showDatePicker(context,
                      theme: DatePickerTheme(
                        itemStyle: TextStyle(color: Colors.blue[800]),
                        containerHeight: 300.0,
                      ),
                      showTitleActions: true,
                      minTime: DateTime.now(),
                      maxTime: DateTime(2025, 12, 31), onConfirm: (date) {
                    departureDate = '${date.day}/${date.month}/${date.year}  ';
                  }, currentTime: DateTime.now(), locale: LocaleType.en);
                },
                child: Container(
                  alignment: Alignment.center,
                  height: 40.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                    " Date:  $departureDate",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Theme.of(context).primaryColor,
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
            Container(
              width: deviceWidth * 0.8,
              child: TypeAheadFormField(
                keepSuggestionsOnLoading: false,
                debounceDuration: const Duration(milliseconds: 200),
                textFieldConfiguration: TextFieldConfiguration(
                  onSubmitted: (val) {
                    from = val;
                  },
                  controller: this._typeAheadController,
                  decoration: InputDecoration(
                      labelText: 'From', icon: Icon(Icons.location_on)),
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
                transitionBuilder: (context, suggestionsBox, controller) {
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
            Container(
              width: deviceWidth * 0.8,
              child: TypeAheadFormField(
                keepSuggestionsOnLoading: false,
                debounceDuration: const Duration(milliseconds: 200),
                textFieldConfiguration: TextFieldConfiguration(
                  onSubmitted: (val) {
                    to = val;
                  },
                  controller: this._typeAheadController2,
                  decoration: InputDecoration(
                      labelText: 'To', icon: Icon(Icons.location_on)),
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
                transitionBuilder: (context, suggestionsBox, controller) {
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
            Container(
              width: deviceWidth * 0.8,
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'Weight limit:',
                  icon: Icon(Icons.format_size),
                ),
                keyboardType: TextInputType.number,
                onChanged: (String val) {
                  weight = val;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: RaisedButton(
                  color: Theme.of(context).primaryColor,

                  elevation: 2,
//                            color: Theme.of(context).primaryColor,
                  child: Container(
                    width: deviceWidth * 0.7,
                    child: Center(
                      child: Text(
                        "Add Trip",
                        style: TextStyle(
                          fontSize: 19,
                          color: Colors.white,
//                                  fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  onPressed: () {
                    //var token = Provider.of<Auth>(context, listen: false).token;
                    var token = '40694c366ab5935e997a1002fddc152c9566de90';
                    const url = "http://briddgy.herokuapp.com/api/trips/";
                    http.post(url,
                        headers: {
                          HttpHeaders.CONTENT_TYPE: "application/json",
                          "Authorization": "Token " + token,
                        },
                        body: json.encode({
                          "source": from,
                          "destination": to,
                          "date": DateTime.now().toString().substring(0, 10),
                          "weight_limit": weight,
                        }));
                    Navigator.of(context).pushNamed(MyTrips.routeName);
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
