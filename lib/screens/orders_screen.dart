import 'package:bottom_navy_bar/bottom_navy_bar.dart';
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

  Widget _searchBar() {
    final deviceSize = MediaQuery.of(context).size;
    return Container(
      width: deviceSize.width,
      margin: EdgeInsets.only(top: 3, left: 4, right: 4, bottom: 3),
      height: 90,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        //color: Colors.lightBlueAccent,
        boxShadow: [
          BoxShadow(
              color: Theme.of(context).primaryColor,
              blurRadius: 30,
              spreadRadius: 30)
        ],
      ),
      child: Container(
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.search,
                color: Colors.white,
                size: 30,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.all(5),
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                    ),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectStartDate(context), //Todo
                            child: Container(
                              color: Colors.grey[200],
//                              padding: EdgeInsets.all(5),
                              margin: EdgeInsets.symmetric(horizontal: 10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    "From",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.white,
                                    ),
                                    child: Icon(
                                      Icons.arrow_right,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectStartDate(context), //Todo
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    "To",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.grey[200],
                                    ),
                                    child: Icon(
                                      Icons.arrow_right,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(10),
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey[200],
                    ),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectStartDate(context), //Todo
                            child: Container(
                              color: Colors.white,
//                              padding: EdgeInsets.all(5),
                              margin: EdgeInsets.symmetric(horizontal: 10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    "From",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.grey[200],
                                    ),
                                    child: Icon(
                                      Icons.arrow_right,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectStartDate(context), //Todo
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    "To",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.grey[200],
                                    ),
                                    child: Icon(
                                      Icons.arrow_right,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
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
          _searchBar(),
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
