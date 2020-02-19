import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:optisend/screens/splash_screen.dart';
import 'package:provider/provider.dart';

import '../providers/orders.dart' show Orders;
import '../widgets/order_item.dart';
import '../widgets/app_drawer.dart';
import '../widgets/bottom_navbar.dart';
import 'profile_screen.dart';
import 'add_screen.dart';
import 'notification_screen.dart';
import 'chats_screen.dart';

//class OrdersScreen extends StatelessWidget {
//  static const routeName = '/orders';
//  var _selectedIndex = 1;
//  @override
//  Widget build(BuildContext context) {
//    print('building orders');
//    // final orderData = Provider.of<Orders>(context);
//    return Scaffold(
//        appBar: AppBar(
//          title: Text('Your Orders'),
//        ),
//        drawer: AppDrawer(),
//        bottomNavigationBar: BottomNavyBar(
//          selectedIndex: _selectedIndex,
//          showElevation: true, // use this to remove appBar's elevation
//          onItemSelected: (index) => setState(() {
//            _selectedIndex = index;
//            _pageController.animateToPage(index,
//                duration: Duration(milliseconds: 300), curve: Curves.ease);
//          }),
//          items: [
//            BottomNavyBarItem(
//              icon: Icon(Icons.apps),
//              title: Text('Home'),
//              activeColor: Colors.red,
//            ),
//            BottomNavyBarItem(
//                icon: Icon(Icons.people),
//                title: Text('Users'),
//                activeColor: Colors.purpleAccent),
//            BottomNavyBarItem(
//                icon: Icon(Icons.message),
//                title: Text('Messages'),
//                activeColor: Colors.pink),
//            BottomNavyBarItem(
//                icon: Icon(Icons.settings),
//                title: Text('Settings'),
//                activeColor: Colors.blue),
//          ],
//        ),
//        body: Center(child: Text("orders Screen"))
////      FutureBuilder(
////        future: Provider.of<Orders>(context, listen: false).fetchAndSetOrders(),
////        builder: (ctx, dataSnapshot) {
////          if (dataSnapshot.connectionState == ConnectionState.waiting) {
////            return Center(child: CircularProgressIndicator());
////          } else {
////            if (dataSnapshot.error != null) {
////              // ...
////              // Do error handling stuff
////              return Center(
////                child: Text('An error occurred!'),
////              );
////            } else {
////              return Consumer<Orders>(
////                builder: (ctx, orderData, child) => ListView.builder(
////                      itemCount: orderData.orders.length,
////                      itemBuilder: (ctx, i) => OrderItem(orderData.orders[i]),
////                    ),
////              );
////            }
////          }
////        },
////      ),
//        );
//  }
//}

class OrdersScreen extends StatefulWidget {
  static const routeName = '/orders';
  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
//  var deviceSize = MediaQuery.of(context).size;
  DateTime startDate = DateTime.now();

  Future<Null> _selectStartDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: startDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != startDate)
      setState(() {
        startDate = picked;
      });
  }

  Widget _orderItem() {
    return InkWell(
//        onTap: Navigator.push(
//          context,
//          MaterialPageRoute(builder: (context) => _orderWindow()),
//        );
      child: Container(
        height: 130,
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
                        Icon(
                          Icons.location_on,
                          color: Colors.blue[200],
                        ),
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

  bool expanded = true;
  @override
  Widget build(BuildContext context) {
    print('oorderscreen'); //todo:delete
    return Scaffold(
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
          Form(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15)),
                child: Container(
//                  color: Theme.of(context).primaryColor,
                  child: ExpansionTile(
                    onExpansionChanged: (val) {
                      val = !val;
                    },
                    //                    backgroundColor: Theme.of(context).backgroundColor,

//                    backgroundColor: Theme.of(context).primaryColor,
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
                          RaisedButton(
                            color: Colors.white,
                            child: Text("Start Date",
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                )),
                            onPressed: () => _selectStartDate(context),
                          ),
                          RaisedButton(
                            color: Colors.white,
                            child: Text("End Date",
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                )),
                            onPressed: () => _selectStartDate(context),
                          ),
//                          DateTimeField(),
                          RaisedButton(
                            color: Theme.of(context).primaryColor,

                            elevation: 8,
//                            color: Theme.of(context).primaryColor,
                            child: Text(
                              "       Search         ",
                              style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            onPressed: () {},
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 10),
                      ),
                    ],
                    initiallyExpanded: true,
                  ),
                ),
              ),
            ),
          ),
//          Padding(
//            padding: const EdgeInsets.all(8),
//            child: ClipRRect(
//              borderRadius: BorderRadius.only(
//                  topLeft: Radius.circular(15), topRight: Radius.circular(15)),
//              child: GestureDetector(
//                onTap: () {
////                  Navigator.of(context).push(MaterialPageRoute(builder: (context)=>{}));
//                },
//                child: Container(
//                  padding: EdgeInsets.all(8),
//                  height: 45,
//                  color: Theme.of(context).primaryColor,
//                  child: Row(
//                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                    children: <Widget>[
//                      Icon(
//                        Icons.arrow_drop_down,
//                        color: Colors.white,
//                      ),
//                      Text(
//                        "Configure Filtering",
//                        style: TextStyle(
//                            color: Colors.white,
//                            fontWeight: FontWeight.bold,
//                            fontSize: 20),
//                      ),
//                      Icon(
//                        Icons.arrow_drop_down,
//                        color: Colors.white,
//                      ),
//                    ],
//                  ),
//                ),
//              ),
//            ),
//          ),
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
