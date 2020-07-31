import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:optisend/models/trip.dart';

class TripWidget extends StatelessWidget {
  Trip trip;
  var i;
  TripWidget({@required this.trip, @required this.i});
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
              Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Image.network(
                    "https://img.icons8.com/wired/2x/passenger-with-baggage.png",
//                    frameBuilder: (BuildContext context, Widget child, int frame, bool wasSynchronouslyLoaded) {
//                      return Container(
//                        width: 60,
//                        height: 60,
//                        color: Colors.grey[200],
//                      );
//                    },
                    height: 60,
                    width: 60,
                  )

                  // Image.network(
                  //         getImageUrl(_trips[i]["orderimage"])
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
                        trip.owner.firstName + " " + trip.owner.lastName, //Todo: title
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
                            "  " + DateFormat.yMMMd().format(trip.date), //Todo: date
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Icon(
                            MdiIcons.weightKilogram, //todo: icon
                            color: Theme.of(context).primaryColor,
                            size: 16,
                          ),
                          Text(
                            "  " + trip.weightLimit.toString(),
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
                child: RaisedButton(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  color: Theme.of(context).scaffoldBackgroundColor,
                  elevation: 1,
                  onPressed: () {
                    //todo Orxan fix
//                  createRooms(tripsProvider.trips[i]["owner"]["id"]);
                    Flushbar(
                      title: "Chat with " + trip.owner.firstName.toString() + " has been started!",
                      message: "Check Chats to see more.",
                      padding: const EdgeInsets.all(8),
                      borderRadius: 10,
                      duration: Duration(seconds: 5),
                    )..show(context);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Icon(
                        MdiIcons.chatOutline,
                        color: Theme.of(context).primaryColor,
                        size: 18,
                      ),
                      Text(
                        " Message",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
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
