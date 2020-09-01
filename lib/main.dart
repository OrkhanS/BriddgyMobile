import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:optisend/localization/demo_localization.dart';
import 'package:optisend/screens/add_order_screen.dart';
import 'package:optisend/screens/add_trip_screen.dart';
import 'package:optisend/screens/auth_screen.dart';
import 'package:optisend/screens/my_trips.dart';
import 'package:optisend/screens/trips_screen.dart';
import 'package:provider/provider.dart';
import './providers/auth.dart';
import './screens/orders_screen.dart';
import 'package:flutter/foundation.dart';
import './screens/account_screen.dart';
import './screens/notification_screen.dart';
import './screens/chats_screen.dart';
import './screens/chat_window.dart';
import 'package:optisend/screens/profile_screen.dart';
import 'package:optisend/screens/order_screen.dart';
//import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:web_socket_channel/io.dart';
import 'package:optisend/providers/messages.dart';
import 'package:optisend/providers/ordersandtrips.dart';
import 'package:optisend/screens/my_orders.dart';
import 'package:optisend/screens/contracts.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:badges/badges.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'models/api.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  final StreamController<String> streamController = StreamController<String>.broadcast();
  IOWebSocketChannel _channel;
  ObserverList<Function> _listeners = new ObserverList<Function>();
  var button = ChatsScreen();
  static void setLocale(BuildContext context, Locale locale) {
    _MyAppState state = context.findAncestorStateOfType<_MyAppState>();
    state.setLocale(locale);
  }

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final notifications = FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  bool _isOn = false;
  int _currentIndex = 0;
  PageController _pageController;
  String tokenforROOM;
  Map valueMessages = {};
  bool socketConnected = false;
  bool socketConnectedFirebase = false;
  var neWMessage, newMessageauth;

  Locale _locale;

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  void initState() {
    _currentIndex = 0;
    super.initState();
    getToken();
    _pageController = PageController(initialPage: 0);
  }

  _configureFirebaseListerners() {
    socketConnectedFirebase = true;
    print("ConnectedFirebase");
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        neWMessage.addMessages(message.values.last, newMessageauth);
      },
      onLaunch: (Map<String, dynamic> message) async {
        neWMessage.addMessages(message.values.last, newMessageauth);
      },
      onResume: (Map<String, dynamic> message) async {
        neWMessage.addMessages(message.values.last, newMessageauth);
      },
    );
  }

  Future getToken() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractedUserData = json.decode(prefs.getString('userData')) as Map<String, Object>;
    tokenforROOM = extractedUserData['token'];
  }

  Future onSelectNotification(String payload) async => await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ChatsScreen()),
      );

  initCommunication(auth, newmessage) async {
    if (socketConnected == false) {
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
        final extractedUserData = json.decode(prefs.getString('userData')) as Map<String, Object>;

        auth.token = extractedUserData['token'];

        if (extractedUserData['token'] != null) {
          widget._channel = new IOWebSocketChannel.connect(Api.alertSocket + extractedUserData['token']);
          widget._channel.stream.listen(_onReceptionOfMessageFromServer);
          print("Alert Connected");
          socketConnected = true;
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
      selectedItemColor: Colors.teal[700],
      unselectedItemColor: Colors.grey[500],
      unselectedFontSize: 9,
      selectedFontSize: 11,
      onTap: (index) {
        setState(() => _currentIndex = index);
        _pageController.animateToPage(index, duration: Duration(milliseconds: 200), curve: Curves.ease);
      },
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(title: Text('Orders'), icon: Icon(MdiIcons.packageVariantClosed), activeIcon: Icon(MdiIcons.packageVariant)),
        BottomNavigationBarItem(
          title: Text('Trips'),
          icon: Icon(MdiIcons.roadVariant),
          activeIcon: Icon(MdiIcons.road),
        ),
        BottomNavigationBarItem(
          title: Text('Chats'),
          icon: newmessage.arethereNewMessage == true
              ? Badge(
                  badgeContent: Text(newmessage.newMessages.length.toString()),
                  child: Icon(MdiIcons.forumOutline),
                )
              : Icon(MdiIcons.forumOutline),
          activeIcon: Icon(MdiIcons.forum),
        ),
//        BottomNavigationBarItem(
//          title: Text('Notifications'),
//          icon: Icon(Icons.notifications_none),
//          activeIcon: Icon(Icons.notifications),
//        ),
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
          create: (_) => Auth(),
        ),
        ChangeNotifierProvider(
          create: (_) => OrdersTripsProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => Messages(),
        ),
      ],
      child: Consumer3<Auth, Messages, OrdersTripsProvider>(builder: (
        ctx,
        auth,
        message,
        orderstripsProvider,
        _,
      ) {
        neWMessage = message;
        newMessageauth = auth;
        if (auth.isAuth == false) {
          auth.tryAutoLogin();
        }
        if (message.isChatsLoadingForMain && auth.isAuth) message.fetchAndSetRooms(auth, false);
        if (!socketConnectedFirebase) _configureFirebaseListerners();
        if (auth.isLoadingUserForMain && auth.token != null)
          auth.fetchAndSetUserDetails().whenComplete(() {
            if (auth.user == null) {
              auth.isLoadingUserForMain = true;
              auth.isLoadingUserDetails = true;
            }
          });
        if (auth.reviewsNotReady && auth.isNotLoadingUserDetails == false) auth.fetchAndSetReviews();
        if (auth.statsNotReady && auth.isNotLoadingUserDetails == false) auth.fetchAndSetStatistics();
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          statusBarColor: Colors.white10,
          statusBarIconBrightness: Brightness.dark,
        ));
        return MaterialApp(
          locale: _locale,
          localizationsDelegates: [
            DemoLocalization.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [
            const Locale('en', 'US'), // English, no country code
            const Locale('ru', 'RU'), // Russian, no country code
          ],
          localeResolutionCallback: (deviceLocale, supportedLocales) {
            for (var locale in supportedLocales) {
              if (locale.languageCode == deviceLocale.languageCode && locale.countryCode == deviceLocale.countryCode) {
                return deviceLocale;
              }
            }

            return supportedLocales.first;
          },
          title: 'Optisend',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            backgroundColor: Colors.white,
            primarySwatch: Colors.blue,
            primaryColor: Colors.teal[700],
            accentColor: Colors.green,
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
                  OrdersScreen(orderstripsProvider: orderstripsProvider, room: message, auth: auth, token: tokenforROOM),
                  TripsScreen(orderstripsProvider: orderstripsProvider, room: message, auth: auth, token: tokenforROOM),
                  ChatsScreen(provider: message, auth: auth),
//                  NotificationScreen(),
                  auth.isAuth ? AccountScreen(token: tokenforROOM, auth: auth, orderstripsProvider: orderstripsProvider) : AuthScreen(),
                ],
              ),
            ),
            bottomNavigationBar: navbar(message),
          ),
          routes: {
            OrdersScreen.routeName: (ctx) => OrdersScreen(),
            TripsScreen.routeName: (ctx) => TripsScreen(),
            ChatWindow.routeName: (ctx) => ChatWindow(),
            AddItemScreen.routeName: (ctx) => AddItemScreen(),
            AddTripScreen.routeName: (ctx) => AddTripScreen(),
            MyItems.routeName: (ctx) => MyItems(),
            MyTrips.routeName: (ctx) => MyTrips(),
            Contracts.routeName: (ctx) => Contracts(),
            AccountScreen.routeName: (ctx) => AccountScreen(token: tokenforROOM, orderstripsProvider: orderstripsProvider),
          },
        );
      }),
    );
  }
}
