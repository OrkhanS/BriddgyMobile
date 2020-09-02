import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:menu/menu.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:optisend/localization/localization_constants.dart';
import 'package:optisend/models/api.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class Contracts extends StatefulWidget {
  var token;
  Contracts({this.token});
  static const routeName = '/account/contracts';

  @override
  _ContractsState createState() => _ContractsState();
}

class _ContractsState extends State<Contracts> {
  List _contracts = [];
  bool isLoading = true;
  bool _isfetchingnew = false;

  @override
  void initState() {
    fetchAndSetContracts();
    super.initState();
  }

  Future fetchAndSetContracts() async {
    const url = Api.contracts;
    http.get(
      url,
      headers: {
        HttpHeaders.contentTypeHeader: "application/json",
        "Authorization": "Token " + widget.token,
      },
    ).then((response) {
      setState(
        () {
          final dataContracts = json.decode(response.body) as Map<String, dynamic>;
          _contracts = dataContracts["results"];
          isLoading = false;
        },
      );
    });
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            if (!_isfetchingnew && scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
              // start loading data
              setState(() {
                _isfetchingnew = true;
                print("load order");
              });
              //_loadData();
            }
          },
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: AppBar(
                  backgroundColor: Colors.white,
                  centerTitle: true,
                  leading: IconButton(
                    color: Theme.of(context).primaryColor,
                    icon: Icon(Icons.chevron_left),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  title: Text(
                    t(context, 'my_contracts'),
                    style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                  ),
                  elevation: 1,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemBuilder: (context, int i) {
                    return Menu(
                      child: Container(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.all(1),
                            // Warning
                            // Warning
                            child: InkWell(
                              onTap: () {},
                              child: Container(
                                height: 140,
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Card(
                                  elevation: 4,
                                  child: Row(
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              _contracts[i]["trip"]["source"]["city_ascii"] +
                                                  "  >  " +
                                                  _contracts[i]["trip"]["destination"]["city_ascii"],
                                              style: TextStyle(fontSize: 22, color: Colors.grey[600], fontWeight: FontWeight.normal),
                                            ),
                                            Text(
                                              "${t(context, 'traveler')}: " +
                                                  _contracts[i]["trip"]["owner"]["first_name"] +
                                                  " " +
                                                  _contracts[i]["trip"]["owner"]["last_name"],
                                              style: TextStyle(fontSize: 15, color: Colors.grey[600], fontWeight: FontWeight.normal),
                                            ),
                                            Text(
                                              "${t(context, 'orderer')}: " +
                                                  _contracts[i]["order"]["owner"]["first_name"] +
                                                  " " +
                                                  _contracts[i]["order"]["owner"]["last_name"],
                                              style: TextStyle(fontSize: 15, color: Colors.grey[600], fontWeight: FontWeight.normal),
                                            ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                                              children: <Widget>[
                                                Row(
                                                  children: <Widget>[
                                                    Icon(
                                                      MdiIcons.calendarRange,
                                                      color: Theme.of(context).primaryColor,
                                                    ),
                                                    Text(
                                                      _contracts[i]["dateSigned"].toString(),
                                                      style: TextStyle(color: Colors.grey[600]),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  width: 50,
                                                ),
                                                Row(
                                                  children: <Widget>[
                                                    Icon(
                                                      Icons.attach_money,
                                                      color: Theme.of(context).primaryColor,
                                                    ),
                                                    Text(
                                                      _contracts[i]["order"]["price"].toString(),
                                                      style: TextStyle(color: Colors.grey[600]),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      items: [
                        MenuItem(t(context, 'info'), () {
                          Alert(
                            context: context,
                            title: "${t(context, 'contract_details')} " + "\n",
                            buttons: [
                              DialogButton(
                                child: Text(
                                  t(context, 'back'),
                                  style: TextStyle(color: Colors.white, fontSize: 20),
                                ),
                                onPressed: () => Navigator.pop(context),
                                color: Color.fromRGBO(0, 179, 134, 1.0),
                              ),
                              DialogButton(
                                child: Text(
                                  t(context, 'report'),
                                  style: TextStyle(color: Colors.white, fontSize: 20),
                                ),
                                onPressed: () => {},
                                color: Color.fromRGBO(0, 179, 134, 1.0),
                              )
                            ],
                            content: Column(
                              children: <Widget>[
                                Text(
                                  "${t(context, 'traveler')}: " +
                                      _contracts[i]["trip"]["owner"]["first_name"] +
                                      " " +
                                      _contracts[i]["trip"]["owner"]["last_name"] +
                                      "\n" +
                                      "${t(context, 'orderer')}: " +
                                      _contracts[i]["order"]["owner"]["first_name"] +
                                      " " +
                                      _contracts[i]["order"]["owner"]["last_name"] +
                                      "\n" +
                                      "${t(context, 'weight')}: " +
                                      _contracts[i]["order"]["weight"].toString() +
                                      "\n" +
                                      "${t(context, 'reward')}: " +
                                      _contracts[i]["order"]["price"].toString() +
                                      "\n" +
                                      "${t(context, 'arrival_date')} : " +
                                      _contracts[i]["trip"]["date"].toString(),
                                  style: TextStyle(fontSize: 15, color: Colors.grey[600], fontWeight: FontWeight.normal),
                                ),
                              ],
                            ),
                          ).show();
                        }),
                        MenuItem(t(context, 'remove'), () {}),
                      ],
                      decoration: MenuDecoration(),
                    );
                  },
                  itemCount: _contracts == null ? 0 : _contracts.length,
                ),
              ),
              Container(
                height: _isfetchingnew ? 100.0 : 0.0,
                color: Colors.transparent,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
