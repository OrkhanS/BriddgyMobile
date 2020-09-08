import 'dart:convert';
import 'dart:io';

import 'package:briddgy/models/api.dart';
import 'package:briddgy/providers/auth.dart';
import 'package:briddgy/widgets/progress_indicator_widget.dart';
import 'package:flushbar/flushbar.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/svg.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:briddgy/localization/localization_constants.dart';
import 'package:briddgy/models/user.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';


class AddReviewScreen extends StatefulWidget {
  final User user;

  AddReviewScreen({@required this.user});

  @override
  _AddReviewScreenState createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends State<AddReviewScreen> {
  double _rating = 5;
  User user;
  String _review = '';
  bool showAddReviewButton = true;

  @override
  void initState() {
    user = widget.user;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
      return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height * 0.8,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: AppBar(
                    backgroundColor: Colors.white,
                    centerTitle: true,
                    leading: IconButton(
                      color: Theme.of(context).primaryColor,
                      icon: Icon(
                        Icons.chevron_left,
                        size: 24,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    title: Text(
                      t(context, 'review-add'),
                      style: TextStyle(
//                    color: Colors.black,
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    elevation: 1,
                  ),
                ),
                Form(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                    child: Column(
                      children: [
                        Container(
                          height: 200,
                          padding: EdgeInsets.all(10),
                          child: SvgPicture.asset(
                            "assets/photos/review.svg",
                            colorBlendMode: BlendMode.lighten,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).primaryColor.withOpacity(.3),
                                offset: Offset(5, 5),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  RatingBar(
                                    initialRating: _rating,
                                    minRating: 1,
                                    direction: Axis.horizontal,
                                    glowColor: Colors.amber,
                                    glowRadius: .2,
                                    itemSize: 30,
                                    allowHalfRating: false,
                                    itemCount: 5,
                                    itemPadding: EdgeInsets.symmetric(horizontal: 1.0),
                                    itemBuilder: (context, _) => Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                    ),
                                    onRatingUpdate: (val) {
                                      setState(() {
                                        _rating = val;
                                      });
                                    },
                                  ),
                                  Text(
                                    " " + _rating.toString(),
                                    style: Theme.of(context).textTheme.headline6.copyWith(color: Colors.grey[700]),
                                  ),
                                ],
                              ),
                              Divider(),
                              TextField(
                                maxLines: null,
                                decoration: InputDecoration(
                                  labelText: t(context, 'review'),
                                  icon: Icon(MdiIcons.informationOutline),
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                ),
                                onChanged: (String val) {
                                  _review = val;
                                },
                              ),
                              if(showAddReviewButton)
                                RaisedButton.icon(
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  color: Colors.green,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                  icon: Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  label: Text(
                                    t(context, 'review-add'),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      showAddReviewButton = false;
                                    });
                                    var now = DateTime.now();
                                    final url = Api.writeDeleteReview;
                                    http.post(
                                      url,
                                      headers: {
                                          HttpHeaders.contentTypeHeader: "application/json",
                                          "Authorization": "Token " + Provider.of<Auth>(context,listen:false).myTokenFromStorage,
                                      },
                                      body: json.encode({
                                          "reviewTo": user.id,
                                          "comment": _review,
                                          "rating": _rating,
                                          "Date": DateFormat('yyyy-MM-dd hh:mm:ss').format(now).toString()
                                        })
                                      
                                    ).then((value){
                                      if(value.statusCode == 200){
                                        Navigator.pop(context);
                                        var auth = Provider.of<Auth>(context,listen: false);
                                        var url = Api.users + user.id.toString() + "/reviews/";
                                        auth.reviewsloading = true; auth.fetchAndSetReviews(url);
                                        Flushbar(
                                        title: "${t(context, 'success')}!",
                                        backgroundColor: Colors.green[800],
                                        message: t(context, 'review_added'),
                                        padding: const EdgeInsets.all(8),
                                        borderRadius: 10,
                                        duration: Duration(seconds: 3),
                                      )..show(context);
                                      } else if(value.statusCode == 403){
                                          Flushbar(
                                          title: "${t(context, 'failed')}!",
                                          backgroundColor: Colors.red[800],
                                          message: t(context, 'review_not_added_contract'),
                                          padding: const EdgeInsets.all(8),
                                          borderRadius: 10,
                                          duration: Duration(seconds: 3),
                                        )..show(context);
                                      } else if (value.statusCode == 409){
                                        Flushbar(
                                          title: "${t(context, 'failed')}!",
                                          backgroundColor: Colors.red[800],
                                          message: t(context, 'review_not_added'),
                                          padding: const EdgeInsets.all(8),
                                          borderRadius: 10,
                                          duration: Duration(seconds: 3),
                                        )..show(context);
                                      } else{
                                        Flushbar(
                                            title: t(context, 'failure'),
                                            message: t(context, 'please_try_again'),
                                            padding: const EdgeInsets.all(8),
                                            borderRadius: 10,
                                            duration: Duration(seconds: 3),
                                          )..show(context);
                                      }
                                      setState(() {
                                        showAddReviewButton = true;
                                      });

                                    });
                                  },
                                ),

                                if(!showAddReviewButton)
                                ProgressIndicatorWidget(show: true)
                            
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );      
  }
}
