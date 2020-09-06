import 'dart:convert';
import 'dart:io';
import 'package:flushbar/flushbar.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:briddgy/localization/localization_constants.dart';
import 'package:briddgy/models/api.dart';
import 'package:briddgy/models/order.dart';
import 'package:briddgy/models/trip.dart';
import 'package:briddgy/models/user.dart';
import 'package:briddgy/providers/auth.dart';
import 'package:briddgy/providers/messages.dart';
import 'package:briddgy/widgets/order_widget.dart';
import 'package:briddgy/widgets/progress_indicator_widget.dart';
import 'package:briddgy/widgets/trip_widget.dart';
import 'package:provider/provider.dart';

bool _iAmOrderer = true;
Trip _trip;
Order _order;
User _requestingUser;
User _proposedUser;

class NewContactScreen extends StatefulWidget {
  final User user;
  NewContactScreen(this.user);

  @override
  _NewContactScreenState createState() => _NewContactScreenState();
}

class _NewContactScreenState extends State<NewContactScreen> {
  int currentStep;
  @override
  void initState() {
    currentStep = 1;
    _requestingUser = Provider.of<Auth>(context, listen: false).user;
    _proposedUser = widget.user;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                    Provider.of<Messages>(context, listen: false).notifFun();
                  },
                ),
                title: Text(
                  t(context, 'propose_contract'),
                  style: TextStyle(
//                    color: Colors.black,
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
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
            if (currentStep == 2) Step2(stepIncrement),
            if (currentStep == 3) Step3(stepIncrement),
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            RaisedButton(
              padding: EdgeInsets.all(10),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Container(
                    height: 150,
                    width: 150,
                    padding: EdgeInsets.all(10),
                    child: SvgPicture.asset(
                      "assets/photos/orderer.svg",
                    ),
                  ),
                  Text(
                    t(context, 'i-am-orderer'),
                    style: TextStyle(fontSize: 20),
                  ),
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Container(
                    height: 150,
                    width: 150,
                    padding: EdgeInsets.all(10),
                    child: SvgPicture.asset("assets/photos/traveler.svg"),
                  ),
                  Text(
                    t(context, 'i-am-traveler'),
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              ),
              onPressed: () {
                next();
                setOrderer(false);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class Step2 extends StatefulWidget {
  final Function next;
  Step2(this.next);

  @override
  _Step2State createState() => _Step2State();
}

class _Step2State extends State<Step2> {
  List<Trip> trips = [];
  bool tripsFetched = false;
  bool ordersFetched = false;

  @override
  void initState() {
    loadTrips(trips, _iAmOrderer ? _proposedUser.id : _requestingUser.id, tripFetchDone);

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
            padding: EdgeInsets.symmetric(horizontal: 0),
            child: Text(
              _iAmOrderer ? t(context, 'select_trip_of') + _proposedUser.firstName + " " + _proposedUser.lastName : t(context, 'select_your_trip'),
              style: TextStyle(fontSize: 20),
            ),
          ),
          Expanded(
            child: tripsFetched
                ? ListView.builder(
                    itemBuilder: (context, int i) {
                      var color = Colors.grey;
                      return InkWell(
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
  Step3(this.next);

  @override
  _Step3State createState() => _Step3State();
}

class _Step3State extends State<Step3> {
  List<Order> orders = [];
  bool tripsFetched = false;
  bool ordersFetched = false;

  @override
  void initState() {
    loadOrders(orders, !_iAmOrderer ? _proposedUser.id : _requestingUser.id, orderFetchDone);

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
            padding: EdgeInsets.symmetric(horizontal: 0),
            child: Text(
              !_iAmOrderer ? t(context, 'select_order_of') + _proposedUser.firstName + " " + _proposedUser.lastName : t(context, 'select_your_order'),
              style: TextStyle(fontSize: 20),
            ),
          ),
          Expanded(
            child: ordersFetched
                ? ListView.builder(
                    itemBuilder: (context, int i) {
                      if (true)
                        return InkWell(
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

class Step4 extends StatefulWidget {
  Step4();

  @override
  _Step4State createState() => _Step4State();
}

class _Step4State extends State<Step4> {
  bool proposingContract = false;

  Future signContract() async {
    setState(() {
      proposingContract = true;
    });
    final url = Api.applyForDelivery;
    http
        .put(
      url,
      headers: {
        HttpHeaders.contentTypeHeader: "application/json",
        "Authorization": "Token " + Provider.of<Auth>(context, listen: false).myTokenFromStorage,
      },
      body: json.encode(
        {
          'order': _order.id,
          'trip': _trip.id,
        },
      ),
    )
        .then((response) {
      if (response.statusCode == 201) {
        var my, opp;
        if (_order.id == _requestingUser.id) {
          my = _order;
          opp = _trip;
        } else {
          my = _trip;
          opp = _order;
        }
        Map body = {"type": _iAmOrderer ? "order" : "trip", "my": my, "opp": opp};
        Provider.of<Messages>(context, listen: false).contractBody = json.encode(body);
        Provider.of<Messages>(context, listen: false).notifFun();
        Navigator.pop(context);
      } else {
        print(response.body);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
//        mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
//            Expanded(child: SizedBox()),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: SvgPicture.asset(
                "assets/photos/handshake.svg",
                height: 150,
                width: 250,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                t(context, 'summary'),
                style: TextStyle(
                  fontSize: 22,
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Row(
              children: <Widget>[
                Text(
                  t(context, 'contract_proposed_by'),
                  style: TextStyle(fontSize: 17, color: Colors.grey[600]),
                ),
                Expanded(
                  child: SizedBox(
                    height: 1,
                  ),
                ),
                Text(
                  "${_requestingUser.firstName} ${_requestingUser.lastName}",
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Text(
                  t(context, 'order_owner'),
                  style: TextStyle(fontSize: 17, color: Colors.grey[600]),
                ),
                Expanded(child: SizedBox()),
                Text(
                  " ${_order.owner.firstName} ${_order.owner.lastName}",
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Text(
                  "${t(context, 'order')}: ",
                  style: TextStyle(fontSize: 17, color: Colors.grey[600]),
                ),
                Expanded(child: SizedBox()),
                Text(
                  " ${_order.title}",
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Text(
                  "${t(context, 'deliverer')}: ",
                  style: TextStyle(fontSize: 17, color: Colors.grey[600]),
                ),
                Expanded(child: SizedBox()),
                Text(
                  " ${_trip.owner.firstName} ${_trip.owner.lastName}",
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Text(
                  "${t(context, 'from')}:",
                  style: TextStyle(fontSize: 17, color: Colors.grey[600]),
                ),
                Expanded(child: SizedBox()),
                Text(
                  " ${_trip.source.cityAscii}",
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Text(
                  "${t(context, 'to')}:",
                  style: TextStyle(fontSize: 17, color: Colors.grey[600]),
                ),
                Expanded(child: SizedBox()),
                Text(
                  "${_trip.destination.cityAscii}",
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Text(
                  "${t(context, 'trip_date')}:",
                  style: TextStyle(fontSize: 17, color: Colors.grey[600]),
                ),
                Expanded(child: SizedBox()),
                Text(
                  DateFormat('d MMMM yyyy').format(_trip.date),
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Text(
                  "${t(context, 'reward')}:",
                  style: TextStyle(fontSize: 17, color: Colors.grey[600]),
                ),
                Expanded(child: SizedBox()),
                Text(
                  "\$${_order.price}",
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
//            TripSimpleWidget(
//              trip: _trip,
//            ),
//            OrderSimpleWidget(
//              order: _order,
//            ),

            Expanded(
              child: SizedBox(
                width: 1,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                if (!proposingContract)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: RaisedButton.icon(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//                            color: Theme.of(context).scaffoldBackgroundColor,
                      color: Colors.white,

                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                      icon: Icon(
                        MdiIcons.cancel,
                        color: Colors.red,
//                              color: Theme.of(context).primaryColor,
                        size: 18,
                      ),
                      label: Text(
                        t(context, 'cancel'),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
//                                    color: Theme.of(context).primaryColor,
                        ),
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text(t(context, 'cancel_contract_prompt')),
                            content: Text("This action cannot be undone"),
                            actions: <Widget>[
                              FlatButton(
                                child: Text(
                                  'No',
                                  style: TextStyle(color: Colors.red),
                                ),
                                onPressed: () {
                                  Navigator.of(ctx).pop();
                                },
                              ),
                              FlatButton(
                                child: Text('Yes'),
                                onPressed: () {
                                  Navigator.of(ctx).pop();
                                  Navigator.of(ctx).pop();
                                },
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                if (!proposingContract)
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
                        size: 18,
                      ),
                      label: Text(
                        "Confirm & Propose",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      onPressed: () {
                        signContract();
                      },
                    ),
                  ),
                if (proposingContract) ProgressIndicatorWidget(show: true)
              ],
            )
          ],
        ),
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
      trips.add(Trip.fromJson(data["results"][i]));
    }
    fetch();
  });
}

void loadOrders(List<Order> orders, int id, Function fetch) async {
  final url = Api.orderById + id.toString() + "/orders/?origin=" + _trip.source.id.toString() + "&dest=" + _trip.destination.id.toString();
  http.get(
    url,
    headers: {
      HttpHeaders.contentTypeHeader: "application/json",
    },
  ).then((onValue) {
    Map<String, dynamic> data = json.decode(onValue.body) as Map<String, dynamic>;

    for (var i = 0; i < data["results"].length; i++) {
      orders.add(Order.fromJson(data["results"][i]));
    }
    fetch();
  });
}
