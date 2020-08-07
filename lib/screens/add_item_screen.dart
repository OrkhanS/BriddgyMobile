import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart';
import 'package:optisend/models/api.dart';
import 'package:optisend/providers/ordersandtrips.dart';
import 'package:flushbar/flushbar.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:async/async.dart';

class AddItemScreen extends StatefulWidget {
  static const routeName = '/orders/add_item';
  OrdersTripsProvider orderstripsProvider;
  var token;
  AddItemScreen({this.orderstripsProvider, this.token});
  @override
  _AddItemScreenState createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  String title;
  String from, to, description;
  String weight, price;
  List _suggested = [];
  List _cities = [];
  bool isLoading = true;
  var imageFile;

  final TextEditingController _typeAheadController = TextEditingController();
  final TextEditingController _typeAheadController2 = TextEditingController();
  Future<void> addPicture(id) async {
    var token = widget.token;
    const url = Api.addOrderImage;
    var uri = Uri.parse(url);
    var request = new MultipartRequest("POST", uri);

    var multipartFile = await MultipartFile.fromPath("photo", imageFile);
    request.files.add(multipartFile);

    StreamedResponse response = await request.send();
    response.stream.transform(utf8.decoder).listen((value) {
      print(value);
    });
    http.put(url,
        headers: {
          HttpHeaders.CONTENT_TYPE: "application/json",
          "Authorization": "Token " + token,
        },
        body: json.encode({
          "file": base64Encode(imageFile.readAsBytesSync()),
          "order_id": id,
        }));
  }

  Future upload(id) async {
    var stream =
        new http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
    var length = await imageFile.length();

    var uri = Uri.parse(Api.addOrderImage);

    var request = new http.MultipartRequest("PUT", uri);
    var multipartFile = new http.MultipartFile('file', stream, length,
        filename: basename(imageFile.path));
    request.headers['Authorization'] = "Token " + widget.token;
    //contentType: new MediaType('image', 'png'));
    request.fields["order_id"] = id.toString();

    request.files.add(multipartFile);
    var response = await request.send();
    print(response.statusCode);
    response.stream.transform(utf8.decoder).listen((value) {
      print(value);
    });
  }

