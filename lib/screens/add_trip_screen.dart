import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:optisend/localization/localization_constants.dart';
import 'package:optisend/models/api.dart';
import 'package:optisend/models/city.dart';
import 'package:optisend/providers/auth.dart';
import 'package:optisend/providers/messages.dart';
import 'package:optisend/providers/ordersandtrips.dart';
import 'package:flushbar/flushbar.dart';
import 'package:optisend/widgets/progress_indicator_widget.dart';
import 'package:provider/provider.dart';

import 'my_trips.dart';

class AddTripScreen extends StatefulWidget {
  OrdersTripsProvider orderstripsProvider;
  var token;
  AddTripScreen({this.orderstripsProvider, this.token});
  static const routeName = '/trip/add_trip';

  @override
  _AddTripScreenState createState() => _AddTripScreenState();
}

class _AddTripScreenState extends State<AddTripScreen> {
  String departureDate = DateTime.now().toString().substring(0, 11);
  String from, to;
  String weight;
  List _suggested = [];
  List _cities = [];
  bool isLoading = true;
  bool addTripButton = true;
  String description;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _typeAheadController = TextEditingController();
  final TextEditingController _typeAheadController2 = TextEditingController();

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
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: AppBar(
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
                  t(context, 'trip-add'),
                  style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                ),
                elevation: .5,
              ),
            ),
//            Row(
//              mainAxisAlignment: MainAxisAlignment.start,
//              children: <Widget>[
//                Padding(
//                  padding: const EdgeInsets.only(left: 20.0, top: 20, bottom: 20),
//                  child: Text(
//                    "Trip Details",
//                    style: TextStyle(fontSize: 25, color: Theme.of(context).primaryColor),
//                  ),
//                ),
//              ],
//            ),

            SizedBox(
              height: 40,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: deviceWidth * 0.4,
                  child: TypeAheadFormField(
                    keepSuggestionsOnLoading: false,
                    debounceDuration: const Duration(milliseconds: 200),
                    textFieldConfiguration: TextFieldConfiguration(
                      onSubmitted: (val) {
                        from = val.toString();
                      },
                      controller: this._typeAheadController,
                      decoration: InputDecoration(labelText: t(context, 'from'), icon: Icon(MdiIcons.bridge)),
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
                    },
                    validator: (value) {
                      from = value.toString();
                      if (value.isEmpty) {
                        return t(context, 'select_city');
                      }
                    },
                    onSaved: (value) => from = value,
                  ),
                ),
                Container(
                  width: deviceWidth * 0.4,
                  child: TypeAheadFormField(
                    keepSuggestionsOnLoading: false,
                    debounceDuration: const Duration(milliseconds: 200),
                    textFieldConfiguration: TextFieldConfiguration(
                      onSubmitted: (val) {
                        to = val.toString();
                      },
                      controller: this._typeAheadController2,
                      decoration: InputDecoration(labelText: t(context, 'to'), icon: Icon(MdiIcons.mapMarkerMultipleOutline)),
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
            Container(
              width: deviceWidth * 0.8,
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: t(context, 'max_weight'),
                  icon: Icon(MdiIcons.weightKilogram),
                ),
                maxLength: 4,
                keyboardType: TextInputType.number,
                onChanged: (String val) {
                  weight = val;
                },
              ),
            ),
            Container(
              width: deviceWidth * 0.8,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: 300.0,
                ),
                child: TextField(
                  maxLines: null,
                  decoration: InputDecoration(
                    labelText: t(context, 'description'),
                    icon: Icon(MdiIcons.informationOutline),
                  ),
                  onChanged: (String val) {
                    description = val;
                  },
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
              width: deviceWidth * 0.8,
              child: RaisedButton(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
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
                    setState(() {
                      departureDate = '${date.year}-${date.month}-${date.day}';
                    });
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
                                  color: Theme.of(context).primaryColor,
                                ),
                                Center(
                                  child: Text(
                                    "   ${t(context, 'date')}:  " + departureDate,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold, fontSize: 15.0),
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
            addTripButton
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 40),
                    child: RaisedButton(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      color: Colors.green,
//                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                      child: Container(
                        width: double.infinity,
                        child: Text(
                          t(context, 'trip-add'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            fontSize: 19,
                          ),
                        ),
                      ),
                      onPressed: () {
                        var token = Provider.of<Auth>(context, listen: false).token;
                        const url = Api.trips;
                        if (from == null || to == null || weight == null) {
                          setState(() {
                            addTripButton = true;
                          });
                          Flushbar(
                            title: "${t(context, 'warning')}!",
                            message: t(context, 'fill_fields'),
                            padding: const EdgeInsets.all(8),
                            borderRadius: 10,
                            duration: Duration(seconds: 3),
                          )..show(context);
                        } else {
                          setState(() {
                            addTripButton = false;
                          });
                          http
                              .post(url,
                                  headers: {
                                    HttpHeaders.contentTypeHeader: "application/json",
                                    "Authorization": "Token " + token,
                                  },
                                  body: json.encode({
                                    "source": from,
                                    "destination": to,
                                    "date": departureDate.toString(),
                                    "weight_limit": weight,
                                    "description": description
                                  }))
                              .then((value) {
                            if (value.statusCode == 201) {
                              widget.orderstripsProvider.isLoadingMyTrips = true;
                              widget.orderstripsProvider.fetchAndSetMyTrips(widget.token);
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (__) => MyTrips()),
                              );

                              Flushbar(
                                title: t(context, 'trip_added'),
                                message: t(context, 'trips_in_acc_page'),
                                padding: const EdgeInsets.all(8),
                                borderRadius: 10,
                                duration: Duration(seconds: 5),
                              )..show(context);
                            } else {
                              setState(() {
                                addTripButton = true;
                              });
                              Flushbar(
                                title: "${t(context, 'warning')}!",
                                message: t(context, 'trip_not_added'),
                                padding: const EdgeInsets.all(8),
                                borderRadius: 10,
                                duration: Duration(seconds: 3),
                              )..show(context);
                            }
                          });
                        }
                      },
                    ),
                  )
                : ProgressIndicatorWidget(show: true),
          ],
        ),
      ),
    );
  }
}
