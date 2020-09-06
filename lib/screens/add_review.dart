import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/svg.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:optisend/localization/localization_constants.dart';
import 'package:optisend/models/user.dart';

class AddReviewScreen extends StatefulWidget {
  final User user;

  AddReviewScreen({@required this.user});

  @override
  _AddReviewScreenState createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends State<AddReviewScreen> {
  double _rating = 0;

  String _review = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: RaisedButton.icon(
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
          //todo Orxan
        },
      ),
      body: SafeArea(
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        RatingBar(
                          initialRating: 0,
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
                          _rating.toString(),
                        ),
                      ],
                    ),
                    Container(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: 300.0,
                        ),
                        child: TextField(
                          maxLines: null,
                          decoration: InputDecoration(
                            labelText: t(context, 'review'),
                            icon: Icon(MdiIcons.informationOutline),
                          ),
                          onChanged: (String val) {
                            _review = val;
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
