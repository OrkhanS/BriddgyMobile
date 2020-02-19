import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import './screens/splash_screen.dart';
import './screens/cart_screen.dart';
import './screens/products_overview_screen.dart';
import './screens/product_detail_screen.dart';
import './providers/products.dart';
import './providers/cart.dart';
import './providers/orders.dart';
import './providers/auth.dart';
import './screens/orders_screen.dart';
import './screens/user_products_screen.dart';
import './screens/edit_product_screen.dart';
import './screens/auth_screen.dart';

import './screens/profile_screen.dart';
import './screens/add_screen.dart';
import './screens/notification_screen.dart';
import './screens/chats_screen.dart';
import './screens/chat_window.dart';

import 'package:flutter_facebook_login/flutter_facebook_login.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _currentIndex = 1;

  PageController _pageController;

  @override
  void initState() {
    _currentIndex = 1;
    super.initState();
    _pageController = PageController(initialPage: 1);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, Products>(
          builder: (ctx, auth, previousProducts) => Products(
            auth.token,
            auth.userId,
            previousProducts == null ? [] : previousProducts.items,
          ),
        ),
        ChangeNotifierProvider.value(
          value: Cart(),
        ),
        ChangeNotifierProxyProvider<Auth, Orders>(
          builder: (ctx, auth, previousOrders) => Orders(
            auth.token,
            auth.userId,
            previousOrders == null ? [] : previousOrders.orders,
          ),
        ),
      ],
      child: Consumer<Auth>(builder: (ctx, auth, _) {
        return MaterialApp(
          title: 'Optisend',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            accentColor: Colors.pinkAccent,
            fontFamily: 'Lato',
          ),
          home: Scaffold(
            //appBar: AppBar(title: Text("Nav Bar")),
            body: SizedBox.expand(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                },
                children: <Widget>[
                  AddScreen(),
                  OrdersScreen(),
                  ChatsScreen(),
                  NotificationScreen(),
                  ProfileScreen(),
                ],
              ),
            ),
            bottomNavigationBar: BottomNavigationBar(
              elevation: 4,
              type: BottomNavigationBarType.fixed,

              //mainAxisAlignment: MainAxisAlignment.spaceBetween,
//              backgroundColor: Colors.black,
              currentIndex: _currentIndex,
              selectedItemColor: Theme.of(context).primaryColor,

              unselectedItemColor: Colors.grey[500],

              //selectedIndex: _currentIndex,
              unselectedFontSize: 9,
              selectedFontSize: 11,

              onTap: (index) {
                setState(() => _currentIndex = index);
                _pageController.animateToPage(index,
                    duration: Duration(milliseconds: 200), curve: Curves.ease);
              },
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  title: Text('Add'),
//                    textAlign: TextAlign.center,
//                    inactiveColor: Colors.black45,
                  icon: Icon(Icons.add),
                ),
                BottomNavigationBarItem(
                  title: Text('Search'),
//                  textAlign: TextAlign.end,
//                  inactiveColor: Colors.black45,
                  icon: Icon(
                    Icons.search,
                  ),
//                  activeIcon: Icon(Icons),
                ),
                BottomNavigationBarItem(
                  title: Text('Chats'),
//                  textAlign: TextAlign.center,
//                  inactiveColor: Colors.black45,
                  icon: Icon(Icons.chat_bubble_outline),
                  activeIcon: Icon(Icons.chat_bubble),
                ),
                BottomNavigationBarItem(
                  title: Text('Notifications'),
//                  textAlign: TextAlign.center,
//                  inactiveColor: Colors.black45,
                  icon: Icon(Icons.notifications_none),
                  activeIcon: Icon(Icons.notifications),
                ),
                BottomNavigationBarItem(
                  title: Text('Profile'),
//                  textAlign: TextAlign.center,
//                  inactiveColor: Colors.black45,
                  //activeColor: Theme.of(context).accentColor,
                  icon: Icon(Icons.person_outline),
                  activeIcon: Icon(Icons.person),
                ),
              ],
            ),
//            BottomNavyBar(
//              mainAxisAlignment: MainAxisAlignment.spaceBetween,
//              backgroundColor: Colors.grey[200],
//              selectedIndex: _currentIndex,
//              showElevation: true,
//              onItemSelected: (index) {
//                setState(() => _currentIndex = index);
//                _pageController.animateToPage(index,
//                    duration: Duration(milliseconds: 200), curve: Curves.ease);
//              },
//              items: <BottomNavyBarItem>[
//                BottomNavyBarItem(
//                    title: Text(''),
//                    textAlign: TextAlign.center,
//                    inactiveColor: Colors.black45,
//                    icon: Icon(Icons.add)),
//                BottomNavyBarItem(
//                  title: Text(''),
//                  textAlign: TextAlign.end,
//                  inactiveColor: Colors.black45,
//                  icon: Icon(Icons.search),
//                ),
//                BottomNavyBarItem(
//                  title: Text(''),
//                  textAlign: TextAlign.center,
//                  inactiveColor: Colors.black45,
//                  icon: Icon(Icons.chat_bubble_outline),
//                ),
//                BottomNavyBarItem(
//                  title: Text(''),
//                  textAlign: TextAlign.center,
//                  inactiveColor: Colors.black45,
//                  icon: Icon(Icons.notifications_none),
//                ),
//                BottomNavyBarItem(
//                  title: Text(''),
//                  textAlign: TextAlign.center,
//                  inactiveColor: Colors.black45,
//                  //activeColor: Theme.of(context).accentColor,
//                  icon: Icon(Icons.person_outline),
//                ),
//              ],
//            ),
          ),
          routes: {
            ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
            CartScreen.routeName: (ctx) => CartScreen(),
            OrdersScreen.routeName: (ctx) => OrdersScreen(),
            UserProductsScreen.routeName: (ctx) => UserProductsScreen(),
            EditProductScreen.routeName: (ctx) => EditProductScreen(),
            ChatWindow.routeName: (ctx) => ChatWindow(),
          },
        );
      }),
    );
  }
}
