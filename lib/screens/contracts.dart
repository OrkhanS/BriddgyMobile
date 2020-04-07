import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:menu/menu.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
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
    const url = "http://briddgy.herokuapp.com/api/my/contracts/";
    http.get(
      url,
      headers: {
        HttpHeaders.CONTENT_TYPE: "application/json",
        "Authorization": "Token " + "40694c366ab5935e997a1002fddc152c9566de90",
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
          "My Contracts",
          style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
        ),
        elevation: 1,
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (!_isfetchingnew && scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
            // start loading data
            setState(() {
              _isfetchingnew = true;
              print("load order");
            });
            //_loadData(); todo: orxan
          }
        },
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                itemBuilder: (context, int i) {
                  return Menu(
                    child: Container(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.all(1),
                          // Todo
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
                                      //Order image
                                      padding: const EdgeInsets.all(10.0),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.all(Radius.circular(15)),
                                        child: Image(
                                          image: NetworkImage(
                                              // "https://briddgy.herokuapp.com/media/" + _user["avatarpic"].toString() +"/"
                                              "https://picsum.photos/250?image=9"), //Todo,
                                        ),
                                      ),
                                    ),
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
                                            "Traveler: " +
                                                _contracts[i]["trip"]["owner"]["first_name"] +
                                                " " +
                                                _contracts[i]["trip"]["owner"]["last_name"],
                                            style: TextStyle(fontSize: 15, color: Colors.grey[600], fontWeight: FontWeight.normal),
                                          ),
                                          Text(
                                            "Orderer: " +
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
                      MenuItem("Info", () {
                        Alert(
                          context: context,
                          title: "Contract Details  " + "\n",
                          buttons: [
                            DialogButton(
                              child: Text(
                                "Back",
                                style: TextStyle(color: Colors.white, fontSize: 20),
                              ),
                              onPressed: () => Navigator.pop(context),
                              color: Color.fromRGBO(0, 179, 134, 1.0),
                            ),
                            DialogButton(
                              child: Text(
                                "Report",
                                style: TextStyle(color: Colors.white, fontSize: 20),
                              ),
                              onPressed: () => {},
                              color: Color.fromRGBO(0, 179, 134, 1.0),
                            )
                          ],
                          content: Column(
                            children: <Widget>[
                              Text(
                                "Traveler: " +
                                    _contracts[i]["trip"]["owner"]["first_name"] +
                                    " " +
                                    _contracts[i]["trip"]["owner"]["last_name"] +
                                    "\n" +
                                    "Orderer: " +
                                    _contracts[i]["order"]["owner"]["first_name"] +
                                    " " +
                                    _contracts[i]["order"]["owner"]["last_name"] +
                                    "\n" +
                                    "Weight: " +
                                    _contracts[i]["order"]["weight"].toString() +
                                    "\n" +
                                    "Reward: " +
                                    _contracts[i]["order"]["price"].toString() +
                                    "\n" +
                                    "Arrival Date : " +
                                    _contracts[i]["trip"]["date"].toString(),
                                style: TextStyle(fontSize: 15, color: Colors.grey[600], fontWeight: FontWeight.normal),
                              ),
                            ],
                          ),
                        ).show();
                      }),
                      MenuItem("Remove", () {}),
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
    );
  }
}
