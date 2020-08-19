import 'package:cached_network_image/cached_network_image.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:optisend/models/api.dart';
import 'package:optisend/models/trip.dart';
import 'package:optisend/providers/auth.dart';
import 'package:optisend/providers/messages.dart';
import 'package:optisend/screens/chats_screen.dart';
import 'package:optisend/screens/profile_screen_another.dart';
import 'package:optisend/screens/trip_screen.dart';
import 'package:provider/provider.dart';

class TripWidget extends StatelessWidget {
  Trip trip;
  var i;
  TripWidget({@required this.trip, @required this.i});
  var imageUrl;
  @override
  Widget build(BuildContext context) {
    if (imageUrl == null) {
      imageUrl = trip.owner.avatarpic == null
          ? Api.noPictureImage
          : Api.storageBucket + trip.owner.avatarpic.toString();
    }
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (__) => TripScreen(
              trip: trip,
            ),
          ),
        );
      },
      child: Column(
        children: <Widget>[
          Container(
            height: 100,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                CircleAvatar(
                  radius: 40,
                  child: FadeInImage(
                      image: NetworkImage(imageUrl),
                      placeholder: NetworkImage("https://cdn2.iconfinder.com/data/icons/outlined-set-1/29/no_camera-512.png")),
                  backgroundColor: Colors.grey[300],
                  // backgroundImage: NetworkImage(
                  //   imageUrl,
                  // ),
                ),
                Expanded(
                  flex: 5,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          trip.owner.firstName + " " + trip.owner.lastName,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(fontSize: 20, color: Colors.grey[600], fontWeight: FontWeight.bold),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Icon(
                              Icons.location_on,
                              color: Theme.of(context).primaryColor,
                              size: 16,
                            ),
                            Text(
                              "  " + trip.source.cityAscii + " > " + trip.destination.cityAscii,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(fontSize: 15, color: Colors.grey[600], fontWeight: FontWeight.normal),
                            ),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Icon(
                              Icons.date_range,
                              color: Theme.of(context).primaryColor,
                              size: 16,
                            ),
                            Text(
                              "  " + DateFormat('dd MMMM').format(trip.date), //Todo: date
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Icon(
                              MdiIcons.weightKilogram,
                              color: Theme.of(context).primaryColor,
                              size: 16,
                            ),
                            Text(
                              "  " + trip.weightLimit.toString() + ' kg',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                //todo check if I am the owner
                //todo if user is the owner, then replace the button below with delete button
                Expanded(
                  flex: 3,
                  child: RaisedButton.icon(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    color: Theme.of(context).scaffoldBackgroundColor,
                    elevation: 1,
                    icon: Icon(
                      MdiIcons.chatOutline,
                      color: Theme.of(context).primaryColor,
                      size: 18,
                    ),
                    label: Text(
                      " Message",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    onPressed: () {
                      var auth = Provider.of<Auth>(context, listen: false);
                      var messageProvider = Provider.of<Messages>(context, listen: false);

                      messageProvider.createRooms(trip.owner.id, auth);
                      messageProvider.isChatsLoading = true;
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (__) => ChatsScreen(provider: messageProvider, auth: auth)),
                      );
                      Flushbar(
                        title: "Success",
                        message: "Chat with " + trip.owner.firstName.toString() + " has been started!",
                        padding: const EdgeInsets.all(8),
                        borderRadius: 10,
                        duration: Duration(seconds: 3),
                      )..show(context);
                    },
                  ),
                ),
                SizedBox(width: 10),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Divider(
              height: 4,
              color: Colors.black45,
            ),
          ),
        ],
      ),
    );
  }
}

class TripFadeWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          height: 100,
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.grey[200],
              ),
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        height: 10,
                        width: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.grey[200],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Icon(
                            Icons.location_on,
                            color: Colors.grey[200],
                            size: 16,
                          ),
                          Container(
                            height: 10,
                            width: 90,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.grey[200],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Icon(
                            Icons.date_range,
                            color: Colors.grey[200],
                            size: 16,
                          ),
                          Container(
                            height: 10,
                            width: 90,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.grey[200],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Icon(
                            MdiIcons.weightKilogram,
                            color: Colors.grey[200],
                            size: 16,
                          ),
                          Container(
                            height: 10,
                            width: 90,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.grey[200],
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              //todo check if I am the owner
              //todo if user is the owner, then replace the button below with delete button
              Expanded(
                flex: 3,
                child: RaisedButton.icon(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  color: Theme.of(context).scaffoldBackgroundColor,
                  elevation: 1,
                  onPressed: () {},
                  icon: Icon(
                    MdiIcons.chatOutline,
                    color: Colors.grey[200],
                    size: 18,
                  ),
                  label: Text(
                    " Message",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[200],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Divider(
            height: 4,
            color: Colors.black45,
          ),
        ),
      ],
    );
  }
}

class TripSimpleWidget extends StatelessWidget {
  Trip trip;
  var i;
  var imageUrl;
  TripSimpleWidget({@required this.trip, @required this.i});
  @override
  Widget build(BuildContext context) {
    if (imageUrl == null) {
      imageUrl = trip.owner.avatarpic == null
          ? Api.noPictureImage
          : Api.storageBucket + trip.owner.avatarpic.toString();
    }
    return Column(
      children: <Widget>[
        Container(
          height: 100,
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.grey[300],
                backgroundImage: NetworkImage(
                  imageUrl,
                ),
              ),
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        trip.owner.firstName + " " + trip.owner.lastName,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(fontSize: 20, color: Colors.grey[600], fontWeight: FontWeight.bold),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Icon(
                            Icons.location_on,
                            color: Theme.of(context).primaryColor,
                            size: 16,
                          ),
                          Text(
                            "  " + trip.source.cityAscii + " > " + trip.destination.cityAscii,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(fontSize: 15, color: Colors.grey[600], fontWeight: FontWeight.normal),
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Icon(
                            Icons.date_range,
                            color: Theme.of(context).primaryColor,
                            size: 16,
                          ),
                          Text(
                            "  " + DateFormat('dd MMMM').format(trip.date), //Todo: date
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Icon(
                            MdiIcons.weightKilogram,
                            color: Theme.of(context).primaryColor,
                            size: 16,
                          ),
                          Text(
                            "  " + trip.weightLimit.toString() + ' kg',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(width: 10),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Divider(
            height: 4,
            color: Colors.black45,
          ),
        ),
      ],
    );
  }
}
