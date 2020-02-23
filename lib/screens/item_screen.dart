import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ItemScreen extends StatelessWidget {
  static const routeName = '/orders/item';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          color: Theme.of(context).primaryColor,
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          "Item Screen", //Todo: item name
          style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold),
        ),
        elevation: 1,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(40)),
                    child: Image.network(
                      'https://images-na.ssl-images-amazon.com/images/I/81NIli1PuqL._AC_SL1500_.jpg',
                      height: 250,
                      width: 250,
                      fit: BoxFit.cover,
                      loadingBuilder: (BuildContext context, Widget child,
                          ImageChunkEvent loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 26.0, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  CircleAvatar(
                    radius: 24.0,
                    backgroundImage: NetworkImage(
                        "https://randomuser.me/api/portraits/women/34.jpg"),
                  ),
                  Text(
                    "Kazato Suriname",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    width: 50,
                    height: 25,
                    decoration: BoxDecoration(
                      color: Colors.lightGreenAccent,
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Icon(
                          Icons.star,
                          size: 15,
                          color: Colors.white,
                        ),
                        Text(
                          "4.5",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  )
//                  RatingBar(
//                    initialRating: 3,
//                    direction: Axis.horizontal,
//                    allowHalfRating: true,
//                    itemCount: 5,
//                    glowColor: Colors.amber,
//                    ratingWidget: RatingWidget(
//                      full: Icon(Icons.star),
//                      half: Icon(Icons.star_half),
//                      empty: Icon(Icons.star_border),
//                    ),
//                    itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
//                    onRatingUpdate: (rating) {
//                      print(rating);
//                    },
//                  ),
                ],
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15),
              child: Text(
                "Item Details",
                style: TextStyle(
                  fontSize: 25,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            Card(
              margin: EdgeInsets.symmetric(horizontal: 40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              elevation: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  ListTile(
                    dense: true,
                    title: Text(
                      "Departure city:",
                      style: TextStyle(
                        fontSize: 17,
                        color: Colors.grey[600],
                      ),
                    ),
                    trailing: Text(
                      'Baku', //todo: data
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  ListTile(
                    dense: true,
                    title: Text(
                      "Arrival city:",
                      style: TextStyle(
                        fontSize: 17,
                        color: Colors.grey[600],
                      ),
                    ),
                    trailing: Text(
                      'Yevlax', //todo: data
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  ListTile(
                    dense: true,
                    title: Text(
                      "Arrival date:",
                      style: TextStyle(
                        fontSize: 17,
                        color: Colors.grey[600],
                      ),
                    ),
                    trailing: Text(
                      '25 Apr 2020', //todo: data
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  ListTile(
                    dense: true,
                    title: Text(
                      "Weight:",
                      style: TextStyle(
                        fontSize: 17,
                        color: Colors.grey[600],
                      ),
                    ),
                    trailing: Text(
                      '800 gr', //todo: data
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  ListTile(
                    dense: true,
                    title: Text(
                      "Dimensions:",
                      style: TextStyle(
                        fontSize: 17,
                        color: Colors.grey[600],
                      ),
                    ),
                    trailing: Text(
                      '25x17x20', //todo: data
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  ListTile(
                    dense: true,
                    title: Text(
                      "Item cost:", //todo: data
                      style: TextStyle(
                        fontSize: 17,
                        color: Colors.grey[600],
                      ),
                    ),
                    trailing: Text(
                      '80 \$',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ), //
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15),
              child: Text(
                "Description",
                style: TextStyle(
                  fontSize: 25,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              margin: EdgeInsets.symmetric(horizontal: 40),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Text(
                  "Salam gagaeadable content of a page when looking at its layout. The "
                  "point of using Lorem Ipsum is that it has a more-or-les"
                  "t, and a search for 'lorem ipsum' will uncover many web "
                  "sites still in their infanc",
                  style: TextStyle(fontSize: 17),
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  RaisedButton(
                    color: Colors.white,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Text(
                          "Message",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 20,
                          color: Theme.of(context).primaryColor,
                        )
                      ],
                    ),
                    onPressed: () {},
                  ),
                  RaisedButton(
                    color: Theme.of(context).primaryColor,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Text(
                          "To Baggage",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Icon(
                          Icons.add,
                          size: 20,
                          color: Colors.white,
                        )
                      ],
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