  Future<void> _showSelectionDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text("Choose Image source"),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    GestureDetector(
                      child: Text("Gallery"),
                      onTap: () {
                        _openGallery(context);
                      },
                    ),
                    Divider(),
                    GestureDetector(
                      child: Text("Camera"),
                      onTap: () {
                        _openCamera(context);
                      },
                    )
                  ],
                ),
              ));
        });
  }

  void _openGallery(BuildContext context) async {
    var picture = await ImagePicker.pickImage(source: ImageSource.gallery);
    this.setState(() {
      imageFile = picture;
    });
    Navigator.of(context).pop();
  }

  void _openCamera(BuildContext context) async {
    var picture = await ImagePicker.pickImage(source: ImageSource.camera);
    this.setState(() {
      imageFile = picture;
    });
    Navigator.of(context).pop();
  }

  Widget _setImageView() {
    if (imageFile != null) {
      return Image.file(
        imageFile,
        fit: BoxFit.fitWidth,
      );
    } else {
      return Text("Please select an image");
    }
  }

  FutureOr<Iterable> getSuggestions(String pattern) async {
    String url = Api.getSuggestions + pattern;
    await http.get(
      url,
      headers: {HttpHeaders.CONTENT_TYPE: "application/json"},
    ).then((response) {
      setState(
        () {
          final dataOrders = json.decode(response.body) as Map<String, dynamic>;
          _suggested = dataOrders["results"];
          isLoading = false;
        },
      );
    });
    _cities = [];
    for (var i = 0; i < _suggested.length; i++) {
      _cities.add(_suggested[i]["city_ascii"].toString() +
          ", " +
          _suggested[i]["country"].toString() +
          ", " +
          _suggested[i]["id"].toString());
    }
    return _cities;
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
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
                    "Add Item", //Todo: item name
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold),
                  ),
                  elevation: 1,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 20.0, top: 20, bottom: 20),
                    child: Text(
                      "Item Information",
                      style: TextStyle(
                          fontSize: 25, color: Theme.of(context).primaryColor),
                    ),
                  ),
                ],
              ),
              Container(
//              alignment: Alignment.center,
                width: deviceWidth * 0.8,
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Title',
                    icon: Icon(Icons.markunread_mailbox),
                  ),
                  onChanged: (String val) {
                    title = val;
                  },
                ),
              ),
              Container(
                width: deviceWidth * 0.8,
                child: TypeAheadFormField(
                  keepSuggestionsOnLoading: false,
                  debounceDuration: const Duration(milliseconds: 200),
                  textFieldConfiguration: TextFieldConfiguration(
                    onSubmitted: (val) {
                      from = val;
                    },
                    controller: this._typeAheadController,
                    decoration: InputDecoration(
                        labelText: 'From', icon: Icon(Icons.location_on)),
                  ),
                  suggestionsCallback: (pattern) {
                    return getSuggestions(pattern);
                  },
                  itemBuilder: (context, suggestion) {
                    return ListTile(
                      title: Text(suggestion.toString().split(", ")[0] +
                          ", " +
                          suggestion.toString().split(", ")[1]),
                    );
                  },
                  transitionBuilder: (context, suggestionsBox, controller) {
                    return suggestionsBox;
                  },
                  onSuggestionSelected: (suggestion) {
                    this._typeAheadController.text =
                        suggestion.toString().split(", ")[0] +
                            ", " +
                            suggestion.toString().split(", ")[1];
                    from = suggestion.toString().split(", ")[2];
                  },
                  validator: (value) {
                    from = value;
                    if (value.isEmpty) {
                      return 'Please select a city';
                    }
                  },
                  onSaved: (value) => from = value,
                ),
              ),

              Container(
                width: deviceWidth * 0.8,
                child: TypeAheadFormField(
                  keepSuggestionsOnLoading: false,
                  debounceDuration: const Duration(milliseconds: 200),
                  textFieldConfiguration: TextFieldConfiguration(
                    onSubmitted: (val) {
                      to = val;
                    },
                    controller: this._typeAheadController2,
                    decoration: InputDecoration(
                        labelText: 'To', icon: Icon(Icons.location_on)),
                  ),
                  suggestionsCallback: (pattern) {
                    return getSuggestions(pattern);
                  },
                  itemBuilder: (context, suggestion) {
                    return ListTile(
                      title: Text(suggestion.toString().split(", ")[0] +
                          ", " +
                          suggestion.toString().split(", ")[1]),
                    );
                  },
                  transitionBuilder: (context, suggestionsBox, controller) {
                    return suggestionsBox;
                  },
                  onSuggestionSelected: (suggestion) {
                    this._typeAheadController2.text =
                        suggestion.toString().split(", ")[0] +
                            ", " +
                            suggestion.toString().split(", ")[1];
                    to = suggestion.toString().split(", ")[2];
                  },
                  validator: (value) {
                    to = value;
                    if (value.isEmpty) {
                      return 'Please select a city';
                    }
                  },
                  onSaved: (value) => to = value,
                ),
              ),

//            Container(
//              padding: EdgeInsets.symmetric(vertical: 10),
//              width: deviceWidth * 0.4,
//              child: RaisedButton(
//                shape: RoundedRectangleBorder(
//                    borderRadius: BorderRadius.circular(5.0)),
//                elevation: 4.0,
//                onPressed: () {
//                  DatePicker.showDatePicker(context,
//                      theme: DatePickerTheme(
//                        itemStyle: TextStyle(color: Colors.blue[800]),
//                        containerHeight: 300.0,
//                      ),
//                      showTitleActions: true,
//                      minTime: DateTime(2015, 1, 1),
//                      maxTime: DateTime(2025, 12, 31), onConfirm: (date) {
//                    print('confirm $date'); //todo: delete
//                    _startDate = '${date.day}/${date.month}/${date.year}  ';
//                  }, currentTime: DateTime.now(), locale: LocaleType.en);
//                },
//                child: Container(
//                  alignment: Alignment.center,
//                  height: 40.0,
//                  child: Row(
//                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                    children: <Widget>[
//                      Row(
//                        children: <Widget>[
//                          Container(
//                            child: Row(
//                              children: <Widget>[
////                                            Icon(
////                                              Icons.date_range,
////                                              size: 18.0,
////                                              color: Theme.of(context)
////                                                  .primaryColor,
////                                            ),
//                                Text(
//                                  " $_startDate",
//                                  style: TextStyle(
//                                      color: Theme.of(context).primaryColor,
//                                      fontWeight: FontWeight.bold,
//                                      fontSize: 15.0),
//                                ),
//                              ],
//                            ),
//                          )
//                        ],
//                      ),
//                    ],
//                  ),
//                ),
//                color: Colors.white,
//              ),
//            ),
              Container(
                width: deviceWidth * 0.8,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: 300.0,
                  ),
                  child: TextField(
                    maxLines: null,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      icon: Icon(Icons.description),
                    ),
                    onChanged: (String val) {
                      description = val;
                    },
                  ),
                ),
              ),
              Container(
                width: deviceWidth * 0.8,
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Price',
                    icon: Icon(Icons.attach_money),
                  ),

                  keyboardType: TextInputType.number,
