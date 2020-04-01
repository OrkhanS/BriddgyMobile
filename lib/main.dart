import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:optisend/screens/add_item_screen.dart';
import 'package:optisend/screens/add_trip_screen.dart';
import 'package:optisend/screens/my_trips.dart';
import 'package:optisend/screens/trip_screen.dart';
import 'package:provider/provider.dart';

import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import './screens/splash_screen.dart';
import './screens/products_overview_screen.dart';
import './screens/product_detail_screen.dart';
import './providers/products.dart';
import './providers/cart.dart';
import './providers/auth.dart';
import './screens/orders_screen.dart';
import './screens/user_products_screen.dart';
import './screens/edit_product_screen.dart';
import './screens/auth_screen.dart';
import 'package:flutter/foundation.dart';

import './screens/account_screen.dart';
import './screens/notification_screen.dart';
import './screens/chats_screen.dart';
import './screens/chat_window.dart';
import 'package:optisend/screens/profile_screen.dart';
import 'package:optisend/screens/item_screen.dart';

//import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:optisend/web_sockets.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:optisend/providers/messages.dart';
import 'package:optisend/providers/userDetails.dart';
import 'package:optisend/providers/ordersandtrips.dart';

import 'package:optisend/screens/my_items.dart';
import 'package:optisend/screens/contracts.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:optisend/local_notications_helper.dart';
import 'package:badges/badges.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  final StreamController<String> streamController =
      StreamController<String>.broadcast();
  IOWebSocketChannel _channel;
  ObserverList<Function> _listeners = new ObserverList<Function>();
  var button = ChatsScreen();
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final notifications = FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  List<dynamic> _rooms;
  bool _isOn = false;
  bool _loggedIn = true;
  List<dynamic> _messages = [];
  List<dynamic> _mesaj = [];
  int _currentIndex = 1;
  PageController _pageController;
  bool _enabled = true;
  int _status = 0;
  IOWebSocketChannel _channelRoom;
  String tokenforROOM;
  List<DateTime> _events = [];
  Map valueMessages = {};
  bool socketConnected = false;
  var neWMessage;

  @override
  void initState() {
    _currentIndex = 1;
    super.initState();
    getToken();
    _pageController = PageController(initialPage: 1);
    //_configureFirebaseListerners();
    // final settingsAndroid = AndroidInitializationSettings('app_icon');
    // final settingsIOS = IOSInitializationSettings(
    //     onDidReceiveLocalNotification: (id, title, body, payload) =>
    //         onSelectNotification(payload));

    // notifications.initialize(
    //     InitializationSettings(settingsAndroid, settingsIOS),
    //     onSelectNotification: onSelectNotification,
    //     );
  }

  _configureFirebaseListerners(newmessage) {
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        neWMessage.addMessages = message;
      },
      onLaunch: (Map<String, dynamic> message) async {
        neWMessage.addMessages = message;
      },
      onResume: (Map<String, dynamic> message) async {
        neWMessage.addMessages = message;
      },
    );
  }

  Future getToken() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractedUserData =
        json.decode(prefs.getString('userData')) as Map<String, Object>;
    tokenforROOM = extractedUserData['token'];
  }

  Future onSelectNotification(String payload) async => await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ChatsScreen()),
      );

  initCommunication(auth, newmessage) async {
    if (socketConnected == false) {
      socketConnected = true;
      reset();
      try {
        var f, d;
        auth.removeListener(f);
        newmessage.removeListener(d);
        neWMessage = newmessage;
        final prefs = await SharedPreferences.getInstance();
        if (!prefs.containsKey('userData')) {
          return false;
        }
        final extractedUserData =
            json.decode(prefs.getString('userData')) as Map<String, Object>;

        auth.token = extractedUserData['token'];

        if (extractedUserData['token'] != null) {
          widget._channel = new IOWebSocketChannel.connect(
              'ws://briddgy.herokuapp.com/ws/alert/?token=' +
                  extractedUserData['token']); //todo
          widget._channel.stream.listen(_onReceptionOfMessageFromServer);
          print("Alert Connected");
        }
      } catch (e) {
        print("Error Occured");
        reset();
      }
    } else {
      return;
    }
  }

  /// ----------------------------------------------------------
  /// Closes the WebSocket communication
  /// ----------------------------------------------------------
  reset() {
    if (widget._channel != null) {
      if (widget._channel.sink != null) {
        widget._channel.sink.close();
        _isOn = false;
      }
    }
  }

  /// ---------------------------------------------------------
  /// Adds a callback to be invoked in case of incoming
  /// notification
  /// ---------------------------------------------------------
  addListener(Function callback) {
    widget._listeners.add(callback);
  }

  removeListener(Function callback) {
    widget._listeners.remove(callback);
  }

  /// ----------------------------------------------------------
  /// Callback which is invoked each time that we are receiving
  /// a message from the server
  /// ----------------------------------------------------------
  _onReceptionOfMessageFromServer(message) {
    valueMessages = json.decode(message);
    neWMessage.addMessages = valueMessages;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget navbar(newmessage) {
    return BottomNavigationBar(
      elevation: 4,
      type: BottomNavigationBarType.fixed,
      currentIndex: _currentIndex,
      selectedItemColor: Colors.blue[900],
      unselectedItemColor: Colors.grey[400],
      unselectedFontSize: 9,
      selectedFontSize: 11,
      onTap: (index) {
        setState(() => _currentIndex = index);
        _pageController.animateToPage(index,
            duration: Duration(milliseconds: 200), curve: Curves.ease);
      },
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
            title: Text('Items'),
            icon: Icon(MdiIcons.packageVariantClosed),
            activeIcon: Icon(MdiIcons.packageVariant)),
        BottomNavigationBarItem(
          title: Text('Trips'),
          icon: Icon(MdiIcons.roadVariant),
          activeIcon: Icon(MdiIcons.road),
        ),
        BottomNavigationBarItem(
          title: Text('Chats'),
          icon: newmessage.arethereNewMessage == true
              ? 
                Badge(
                      child: Icon(MdiIcons.forumOutline),
                    )
              : Icon(MdiIcons.forumOutline),
          activeIcon: Icon(MdiIcons.forum),
        ),
        BottomNavigationBarItem(
          title: Text('Notifications'),
          icon: Icon(Icons.notifications_none),
          activeIcon: Icon(Icons.notifications),
        ),
        BottomNavigationBarItem(
          title: Text('Account'),
          icon: Icon(MdiIcons.accountSettingsOutline),
          activeIcon: Icon(MdiIcons.accountSettings),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          builder: (_) => Auth(),
        ),

        ChangeNotifierProvider(
          builder: (_) => OrdersTripsProvider(),
        ),

        ChangeNotifierProvider(
          builder: (_) => Messages(),
        ),

        // ChangeNotifierProvider(
        //   builder: (_) => UserDetails(),
        // ),

//         ChangeNotifierProxyProvider<Auth, Products>(
//           builder: (ctx, auth, previousProducts) => Products(
//             auth.token,
//             auth.userId,
//             previousProducts == null ? [] : previousProducts.items,
//           ),
//         ),
//         ChangeNotifierProvider.value(
//           value: Cart(),
//         ),
//        ChangeNotifierProxyProvider<Auth, Orders>(
//          builder: (ctx, auth, previousOrders) => Orders(
//            auth.token,
//            auth.userId,
//            previousOrders == null ? [] : previousOrders.orders,
//          ),
//        ),
      ],
      child: Consumer3<Auth, Messages, OrdersTripsProvider>(builder: (
        ctx,
        auth,
        newmessage,
        orderstripsProvider,
        _,
      ) {
        newmessage.fetchAndSetRooms(auth);
        initCommunication(auth, newmessage);
        _configureFirebaseListerners(newmessage);
        return MaterialApp(
          title: 'Optisend',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            primaryColor: Colors.blue[900],
            accentColor: Colors.indigoAccent,
            fontFamily: 'Lato',
          ),
          home: Scaffold(
            body: SizedBox.expand(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                },
                children: <Widget>[
                  OrdersScreen(
                      orderstripsProvider: orderstripsProvider,
                      room: newmessage,
                      auth: auth,
                      token: tokenforROOM),
                  TripsScreen(
                      orderstripsProvider: orderstripsProvider,
                      room: newmessage,
                      auth: auth,
                      token: tokenforROOM),
                  ChatsScreen(
                      provider: newmessage,
                      auth: auth,
                      token: tokenforROOM),
                  NotificationScreen(),
                  AccountScreen(
                      token: tokenforROOM,
                      auth: auth,
                      orderstripsProvider: orderstripsProvider),
                ],
              ),
            ),
            bottomNavigationBar: navbar(newmessage),
          ),
          routes: {
            ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
            OrdersScreen.routeName: (ctx) => OrdersScreen(),
            TripsScreen.routeName: (ctx) => TripsScreen(),
            UserProductsScreen.routeName: (ctx) => UserProductsScreen(),
            EditProductScreen.routeName: (ctx) => EditProductScreen(),
            ChatWindow.routeName: (ctx) => ChatWindow(),
            ItemScreen.routeName: (ctx) => ItemScreen(),
            AddItemScreen.routeName: (ctx) => AddItemScreen(),
            AddTripScreen.routeName: (ctx) => AddTripScreen(),
            ProfileScreen.routeName: (ctx) => ProfileScreen(),
            MyItems.routeName: (ctx) => MyItems(),
            MyTrips.routeName: (ctx) => MyTrips(),
            Contracts.routeName: (ctx) => Contracts(),
            AccountScreen.routeName: (ctx) => AccountScreen(
                token: tokenforROOM, orderstripsProvider: orderstripsProvider),
          },
        );
      }),
    );
  }
}
