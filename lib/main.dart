import 'package:flutter/material.dart';
import 'package:optisend/screens/add_item_screen.dart';
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
import './screens/notification_screen.dart';
import './screens/chats_screen.dart';
import './screens/chat_window.dart';
import 'package:optisend/screens/item_screen.dart';

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

  Widget navbar() {
    return BottomNavigationBar(
      elevation: 4,
      type: BottomNavigationBarType.fixed,
      currentIndex: _currentIndex,
      selectedItemColor: Theme.of(context).primaryColor,
      unselectedItemColor: Colors.grey[500],
      unselectedFontSize: 9,
      selectedFontSize: 11,
      onTap: (index) {
        setState(() => _currentIndex = index);
        _pageController.animateToPage(index,
            duration: Duration(milliseconds: 200), curve: Curves.ease);
      },
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          title: Text('Orders'),
          icon: Icon(
            Icons.markunread_mailbox, //todo: normal icon
          ),
        ),
        BottomNavigationBarItem(
          title: Text('Trips'),
          icon: Icon(
            Icons.flight,
          ),
        ),
        BottomNavigationBarItem(
          title: Text('Profile'),
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
        ),
        BottomNavigationBarItem(
          title: Text('Chats'),
          icon: Icon(Icons.chat_bubble_outline),
          activeIcon: Icon(Icons.chat_bubble),
        ),
        BottomNavigationBarItem(
          title: Text('Notifications'),
          icon: Icon(Icons.notifications_none),
          activeIcon: Icon(Icons.notifications),
        ),
      ],
    );
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
                  OrdersScreen(),
                  OrdersScreen(),
                  ProfileScreen(),
                  ChatsScreen(),
                  NotificationScreen(),
                ],
              ),
            ),
            bottomNavigationBar: navbar(),
//
          ),
          routes: {
            ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
            CartScreen.routeName: (ctx) => CartScreen(),
            OrdersScreen.routeName: (ctx) => OrdersScreen(),
            UserProductsScreen.routeName: (ctx) => UserProductsScreen(),
            EditProductScreen.routeName: (ctx) => EditProductScreen(),
            ChatWindow.routeName: (ctx) => ChatWindow(),
            ItemScreen.routeName: (ctx) => ItemScreen(),
            AddItemScreen.routeName: (ctx) => AddItemScreen(),
          },
        );
      }),
    );
  }
}
