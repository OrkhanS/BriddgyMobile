import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:briddgy/providers/ordersandtrips.dart';
import 'package:briddgy/screens/account_screen.dart';
import 'package:briddgy/screens/add_trip_screen.dart';
import 'package:briddgy/widgets/components.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:briddgy/localization/localization_constants.dart';
import 'package:briddgy/models/api.dart';
import 'package:briddgy/models/order.dart';
import 'package:briddgy/models/stats.dart';
import 'package:briddgy/models/trip.dart';
import 'package:briddgy/models/user.dart';
import 'package:briddgy/providers/auth.dart';
import 'package:briddgy/providers/messages.dart';
import 'package:briddgy/screens/add_review.dart';
import 'package:briddgy/screens/chats_screen.dart';
import 'package:briddgy/widgets/order_widget.dart';
import 'package:briddgy/widgets/progress_indicator_widget.dart';
import 'package:briddgy/widgets/review_widget.dart';
import 'package:briddgy/widgets/trip_widget.dart';
import 'package:provider/provider.dart';
import 'add_order_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  final User user;
  ProfileScreen({@required this.user});
  static const routeName = '/profile';

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List _reviews = [];
  Map _stats = {};
  int _tabSelected;
  bool reviewsNotReady = true;
  bool statsNotReady = true;
  bool ordersNotReady = true;
  bool tripsNotReady = true;
  User user;
  Stats stats;
  List orders = [];
  List trips = [];
  bool messageButton = true;
  String url;
  Size size;
  bool picturePosting = false;
  var imageFile;
  String nextReviewURL = "FirstCall";
  Auth auth;
  bool isMine = false;

  @override
  void initState() {
    user = widget.user;
    auth = Provider.of<Auth>(this.context, listen: false);
    auth.reviews = [];
    auth.reviewsloading = true;
    url = Api.users + user.id.toString() + "/reviews/";
    auth.fetchAndSetReviews(url);
    _reviews = [];
    _tabSelected = 1;

    fetchAndSetStatistics();
    super.initState();
  }

  Future removeReview(i) async {
    showDialog(
      context: this.context,
      builder: (ctx) => AlertDialog(
        title: Text("Are you sure you want to delete this review?"),
        content: Text("This action cannot be undone"),
        actions: <Widget>[
          FlatButton(
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.red),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
          FlatButton(
            child: Text('Yes,delete!'),
            onPressed: () {
              var url = Api.writeDeleteReview + user.id.toString() + '/';
              http.delete(
                url,
                headers: {
                  HttpHeaders.contentTypeHeader: "application/json",
                  "Authorization": "Token " + Provider.of<Auth>(this.context, listen: false).myTokenFromStorage,
                },
              );
              var auth = Provider.of<Auth>(this.context, listen: false);
              auth.reviews.removeAt(i);
              auth.notifyAuth();
              Navigator.of(ctx).pop();
              Flushbar(
                flushbarStyle: FlushbarStyle.GROUNDED,
                titleText: Text(
                  "Success",
                  style: TextStyle(color: Colors.black, fontSize: 22),
                ),
                messageText: Text(
                  "Review has been deleted",
                  style: TextStyle(color: Colors.black),
                ),
                icon: Icon(MdiIcons.delete),
                backgroundColor: Colors.white,
                borderColor: Theme.of(this.context).primaryColor,
                padding: const EdgeInsets.all(10),
                margin: EdgeInsets.only(left: 20, right: 20, bottom: 50),
                borderRadius: 10,
                duration: Duration(seconds: 5),
              )..show(this.context);
            },
          )
        ],
      ),
    );
  }

  Future loadOrders() async {
    String url = Api.orderById + user.id.toString() + '/orders/';
    final response = await http.get(
      url,
      headers: {
        HttpHeaders.contentTypeHeader: "application/json",
      },
    );

    if (this.mounted) {
      setState(() {
        Map<String, dynamic> data = json.decode(response.body) as Map<String, dynamic>;
        for (var i = 0; i < data["results"].length; i++) {
          orders.add(Order.fromJson(data["results"][i]));
        }
        ordersNotReady = false;
      });
    }
  }

  Future loadTrips() async {
    String url = Api.orderById + user.id.toString() + '/trips/';
    final response = await http.get(
      url,
      headers: {
        HttpHeaders.contentTypeHeader: "application/json",
      },
    );

    if (this.mounted) {
      setState(() {
        Map<String, dynamic> data = json.decode(response.body) as Map<String, dynamic>;
        for (var i = 0; i < data["results"].length; i++) {
          trips.add(Trip.fromJson(data["results"][i]));
        }
        tripsNotReady = false;
      });
    }
  }

  Future fetchAndSetStatistics() async {
    String url = Api.userStats + user.id.toString() + '/';
    final response = await http.get(
      url,
      headers: {
        HttpHeaders.contentTypeHeader: "application/json",
      },
    );

    if (this.mounted) {
      setState(() {
        Map<String, dynamic> data = json.decode(response.body) as Map<String, dynamic>;
        stats = Stats.fromJson(data);
        statsNotReady = false;
      });
    }
  }

  @override
  void didChangeDependencies() {
    auth = Provider.of<Auth>(this.context, listen: false);
    if (Provider.of<Auth>(context, listen: false).isAuth) if (user.id == Provider.of<Auth>(context, listen: false).user.id) isMine = true;
    super.didChangeDependencies();
    if (isMine) {
      orders = Provider.of<OrdersTripsProvider>(context).myorders;
      trips = Provider.of<OrdersTripsProvider>(context).mytrips;
    } else {
      loadOrders();
      loadTrips();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isMine) {
      orders = Provider.of<OrdersTripsProvider>(context).myorders;
      trips = Provider.of<OrdersTripsProvider>(context).mytrips;
    }
    return Consumer<Auth>(
      builder: (context, provider, child) {
        if (!provider.reviewsloading) {
          _reviews = [];
          _reviews = provider.reviews;
        }
        size = MediaQuery.of(context).size;
        return Scaffold(
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          floatingActionButton: Provider.of<Auth>(context, listen: false).isAuth
              ? auth.userdetail.id == user.id
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        RaisedButton.icon(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          color: Theme.of(context).scaffoldBackgroundColor,
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                          ),
                          icon: Icon(
                            Icons.add,
                            color: Theme.of(context).primaryColorDark,
                            size: 18,
                          ),
                          label: Text(
                            t(context, 'add_order'),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColorDark,
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (__) => AddOrderScreen()),
                            );
                          },
                        ),
                        RaisedButton.icon(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          color: Theme.of(context).scaffoldBackgroundColor,
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                          ),
                          icon: Icon(
                            Icons.add,
                            color: Theme.of(context).primaryColorDark,
                            size: 18,
                          ),
                          label: Text(
                            t(context, 'trip-add'),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColorDark,
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (__) => AddTripScreen()),
                            );
                          },
                        ),
