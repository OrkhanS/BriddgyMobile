import 'package:flutter/material.dart';
import 'package:optisend/providers/pagectrl.dart';
import 'package:provider/provider.dart';
import './auth_screen.dart';
import '../providers/auth.dart';
import 'splash_screen.dart';

import 'dart:math' as math;

import 'package:flutter/material.dart';

class Order {
  final String name;
  final String category;
  final String time;
  final Color color;
  final bool completed;

  Order({this.name, this.category, this.time, this.color, this.completed});
}

class ListModel {
  ListModel(this.listKey, items) : this.items = List.of(items);

  final GlobalKey<AnimatedListState> listKey;
  final List<Order> items;

  AnimatedListState get _animatedList => listKey.currentState;

  void insert(int index, Order item) {
    items.insert(index, item);
    _animatedList.insertItem(index, duration: Duration(milliseconds: 150));
  }

  Order removeAt(int index) {
    final Order removedItem = items.removeAt(index);
    if (removedItem != null) {
      _animatedList.removeItem(
          index,
          (context, animation) => OrderRow(
                task: removedItem,
                animation: animation,
              ),
          duration:
              Duration(milliseconds: (150 + 200 * (index / length)).toInt()));
    }
    return removedItem;
  }

  int get length => items.length;

  Order operator [](int index) => items[index];

  int indexOf(Order item) => items.indexOf(item);
}

List<Order> tasks = [
  Order(
      name: "Order 1",
      category: "2kg",
      time: "15 Feb 2020",
      color: Colors.orange,
      completed: false),
  Order(
      name: "Order 2",
      category: "500g",
      time: "3 Jan 2020",
      color: Colors.cyan,
      completed: true),
  Order(
      name: "Order 3",
      category: "7kg",
      time: "28 Oct 2019",
      color: Colors.pink,
      completed: false),
];

class ProfileScreen extends StatelessWidget {
//  final PageController pageController;
//  ProfileScreen(this.pageController);
  @override
  Widget build(BuildContext context) {
    var auth = Provider.of<Auth>(context, listen: false);
    return Scaffold(
      body: auth.isAuth
          ? MainPage()
          : FutureBuilder(
              future: auth.tryAutoLogin(),
              builder: (ctx, authResultSnapshot) =>
                  authResultSnapshot.connectionState == ConnectionState.waiting
                      ? SplashScreen()
                      : AuthScreen(),
            ),
//
    );
  }
}

class OrderRow extends StatelessWidget {
  final Order task;
  final double dotSize = 20.0;
  final Animation<double> animation;

  const OrderRow({Key key, this.task, this.animation}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Row(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.0 - dotSize / 2),
              child: Container(
                height: dotSize,
                width: dotSize,
                decoration:
                    BoxDecoration(shape: BoxShape.circle, color: task.color),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    task.name,
                    style: TextStyle(fontSize: 18.0),
                  ),
                  Text(
                    task.category,
                    style: TextStyle(fontSize: 12.0, color: Colors.grey),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                task.time,
                style: TextStyle(fontSize: 12.0, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MainPage extends StatefulWidget {
//  final PageController pagectrl;
//  MainPage(this.pagectrl);
//  MainPage({Key key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final double _imageHeight = 256.0;
  ListModel listModel;
  bool showOnlyCompleted = false;

  @override
  void initState() {
    super.initState();
    listModel = ListModel(_listKey, tasks);
  }

  @override
  void dispose() {
    // TODO: implement dispose
//    widget.pagectrl.animateToPage(1,
//        duration: Duration(milliseconds: 200), curve: Curves.ease);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<ListTile> choices = <ListTile>[
      ListTile(
        leading: Icon(
          Icons.exit_to_app,
//          color: Theme.of(context).primaryColor,
        ),
        title: Text("Logout"),
        onTap: () {
          Provider.of<Auth>(context, listen: false).logout(context);
        },
      ),
      ListTile(
        leading: Icon(Icons.settings),
        title: Text("Settings"),
      )
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Profile",
          style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 1,
        actions: <Widget>[
          PopupMenuButton<ListTile>(
            icon: Icon(
              Icons.menu,
              color: Colors.grey[600],
            ),
            //onSelected: choiceAction,
            itemBuilder: (BuildContext context) {
              return choices.map((ListTile choice) {
                return PopupMenuItem<ListTile>(
                  value: choice,
                  child: choice,
                );
              }).toList();
            },
          )
        ],
      ),
      body: Stack(
        children: <Widget>[
          _buildTimeline(),
          _buildImage(),
          _buildProfileRow(),
          _buildBottomPart(),
//          _buildFab(),
        ],
      ),
    );
  }

  Widget _buildImage() {
    return Positioned.fill(
      bottom: null,
      child: ClipPath(
        clipper: DialogonalClipper(),
        child: Image.asset(
          'assets/photos/earth_map.jpg',
          fit: BoxFit.fill,
          height: _imageHeight,
          colorBlendMode: BlendMode.srcOver,
          color: Color.fromARGB(60, 20, 10, 50),
        ),
      ),
    );
  }

  Widget _buildProfileRow() {
    return Padding(
      padding: EdgeInsets.only(left: 16.0, top: _imageHeight / 2.5),
      child: Row(
        children: <Widget>[
          CircleAvatar(
            minRadius: 28.0,
            maxRadius: 28.0,
//            backgroundImage: AssetImage('images/avatar.jpg'), //todo: users photo
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'Gismat beleymish', //todo: users name
                  style: TextStyle(
                      fontSize: 26.0,
                      color: Colors.white,
                      fontWeight: FontWeight.w400),
                ),
//                Text(
//                  'Product designer',
//                  style: TextStyle(
//                      fontSize: 14.0,
//                      color: Colors.white,
//                      fontWeight: FontWeight.w300),
//                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomPart() {
    return Padding(
      padding: EdgeInsets.only(top: _imageHeight),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildMyOrdersHeader(),
          _buildOrdersList(),
        ],
      ),
    );
  }

  Widget _buildOrdersList() {
    return Expanded(
      child: AnimatedList(
        initialItemCount: tasks.length,
        key: _listKey,
        itemBuilder: (context, index, animation) {
          return OrderRow(
            task: listModel[index],
            animation: animation,
          );
        },
      ),
    );
  }

  Widget _buildMyOrdersHeader() {
    return Padding(
      padding: EdgeInsets.only(left: 64.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'My Orders',
            style: TextStyle(fontSize: 34.0),
          ),
          SizedBox(
            height: 10,
          )
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    return Positioned(
      top: 0.0,
      bottom: 0.0,
      left: 32.0,
      child: Container(
        width: 1.0,
        color: Colors.grey[300],
      ),
    );
  }
}

class DialogonalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0.0, size.height - 60.0);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0.0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
