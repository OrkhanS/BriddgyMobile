import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:optisend/widgets/filter_panel.dart';
import 'package:optisend/screens/item_screen.dart';
import 'package:optisend/main.dart';

class OrdersScreen extends StatefulWidget {
  static const routeName = '/orders';
  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
//  var deviceSize = MediaQuery.of(context).size;
  bool expands = true;
  String _startDate = "Starting from";
  String _endDate = "Untill";
  String _time = "Not set";
  DateTime startDate = DateTime.now();

  initState() {
    super.initState();
  }

  Widget _orderItem() {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, ItemScreen.routeName);
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
                child: Image(
                  image: AssetImage("assets/photos/facebook_logo.png"),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: <Widget>[
                    Text(
                      "Order Name", //Todo: title
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: <Widget>[
//                        Icon(
//                          Icons.location_on,
//                          color: Colors.blue[200],
//                        ),
                        Text(
                          "City1 - City2", //Todo: Source -> Destination
                          style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.normal),
                        ),
                      ],
                    ),
                    Text(
                      "14 February 2020", //Todo: date
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    Text(
                      "\$ 12.50", //Todo: date
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget filterBar() {
    return Form(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15), topRight: Radius.circular(15)),
          child: Container(
            child: FilterPanel(
              initiallyExpanded: expands,
              onExpansionChanged: (val) {
                val = !val;
              },
              subtitle: Text("Source:  Destination: "),
              title: Text(
                "Configure Filtering",
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 20, right: 20, bottom: 20),
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'From:',
                            //icon: Icon(Icons.place),
                          ),
                          keyboardType: TextInputType.text,
//
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
                            labelText: 'To:',
                            //icon: Icon(Icons.location_on),
                          ),

                          keyboardType: TextInputType.text,
//                      validator: (value) {
//                        if (value.isEmpty || !value.contains('@')) {
//                          return 'Invalid email!';
//                        } else
//                          return null; //Todo
//                      },
                          onSaved: (value) {
//                        _authData['email'] = value;
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Text(
                      "Range:",
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 15,
                      ),
                    ),
                    RaisedButton(
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
                            minTime: DateTime(2015, 1, 1),
                            maxTime: DateTime(2025, 12, 31), onConfirm: (date) {
                          print('confirm $date'); //todo: delete
                          _startDate =
                              '${date.day}/${date.month}/${date.year}  ';
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
//                                            Icon(
//                                              Icons.date_range,
//                                              size: 18.0,
//                                              color: Theme.of(context)
//                                                  .primaryColor,
//                                            ),
                                      Text(
                                        " $_startDate",
                                        style: TextStyle(
                                            color:
                                                Theme.of(context).primaryColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15.0),
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
                    RaisedButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0)),
                      elevation: 4.0,
                      color: Colors.white,
                      onPressed: () {
                        DatePicker.showDatePicker(context,
                            theme: DatePickerTheme(
                              itemStyle: TextStyle(color: Colors.blue[800]),
                              containerHeight: 300.0,
                            ),
                            showTitleActions: true,
                            minTime: DateTime(2015, 1, 1),
                            maxTime: DateTime(2025, 12, 31), onConfirm: (date) {
                          print('confirm $date'); //todo: delete
                          _endDate = '${date.day}/${date.month}/${date.year}  ';
                          setState(() {});
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
//                                            Icon(
//                                              Icons.date_range,
//                                              size: 18.0,
//                                              color: Theme.of(context)
//                                                  .primaryColor,
//                                            ),
                                      Text(
                                        " $_endDate",
                                        style: TextStyle(
                                            color:
                                                Theme.of(context).primaryColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15.0),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('oorderscreen'); //todo:delete

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        child: Icon(Icons.add),
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Center(
          child: Text(
            "Orders",
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
          Expanded(
            child: ListView(
              children: <Widget>[
                _orderItem(),
                _orderItem(),
                _orderItem(),
                _orderItem(),
                _orderItem(),
                _orderItem(),
              ],
            ),
          )
        ],
      ),
    );
  }
}
