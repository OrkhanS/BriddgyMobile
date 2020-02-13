import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:flutter/material.dart';
import 'package:optisend/screens/splash_screen.dart';
import 'profile_screen.dart';
import 'package:provider/provider.dart';

import '../providers/orders.dart' show Orders;
import '../widgets/order_item.dart';
import '../widgets/app_drawer.dart';
import '../widgets/bottom_navbar.dart';

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
  int _currentIndex = 0;
  PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(title: Text("Nav Bar")),
      body: SizedBox.expand(
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() => _currentIndex = index);
          },
          children: <Widget>[
            Container(
              color: Colors.yellow,
            ),
            Container(
              color: Colors.lightBlueAccent,
            ),
            Container(
              color: Colors.green,
            ),
            Container(
              color: Colors.white,
            ),
            ProfileScreen(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavyBar(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        backgroundColor: Colors.grey[200],
        selectedIndex: _currentIndex,
        showElevation: true,
        onItemSelected: (index) {
          setState(() => _currentIndex = index);
          _pageController.animateToPage(index,
              duration: Duration(milliseconds: 300), curve: Curves.ease);
        },
        items: <BottomNavyBarItem>[
          BottomNavyBarItem(
              title: Text('Add'),
              textAlign: TextAlign.center,
              inactiveColor: Colors.black45,
              icon: Icon(Icons.add)),
          BottomNavyBarItem(
            title: Text('Search'),
            textAlign: TextAlign.center,
            inactiveColor: Colors.black45,
            icon: Icon(Icons.search),
          ),
          BottomNavyBarItem(
            title: Text('Messages'),
            textAlign: TextAlign.center,
            inactiveColor: Colors.black45,
            icon: Icon(Icons.chat_bubble_outline),
          ),
          BottomNavyBarItem(
            title: Text('Notifications'),
            textAlign: TextAlign.center,
            inactiveColor: Colors.black45,
            icon: Icon(Icons.notifications_none),
          ),
          BottomNavyBarItem(
            title: Text('Profile'),
            textAlign: TextAlign.center,
            inactiveColor: Colors.black45,
            icon: Icon(Icons.person_outline),
          ),
        ],
      ),
    );
  }
}