//                        RaisedButton.icon(
//                          padding: EdgeInsets.symmetric(horizontal: 10),
//                          color: Theme.of(context).scaffoldBackgroundColor,
//                          elevation: 3,
//                          shape: RoundedRectangleBorder(
//                            borderRadius: BorderRadius.circular(18.0),
//                          ),
//                          icon: Icon(
//                            Icons.settings,
//                            color: Theme.of(context).primaryColor,
//                            size: 18,
//                          ),
//                          label: Text(
//                            t(context, 'settings'),
//                            style: TextStyle(
//                              fontWeight: FontWeight.bold,
//                              color: Theme.of(context).primaryColor,
//                            ),
//                          ),
//                          onPressed: () {
//                            Navigator.push(
//                              context,
//                              MaterialPageRoute(builder: (__) => AccountScreen()),
//                            );
//                          },
//                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        RaisedButton.icon(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                          ),
                          icon: Icon(
                            Icons.add,
                            color: Theme.of(context).primaryColorDark,
                            size: 18,
                          ),
                          label: Text(
                            t(context, 'review-add'),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColorDark,
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (__) => AddReviewScreen(
                                        user: user,
                                      )),
                            );
                          },
                        ),
                        messageButton
                            ? RaisedButton.icon(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                color: Colors.green,
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18.0),
                                ),
                                icon: Icon(
                                  MdiIcons.chatOutline,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                label: Text(
                                  t(context, 'message'),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                onPressed: () {
                                  setState(() {
                                    messageButton = false;
                                  });
                                  var auth = Provider.of<Auth>(context, listen: false);
                                  var messageProvider = Provider.of<Messages>(context, listen: false);

                                  messageProvider.createRooms(user.id, auth).whenComplete(() => {
                                        if (messageProvider.isChatRoomCreated)
                                          {
                                            setState(() {
                                              messageButton = true;
                                            }),
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (__) => ChatsScreen(provider: messageProvider, auth: auth)),
                                            ),
                                            Flushbar(
                                              title: t(context, 'success'),
                                              message: t(context, 'chat_with') + user.firstName.toString() + t(context, 'has_been_started'),
                                              padding: const EdgeInsets.all(8),
                                              borderRadius: 10,
                                              duration: Duration(seconds: 3),
                                            )..show(context)
                                          }
                                        else
                                          {
                                            setState(() {
                                              messageButton = true;
                                            }),
                                            Flushbar(
                                              title: t(context, 'failure'),
                                              message: t(context, 'please_try_again'),
                                              padding: const EdgeInsets.all(8),
                                              borderRadius: 10,
                                              duration: Duration(seconds: 3),
                                            )..show(context)
                                          }
                                      });
                                },
                              )
                            : ProgressIndicatorWidget(show: true),
                      ],
                    )
              : SizedBox(),
          body: SafeArea(
            child: Column(
              children: <Widget>[
                Card(
                  elevation: 3,
                  margin: EdgeInsets.symmetric(horizontal: 10),
//              decoration: BoxDecoration(
//                borderRadius: BorderRadius.circular(8),
//                color: Colors.blueGrey,
//              ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Provider.of<Auth>(context, listen: false).isAuth
                              ? auth.userdetail.id != user.id
                                  ? IconButton(
                                      icon: Icon(
                                        Icons.chevron_left,
                                        size: 21,
                                        //color: Colors.white,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    )
                                  : IconButton(
                                      icon: Icon(
                                        Icons.settings,
                                        size: 21,
                                        //color: Colors.white,
                                        color: Colors.blueGrey,
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (__) => AccountScreen()),
                                        );
                                      },
                                    )
                              : IconButton(
                                  icon: Icon(
                                    Icons.chevron_left,
                                    size: 21,
                                    //color: Colors.white,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                          Column(
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Icon(
                                    MdiIcons.email,
                                    color: user.isEmailVerified ? Colors.green : Colors.grey,
                                    size: 15,
                                  ),
                                  Icon(
                                    MdiIcons.phone,
                                    color: user.isNumberVerified ? Colors.green : Colors.grey,
                                    size: 15,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Text(
                                      user.firstName + " " + user.lastName,
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                        color: Colors.black,
//                                    color: Theme.of(context).primaryColor,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                child: Text(
                                  t(context, 'member_since') + DateFormat("d MMM yyyy").format(user.date_joined).toString(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
//                              Row(
//                                children: <Widget>[
////                                  GestureDetector(
////                                    onTap: () {},
////                                    child: Icon(
////                                      Icons.tag_faces,
////                                      color: user.isPhotoVerified ? Colors.green : Colors.grey,
////                                      size: 17,
////                                    ),
////                                  ),
//                                  SizedBox(width: 5),
//                                  Icon(
//                                    MdiIcons.phone,
//                                    color: user.isNumberVerified ? Colors.green : Colors.grey,
//                                    size: 17,
//                                  ),
//                                  Icon(
//                                    MdiIcons.email,
//                                    color: user.isEmailVerified ? Colors.green : Colors.grey,
//                                    size: 17,
//                                  ),
//                                ],
//                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
                            child: Column(
                              children: [
                                AvatarPicWidget(user: user),
                                StaticRatingBarWidget(
                                  rating: user.rating,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(color: Colors.blueGrey[50], borderRadius: BorderRadius.circular(8)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    t(context, 'earned'),
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "\$" + (statsNotReady ? "0.0" : stats.totalearnings.toString()),
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800]),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Text(
                                    t(context, 'contract_plural'),
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    (statsNotReady ? "0.0" : stats.totalcontracts.toString()),
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800]),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Text(
                                    t(context, 'trip_plural'),
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    (statsNotReady ? "0.0" : stats.totaltrips.toString()),
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800]),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Text(
                                    t(context, 'order_plural'),
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    (statsNotReady ? "0.0" : stats.totalorders.toString()),
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800]),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      IntrinsicHeight(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            SizedBox(
                              height: 40,
                            ),
                            Expanded(
                              child: InkWell(
                                child: Center(
                                  child: Text(t(context, "review_plural"),
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: (_tabSelected == 1 ? Theme.of(context).primaryColorDark : Colors.grey[500]))),
                                ),
                                onTap: () {
                                  setState(() {
                                    _tabSelected = 1;
                                  });
                                },
                              ),
                            ),
                            VerticalDivider(
                              color: Colors.grey[400],
                              thickness: 1,
                              width: 1,
                            ),
                            Expanded(
                              child: InkWell(
                                child: Center(
                                  child: Text(
                                    t(context, "order_plural"),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: (_tabSelected == 2 ? Theme.of(context).primaryColorDark : Colors.grey[500]),
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  setState(() {
                                    _tabSelected = 2;
                                  });
                                },
                              ),
                            ),
                            VerticalDivider(
                              color: Colors.grey[400],
                              thickness: 1,
                              width: 1,
                            ),
                            Expanded(
                              child: InkWell(
                                child: Center(
                                  child: Text(
                                    t(context, "trip_plural"),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: (_tabSelected == 3 ? Theme.of(context).primaryColorDark : Colors.grey[500]),
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  setState(() {
                                    _tabSelected = 3;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 5),
//                  Padding(
//                    padding: const EdgeInsets.symmetric(horizontal: 13.0, vertical: 5),
//                    child: Row(
//                      children: <Widget>[
//                        RaisedButton.icon(
//                          padding: EdgeInsets.symmetric(horizontal: 10),
//                          color: Colors.white,
//                          shape: RoundedRectangleBorder(
//                            borderRadius: BorderRadius.circular(18.0),
//                          ),
//                          icon: Icon(
//                            MdiIcons.star,
//                            color: Colors.green,
//                            size: 18,
//                          ),
//                          label: Text(
//                            t(context, 'review-add'),
//                            style: TextStyle(
//                              fontWeight: FontWeight.bold,
//                              color: Colors.green,
//                            ),
//                          ),
//                          onPressed: () {
//                            Navigator.push(
//                              context,
//                              MaterialPageRoute(builder: (__) => AddReviewScreen()),
//                            );
//                          },
//                        ),
//                        Expanded(
//                          child: SizedBox(
//                            height: 1,
//                          ),
//                        ),
//                        messageButton
//                            ? RaisedButton.icon(
//                                padding: EdgeInsets.symmetric(horizontal: 10),
//                                color: Colors.green,
//                                elevation: 2,
//                                shape: RoundedRectangleBorder(
//                                  borderRadius: BorderRadius.circular(18.0),
//                                ),
//                                icon: Icon(
//                                  MdiIcons.chatOutline,
//                                  color: Colors.white,
//                                  size: 18,
//                                ),
//                                label: Text(
//                                  t(context, 'message'),
//                                  style: TextStyle(
//                                    fontWeight: FontWeight.bold,
//                                    color: Colors.white,
//                                  ),
//                                ),
//                                onPressed: () {
//                                  setState(() {
//                                    messageButton = false;
//                                  });
//                                  var auth = Provider.of<Auth>(context, listen: false);
//                                  var messageProvider = Provider.of<Messages>(context, listen: false);
//
//                                  messageProvider.createRooms(user.id, auth).whenComplete(() => {
//                                        if (messageProvider.isChatRoomCreated)
//                                          {
//                                            setState(() {
//                                              messageButton = true;
//                                            }),
//                                            Navigator.push(
//                                              context,
//                                              MaterialPageRoute(builder: (__) => ChatsScreen(provider: messageProvider, auth: auth)),
//                                            ),
//                                            Flushbar(
//                                              title: t(context, 'success'),
//                                              message: t(context, 'chat_with') + user.firstName.toString() + t(context, 'has_been_started'),
//                                              padding: const EdgeInsets.all(8),
//                                              borderRadius: 10,
//                                              duration: Duration(seconds: 3),
//                                            )..show(context)
//                                          }
//                                        else
//                                          {
//                                            setState(() {
//                                              messageButton = true;
//                                            }),
//                                            Flushbar(
//                                              title: t(context, 'failure'),
//                                              message: t(context, 'please_try_again'),
//                                              padding: const EdgeInsets.all(8),
//                                              borderRadius: 10,
//                                              duration: Duration(seconds: 3),
//                                            )..show(context)
//                                          }
//                                      });
//                                },
//                              )
//                            : ProgressIndicatorWidget(show: true),
//                      ],
//                    ),
//                  ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                //todo i18n
                if (_reviews.length == 0 && _tabSelected == 1)
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20.0),
                        child: SvgPicture.asset(
                          "assets/photos/empty_order.svg",
                          height: size.height * 0.2,
                        ),
                      ),
                      Text(
                        user.firstName + " has no reviews",
                        style: Theme.of(context).textTheme.headline5.copyWith(color: Colors.grey[500]),
                      ),
                    ],
                  ),
                if (orders.length == 0 && _tabSelected == 2)
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20.0),
                        child: SvgPicture.asset(
                          "assets/photos/empty_order.svg",
                          height: size.height * 0.2,
                        ),
                      ),
                      Text(
                        user.firstName + " has no orders",
                        style: Theme.of(context).textTheme.headline5.copyWith(color: Colors.grey[500]),
                      ),
                    ],
                  ),
                if (trips.length == 0 && _tabSelected == 3)
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20.0),
                        child: SvgPicture.asset(
                          "assets/photos/empty_order.svg",
                          height: size.height * 0.2,
                        ),
                      ),
                      Text(
                        user.firstName + " has no trips",
                        style: Theme.of(context).textTheme.headline5.copyWith(color: Colors.grey[500]),
                      ),
                    ],
                  ),
                if (picturePosting) ProgressIndicatorWidget(show: true),
                Expanded(
                  child: ListView.builder(
                    itemBuilder: (context, int i) {
                      if (_tabSelected == 1) {
                        return ReviewWidget(review: _reviews[i]);
                      } else if (_tabSelected == 2)
                        return OrderWidget(
                          order: orders[i],
                          i: i,
                          modeProfile: auth.user != null ? auth.userdetail.id == user.id ? true : false : false,
                        );
                      else {
                        return TripWidget(
                          trip: trips[i],
                          i: i,
                          modeProfile: true,
                        );
                      }
                    },
                    itemCount: (_tabSelected == 1 ? _reviews.length : _tabSelected == 2 ? orders.length : trips.length),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
