import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:optisend/models/api.dart';
import 'package:optisend/models/order.dart';
import 'package:optisend/models/trip.dart';
import 'package:optisend/models/user.dart';
import 'package:optisend/providers/auth.dart';
import 'package:optisend/widgets/order_widget.dart';
import 'package:optisend/widgets/trip_widget.dart';
import 'package:provider/provider.dart';

bool _iAmOrderer = true;
Trip _trip;
Order _order;

class NewContactScreen extends StatefulWidget {
  final User user;
  NewContactScreen(this.user);

  @override
  _NewContactScreenState createState() => _NewContactScreenState();
}

class _NewContactScreenState extends State<NewContactScreen> {
  int currentStep = 1;

  bool complete = false;
  @override
  Widget build(BuildContext context) {
    int myId = Provider.of<Auth>(context, listen: false).user.id;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: AppBar(
                backgroundColor: Colors.white,
                centerTitle: true,
                leading: IconButton(
                  color: Theme.of(context).primaryColor,
                  icon: Icon(
                    Icons.chevron_left,
                    size: 24,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                title: Text(
                  "New Contact ",
                  style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                ),
                elevation: 1,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Container(
                    height: 30,
                    width: 30,
                    decoration: BoxDecoration(
                      color: currentStep >= 1 ? Theme.of(context).primaryColor : Colors.grey[200],
                      borderRadius: BorderRadius.circular(50.0),
                    ),
                    child: Center(
                      child: Text(
                        "1",
                        style: TextStyle(
                            color: currentStep >= 1 ? Colors.white : Theme.of(context).primaryColor, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  customDivider(),
                  Container(
                    height: 30,
                    width: 30,
                    decoration: BoxDecoration(
                      color: currentStep >= 2 ? Theme.of(context).primaryColor : Colors.grey[200],
                      borderRadius: BorderRadius.circular(50.0),
                    ),
                    child: Center(
                      child: Text(
                        "2",
                        style: TextStyle(
                            color: currentStep >= 2 ? Colors.white : Theme.of(context).primaryColor, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  customDivider(),
                  Container(
                    height: 30,
                    width: 30,
                    decoration: BoxDecoration(
                      color: currentStep >= 3 ? Theme.of(context).primaryColor : Colors.grey[200],
                      borderRadius: BorderRadius.circular(50.0),
                    ),
                    child: Center(
                      child: Text(
                        "3",
                        style: TextStyle(
                            color: currentStep >= 3 ? Colors.white : Theme.of(context).primaryColor, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  customDivider(),
                  Container(
                    height: 30,
                    width: 30,
                    decoration: BoxDecoration(
                      color: currentStep >= 4 ? Theme.of(context).primaryColor : Colors.grey[200],
                      borderRadius: BorderRadius.circular(50.0),
                    ),
                    child: Center(
                      child: Text(
                        "4",
                        style: TextStyle(
                            color: currentStep >= 4 ? Colors.white : Theme.of(context).primaryColor, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (currentStep == 1) Step1(stepIncrement, setOrderer),
            if (currentStep == 2) Step2(stepIncrement, widget.user, myId),
            if (currentStep == 3) Step3(stepIncrement, widget.user, myId),
            if (currentStep == 4) Step4(),
          ],
        ),
      ),
    );
  }

  Container customDivider() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5),
      width: 25,
      height: 1,
      color: Colors.black26,
    );
  }

  void stepIncrement() {
    setState(() {
      //todo Rasul fix
      currentStep++;
    });
  }

  void setOrderer(bool me) {
    setState(() {
      _iAmOrderer = me;
    });
  }
}

class Step1 extends StatelessWidget {
  final Function next, setOrderer;

  Step1(this.next, this.setOrderer);
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          RaisedButton(
            padding: EdgeInsets.all(10),
            color: Colors.white,
            child: Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).primaryColor,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(200)),
                  child: Icon(
                    MdiIcons.packageVariantClosed,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                Text("I am orderer"),
              ],
            ),
            onPressed: () {
              next();
              setOrderer(true);
            },
          ),
          RaisedButton(
            padding: EdgeInsets.all(10),
            color: Colors.white,
            child: Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).primaryColor,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(200)),
                  child: Icon(
                    MdiIcons.roadVariant,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                Text("I am traveler"),
              ],
            ),
            onPressed: () {
              next();
              setOrderer(false);
            },
          ),
        ],
      ),
    );
  }
}

class Step2 extends StatefulWidget {
  final Function next;
  final User user;
  final int myId;
  Step2(this.next, this.user, this.myId);

  @override
  _Step2State createState() => _Step2State();
}

class _Step2State extends State<Step2> {
  List<Trip> trips = [];
  User user;
  bool tripsFetched = false;
  bool ordersFetched = false;

  @override
  void initState() {
    user = widget.user;
    loadTrips(trips, _iAmOrderer ? user.id : widget.myId, tripFetchDone);

    super.initState();
  }

  void tripFetchDone() {
    setState(() {
      tripsFetched = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _iAmOrderer ? Text("Select Trip of " + widget.user.firstName) : Text("Select Your trip"),
          ),
          Expanded(
            child: tripsFetched
                ? ListView.builder(
                    itemBuilder: (context, int i) {
                      var color = Colors.grey;
                      return GestureDetector(
                        onTap: () {
                          _trip = trips[i];
                          widget.next();
                        },
                        child: Container(
//                          decoration: BoxDecoration(border: Border.all(width: 1, color: color)),
                          child: TripSimpleWidget(trip: trips[i], i: i),
                        ),
                      );
                    },
                    itemCount: trips == null ? 0 : trips.length)
                : ListView(
                    children: [for (var i = 0; i < 10; i++) TripFadeWidget()],
                  ),
          )
        ],
      ),
    );
  }
}

