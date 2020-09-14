import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class StaticRatingBarWidget extends StatelessWidget {
  StaticRatingBarWidget({@required this.rating});
  final double rating;

  @override
  Widget build(BuildContext context) {
    return RatingBar(
      ignoreGestures: true,
      initialRating: rating,
      minRating: 1,
      direction: Axis.horizontal,
      glowColor: Colors.amber,
      glowRadius: .2,
      itemSize: 15,
      allowHalfRating: false,
      itemCount: 5,
      itemBuilder: (context, _) => Icon(
        Icons.star,
        color: Colors.amber,
      ),
    );
  }
}
