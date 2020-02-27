import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:optisend/screens/add_item_screen.dart';
import 'package:optisend/screens/trip_screen.dart';
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
import 'package:flutter/foundation.dart';

import './screens/account_screen.dart';
import './screens/notification_screen.dart';
import './screens/chats_screen.dart';
import './screens/chat_window.dart';
import 'package:optisend/screens/profile_screen.dart';
import 'package:optisend/screens/item_screen.dart';

import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:optisend/web_sockets.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
//import 'package:optisend/providers/messages.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _currentIndex = 1;

  PageController _pageController;
  IOWebSocketChannel _channel;
  final StreamController<String> streamController =
      StreamController<String>.broadcast();
  ObserverList<Function> _listeners = new ObserverList<Function>();
  bool _isOn = false;
  //List<dynamic> _messages = [];
  List<dynamic> _mesaj = [];
  List<dynamic> _rooms;
  Future<int> roomLength;
  @override
  void initState() {
    _currentIndex = 1;
    super.initState();
    _pageController = PageController(initialPage: 1);
    initCommunication();
    //fetchAndSetRooms();
  }

  /// ----------------------------------------------------------
  /// Fetch Rooms Of User
  /// ----------------------------------------------------------
  Future fetchAndSetRooms() async {
    var token = "40694c366ab5935e997a1002fddc152c9566de90";

    const url = "http://briddgy.herokuapp.com/api/chats/";
    final response = http.get(
      url,
      headers: {
        HttpHeaders.CONTENT_TYPE: "application/json",
        "Authorization": "Token " + token,
      },
    );

    response.then((onValue) {
      final dataOrders = json.decode(onValue.body) as Map<String, dynamic>;

      if (this.mounted) {
        setState(() {
          final dataOrders = json.decode(onValue.body) as Map<String, dynamic>;
          _rooms = dataOrders["results"];
        });
      }
      fetchMessageCaller(_rooms);
    });

    return _rooms;
  }

  /// ----------------------------------------------------------
  /// End Fetching Rooms Of User
  /// ----------------------------------------------------------

  fetchMessageCaller(_rooms) {
    for (var i = 0; i < _rooms.length; i++) {
      fetchAndSetMessages(_rooms, i);
    }
  }

  /// ----------------------------------------------------------
  /// Fetch Rooms Of User
  /// ----------------------------------------------------------
  Future fetchAndSetMessages(_rooms, int i) async {
    var token = "40694c366ab5935e997a1002fddc152c9566de90";
    String url = "http://briddgy.herokuapp.com/api/chat/messages/?room_id=" +
        _rooms[i]["id"].toString();
    final response = await http.get(
      url,
      headers: {
        HttpHeaders.CONTENT_TYPE: "application/json",
        "Authorization": "Token " + token,
      },
    );
    final dataOrders = json.decode(response.body) as Map<String, dynamic>;

    if (this.mounted) {
      setState(() {
        final dataOrders = json.decode(response.body) as Map<String, dynamic>;
        _mesaj = [];
        _mesaj.add(dataOrders["results"]);
      });
//      Provider.of<Messages>(context, listen: false).addMessages(_mesaj);
//    todo: remove comment
    }
    return "success";
  }

  /// ----------------------------------------------------------
  /// End Fetching Rooms Of User
  /// ----------------------------------------------------------

  /// ----------------------------------------------------------
  /// Creates the WebSocket communication
  /// ----------------------------------------------------------
  initCommunication() async {
    reset();
    try {
      _channel = new IOWebSocketChannel.connect(
          'ws://briddgy.herokuapp.com/ws/alert/?token=40694c366ab5935e997a1002fddc152c9566de90');
      _channel.stream.listen(_onReceptionOfMessageFromServer);
      print("Alert Connected");
    } catch (e) {
      print("Error Occured");
      reset();
    }
  }

  /// ----------------------------------------------------------
  /// Closes the WebSocket communication
  /// ----------------------------------------------------------
  reset() {
    if (_channel != null) {
      if (_channel.sink != null) {
        _channel.sink.close();
        _isOn = false;
      }
    }
  }

  /// ---------------------------------------------------------
  /// Adds a callback to be invoked in case of incoming
  /// notification
  /// ---------------------------------------------------------
  addListener(Function callback) {
    _listeners.add(callback);
  }

  removeListener(Function callback) {
    _listeners.remove(callback);
  }

  /// ----------------------------------------------------------
  /// Callback which is invoked each time that we are receiving
  /// a message from the server
  /// ----------------------------------------------------------
  _onReceptionOfMessageFromServer(message) {
    _mesaj = [];
    _mesaj.add(json.decode(message));
    // if(_mesaj[0]["id"]){
    // Check if "ID" of image sent before, then check its room ID, search in _room and get message ID and use
    // it in Message Provider, find message, then add the mesaj into that
    // }
    _isOn = true;
    _listeners.forEach((Function callback) {
      callback(message);
    });
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
          icon: Icon(MdiIcons.forumOutline),
          activeIcon: Icon(MdiIcons.forum),
        ),
        BottomNavigationBarItem(
          title: Text('Notifications'),
          icon: Icon(Icons.notifications_none),
          activeIcon: Icon(Icons.notifications),
        ),
        BottomNavigationBarItem(
          title: Text('Profile'),
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
        ChangeNotifierProvider.value(
          value: Auth(),
        ),
//        ChangeNotifierProvider.value(
//          value: Messages(),
//        ),
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
        fetchAndSetRooms();
        return MaterialApp(
          title: 'Optisend',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            primaryColor: Colors.blue[900],
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
                  TripsScreen(),
                  ChatsScreen(rooms: _rooms, alertChannel: streamController),
                  NotificationScreen(),
                  DetailsScreen(),
                ],
              ),
            ),
            bottomNavigationBar: navbar(),
          ),
          routes: {
            ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
            CartScreen.routeName: (ctx) => CartScreen(),
            OrdersScreen.routeName: (ctx) => OrdersScreen(),
            TripsScreen.routeName: (ctx) => TripsScreen(),
            UserProductsScreen.routeName: (ctx) => UserProductsScreen(),
            EditProductScreen.routeName: (ctx) => EditProductScreen(),
            ChatWindow.routeName: (ctx) => ChatWindow(),
            ItemScreen.routeName: (ctx) => ItemScreen(),
            AddItemScreen.routeName: (ctx) => AddItemScreen(),
            ProfileScreen.routeName: (ctx) => ProfileScreen(),
          },
        );
      }),
    );
  }
}