class Step3 extends StatefulWidget {
  final Function next;
  final User user;
  final int myId;
  Step3(this.next, this.user, this.myId);

  @override
  _Step3State createState() => _Step3State();
}

class _Step3State extends State<Step3> {
  List<Order> orders = [];
  User user;
  bool tripsFetched = false;
  bool ordersFetched = false;

  @override
  void initState() {
    user = widget.user;
    loadOrders(orders, !_iAmOrderer ? user.id : widget.myId, orderFetchDone);

    super.initState();
  }

  void orderFetchDone() {
    setState(() {
      ordersFetched = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: !_iAmOrderer ? Text("Select Order of " + widget.user.firstName) : Text("Select Your Order"),
          ),
          Expanded(
            child: ordersFetched
                ? ListView.builder(
                    itemBuilder: (context, int i) {
                      if (orders[i].source.cityAscii == _trip.source.cityAscii)
                        return GestureDetector(
                          onTap: () {
                            _order = orders[i];
                            widget.next();
                          },
                          child: Container(
//                          decoration: BoxDecoration(border: Border.all(width: 1, color: color)),
                            child: OrderSimpleWidget(order: orders[i], i: i),
                          ),
                        );
                      else
                        return SizedBox();
                    },
                    itemCount: orders == null ? 0 : orders.length)
                : ListView(
                    children: [for (var i = 0; i < 10; i++) OrderFadeWidget()],
                  ),
          )
        ],
      ),
    );
  }
}

class Step4 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.max,
//        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("Summary"),
          ),
          TripSimpleWidget(
            trip: _trip,
          ),
          OrderSimpleWidget(
            order: _order,
          ),
          Expanded(
            child: SizedBox(
              width: 1,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: RaisedButton.icon(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//                            color: Theme.of(context).scaffoldBackgroundColor,
              color: Colors.green,

              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
              ),
              icon: Icon(
                MdiIcons.textBoxCheckOutline,
                color: Colors.white,
//                              color: Theme.of(context).primaryColor,
                size: 18,
              ),
              label: Text(
                "Confirm & Propose",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
//                                    color: Theme.of(context).primaryColor,
                ),
              ),
              onPressed: () {},
            ),
          )
        ],
      ),
    );
  }
}

void loadTrips(List<Trip> trips, int id, Function fetch) async {
  final url = Api.orderById + id.toString() + "/trips/";
  http.get(
    url,
    headers: {
      HttpHeaders.contentTypeHeader: "application/json",
    },
  ).then((onValue) {
    Map<String, dynamic> data = json.decode(onValue.body) as Map<String, dynamic>;

    for (var i = 0; i < data["results"].length; i++) {
//      print(data["results"][i]);
      trips.add(Trip.fromJson(data["results"][i]));
    }
    fetch();
  });
}

void loadOrders(List<Order> orders, int id, Function fetch) async {
  final url = Api.orderById + id.toString() + "/orders/";
  http.get(
    url,
    headers: {
      HttpHeaders.contentTypeHeader: "application/json",
    },
  ).then((onValue) {
    Map<String, dynamic> data = json.decode(onValue.body) as Map<String, dynamic>;

    for (var i = 0; i < data["results"].length; i++) {
//      print(data["results"][i]);
      orders.add(Order.fromJson(data["results"][i]));
    }
    fetch();
  });
}