//                      validator: (value) {
//                        if (value.isEmpty || !value.contains('@')) {
//                          return 'Invalid email!';
//                        } else
//                          return null; //Todo
//                      },
                  onChanged: (String val) {
                    price = val;
                  },
                ),
              ),
              Container(
                width: deviceWidth * 0.8,
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Weight',
                    icon: Icon(Icons.format_size),
                  ),

                  keyboardType: TextInputType.number,
//                      validator: (value) {
//                        if (value.isEmpty || !value.contains('@')) {
//                          return 'Invalid email!';
//                        } else
//                          return null; //Todo
//                      },
                  onChanged: (String val) {
                    weight = val;
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    // InkWell(
                    //   child: Container(
                    //     height: 100,
                    //     width: 100,
                    //     decoration: BoxDecoration(
                    //       color: Colors.white,
                    //       border: Border.all(color: Colors.grey, width: 1),
                    //     ),
                    //     child: imageFile == null
                    //         ? Icon(
                    //             Icons.add,
                    //             size: 30,
                    //             color: Colors.grey,
                    //           )
                    //         : _setImageView(),
                    //   ),
                    //   onTap: () {
                    //     _showSelectionDialog(context);
                    //   },
                    // ),
                    // InkWell(
                    //   child: Container(
                    //     height: 100,
                    //     width: 100,
                    //     decoration: BoxDecoration(
                    //       color: Colors.white,
                    //       border: Border.all(color: Colors.grey, width: 1),
                    //     ),
                    //     child: imageFile == null
                    //         ? Icon(
                    //             Icons.add,
                    //             size: 30,
                    //             color: Colors.grey,
                    //           )
                    //         : _setImageView(),
                    //   ),
                    //   onTap: () {
                    //     _showSelectionDialog(context);
                    //   },
                    // ),
                    InkWell(
                      child: Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey, width: 1),
                        ),
                        child: imageFile == null
                            ? Icon(
                                Icons.add,
                                size: 30,
                                color: Colors.grey,
                              )
                            : _setImageView(),
                      ),
                      onTap: () {
                        _showSelectionDialog(context);
                      },
                    ),
                  ],
                ),
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
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
                label: Text(
                  "Add item",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor, fontSize: 19,
//                                    color: Theme.of(context).primaryColor,
                  ),
                ),
                onPressed: () {
                  var token = widget.token;
                  const url = Api.orders;
                  http
                      .post(url,
                          headers: {
                            HttpHeaders.CONTENT_TYPE: "application/json",
                            "Authorization": "Token " + token,
                          },
                          body: json.encode({
                            "title": title,
                            "dimensions": 0,
                            "source": from,
                            "destination": to,
                            "date": DateTime.now().toString().substring(0, 10),
                            "address": "ads",
                            "weight": weight,
                            "price": price,
                            "trip": null,
                            "description": description
                          }))
                      .then((response) {
                    if (response.statusCode == 201) {
                      upload(json.decode(response.body)["id"]);

                      /// TODO ORKHAN, add this directly to the list, need to convert it to Order object..
                      Provider.of<OrdersTripsProvider>(context, listen: false)
                          .myorders = [];
                      Provider.of<OrdersTripsProvider>(context, listen: false)
                          .fetchAndSetMyOrders(token);
                      Navigator.pop(context);
                      Flushbar(
                        title: "Item added",
                        message:
                            "You can see all of your items in My Items section of Account",
                        padding: const EdgeInsets.all(8),
                        borderRadius: 10,
                        duration: Duration(seconds: 3),
                      )..show(context);
                    } else {
                      Flushbar(
                        title: "Warning",
                        message: "Item couldn't be added, try again.",
                        padding: const EdgeInsets.all(8),
                        borderRadius: 10,
                        duration: Duration(seconds: 3),
                      )..show(context);
                    }
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
