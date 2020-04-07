import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class ProfileScreenAnother extends StatefulWidget {
  var user;
  ProfileScreenAnother({this.user});
  static const routeName = '/profile';

  @override
  _ProfileScreenAnotherState createState() => _ProfileScreenAnotherState();
}

class _ProfileScreenAnotherState extends State<ProfileScreenAnother> {
  List _reviews = [];
  Map _stats = {};
  bool reviewsNotReady = true;
  bool statsNotReady = true;
  @override
  void initState() {
    super.initState();
  }

  Future fetchAndSetReviews(id) async {
    String url = "http://briddgy.herokuapp.com/api/users/" + id.toString() + "/reviews/";
    final response = await http.get(
      url,
      headers: {
        HttpHeaders.CONTENT_TYPE: "application/json",
      },
    );

    if (this.mounted) {
      setState(() {
        final dataReviews = json.decode(response.body) as Map<String, dynamic>;
        _reviews = dataReviews["results"];
        reviewsNotReady = false;
      });
    }
    fetchAndSetStatistics(id);

    return _reviews;
  }

  Future fetchAndSetStatistics(id) async {
    String url = "http://briddgy.herokuapp.com/api/users/stats/" + id.toString() + '/';
    final response = await http.get(
      url,
      headers: {
        HttpHeaders.CONTENT_TYPE: "application/json",
      },
    );

    if (this.mounted) {
      setState(() {
        final dataOrders = json.decode(response.body);
        _stats = dataOrders;
        statsNotReady = false;
      });
    }

    return _stats;
  }

  @override
  Widget build(BuildContext context) {
    fetchAndSetReviews(widget.user["id"]);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back),
          color: Theme.of(context).primaryColor,
        ),
        title: Text(
          "Profile", //Todo: User's name ??
          style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 1,
      ),
      body: reviewsNotReady || statsNotReady
          ? Center(child: CircularProgressIndicator())
          : Center(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Card(
                      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: <Widget>[
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                CircleAvatar(
                                  radius: 70,

                                  backgroundImage: NetworkImage(
                                      // "https://briddgy.herokuapp.com/media/" + _user["avatarpic"].toString() +"/"
                                      "https://picsum.photos/250?image=9"), //Todo
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      MdiIcons.shieldCheck,
                                      color: Colors.lightGreen,
                                    ),
                                    Text(
                                      "  " + widget.user["first_name"].toString() + " " + widget.user["last_name"].toString(),
                                      style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700, color: Theme.of(context).primaryColor),
                                    ),
                                  ],
                                ),
                                Divider(
                                  color: Colors.grey[600],
                                  height: 50,
                                ),
                                ListTile(
                                  dense: true,
                                  title: Text(
                                    "Sent: ",
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  trailing: Text(
                                    _stats["totalorders"].toString(),
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ),
                                ListTile(
                                  dense: true,
                                  title: Text(
                                    "Delivered: ",
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  trailing: Text(
                                    _stats["totaltrips"].toString(),
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ),
                                ListTile(
                                  dense: true,
                                  title: Text(
                                    "Earned: ",
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  trailing: Text(
                                    _stats["totalearnings"].toString() + " \$",
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Text(
                      "Reviews:",
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: _reviews.length,
                      itemBuilder: (context, int index) {
                        return Column(
                          children: <Widget>[
                            ListTile(
                              contentPadding: EdgeInsets.symmetric(horizontal: 20),
                              isThreeLine: false,
                              leading: CircleAvatar(
                                radius: 30,
                                backgroundImage:
                                    NetworkImage('https://images-na.ssl-images-amazon.com/images/I/81NIli1PuqL._AC_SL1500_.jpg'), //Todo: UserPic
                              ),
                              title: Row(
                                children: <Widget>[
                                  Container(
                                    width: MediaQuery.of(context).size.width * 0.4,
                                    child: Text(
                                      _reviews[index]["author"]["first_name"].toString() +
                                          " " +
                                          _reviews[index]["author"]["last_name"].toString(), //Todo: Name
                                      softWrap: false,

                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    MdiIcons.star,
                                    color: Colors.orange,
                                    size: 15,
                                  ),
                                  Text(
                                    // Review and Ranking can be given separately
                                    "5  ", //Todo: Rating

                                    style: TextStyle(
                                      color: Colors.orange,
                                      fontSize: 15,
                                    ),
                                  ),
                                  Text(
                                    " 10 Dec 2019", //Todo: Date
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Text(_reviews[index]["comment"].toString()),
                            ),
                          ],
                        );
                      },
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
