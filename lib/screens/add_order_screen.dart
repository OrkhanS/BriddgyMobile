import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:optisend/models/api.dart';
import 'package:optisend/providers/auth.dart';
import 'package:optisend/providers/ordersandtrips.dart';
import 'package:flushbar/flushbar.dart';
import 'package:optisend/screens/my_items.dart';
import 'package:optisend/widgets/progress_indicator_widget.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:async/async.dart';

class AddItemScreen extends StatefulWidget {
  static const routeName = '/orders/add_item';
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
  bool addItemButton = true;

  final TextEditingController _typeAheadController = TextEditingController();
  final TextEditingController _typeAheadController2 = TextEditingController();

  Future upload(id, token, orderstripsProvider, context) async {
    var stream = new http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
    var length = await imageFile.length();

    var uri = Uri.parse(Api.addOrderImage);

    var request = new http.MultipartRequest("PUT", uri);
    var multipartFile = new http.MultipartFile('file', stream, length, filename: basename(imageFile.path));
    request.headers['Authorization'] = "Token " + token;
    request.fields["order_id"] = id.toString();

    request.files.add(multipartFile);
    var response = await request.send().whenComplete(() {
      orderstripsProvider.myorders = [];
      orderstripsProvider.isLoadingMyOrders = true;
      Navigator.pop(context);
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (__) => MyItems(
              token: token,
              orderstripsProvider: orderstripsProvider,
            ),
          ));
      Flushbar(
        title: "Success!",
        message: "Item added.",
        padding: const EdgeInsets.all(8),
        borderRadius: 10,
        duration: Duration(seconds: 3),
      )..show(context);
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
      _cities.add(_suggested[i]["city_ascii"].toString() + ", " + _suggested[i]["country"].toString() + ", " + _suggested[i]["id"].toString());
    }
    return _cities;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.white10,
      statusBarIconBrightness: Brightness.dark,
    ));
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
                    "Add Item",
                    style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                  ),
                  elevation: 1,
                ),
              ),
//              Padding(
//                padding: const EdgeInsets.only(left: 20, top: 10, bottom: 10),
//                child: Text(
//                  "Item Details",
////                  textAlign: TextAlign.center,
//                  style: TextStyle(fontSize: 25, color: Theme.of(context).primaryColor),
//                ),
//              ),
              SizedBox(
                height: 20,
              ),
              InkWell(
                child: Container(
                  height: 80,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey, width: .5),
                  ),
                  child: imageFile == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add,
                              size: 30,
                              color: Colors.grey,
                            ),
                            Text(
                              "Add image",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        )
                      : _setImageView(),
                ),
                onTap: () {
                  _showSelectionDialog(context);
                },
              ),
              Container(
//              alignment: Alignment.center,
                width: deviceWidth * 0.8,
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Title',
                    icon: Icon(MdiIcons.bagCarryOn),
                  ),
                  onChanged: (String val) {
                    title = val;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Row(
                  children: [
                    Container(
                      width: deviceWidth * 0.4,
                      child: TypeAheadFormField(
                        keepSuggestionsOnLoading: false,
                        debounceDuration: const Duration(milliseconds: 200),
                        textFieldConfiguration: TextFieldConfiguration(
                          onSubmitted: (val) {
                            from = val;
                          },
                          controller: this._typeAheadController,
                          decoration: InputDecoration(labelText: 'From', icon: Icon(MdiIcons.bridge)),
                        ),
                        suggestionsCallback: (pattern) {
                          return getSuggestions(pattern);
                        },
                        itemBuilder: (context, suggestion) {
                          return ListTile(
                            title: Text(suggestion.toString().split(", ")[0] + ", " + suggestion.toString().split(", ")[1]),
                          );
                        },
                        transitionBuilder: (context, suggestionsBox, controller) {
                          return suggestionsBox;
                        },
                        onSuggestionSelected: (suggestion) {
                          this._typeAheadController.text = suggestion.toString().split(", ")[0] + ", " + suggestion.toString().split(", ")[1];
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
                      width: deviceWidth * 0.4,
                      child: TypeAheadFormField(
                        keepSuggestionsOnLoading: false,
                        debounceDuration: const Duration(milliseconds: 200),
                        textFieldConfiguration: TextFieldConfiguration(
                          onSubmitted: (val) {
                            to = val;
                          },
                          controller: this._typeAheadController2,
                          decoration: InputDecoration(labelText: 'To', icon: Icon(MdiIcons.mapMarkerMultipleOutline)),
                        ),
                        suggestionsCallback: (pattern) {
                          return getSuggestions(pattern);
                        },
                        itemBuilder: (context, suggestion) {
                          return ListTile(
                            title: Text(suggestion.toString().split(", ")[0] + ", " + suggestion.toString().split(", ")[1]),
                          );
                        },
                        transitionBuilder: (context, suggestionsBox, controller) {
                          return suggestionsBox;
                        },
                        onSuggestionSelected: (suggestion) {
                          this._typeAheadController2.text = suggestion.toString().split(", ")[0] + ", " + suggestion.toString().split(", ")[1];
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
                  ],
                ),
              ),
              Container(
                width: deviceWidth * 0.8,
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Reward (in USD)',
                    icon: Icon(Icons.attach_money),
                  ),
                  keyboardType: TextInputType.number,
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
                    icon: Icon(MdiIcons.weightKilogram),
                  ),
                  maxLength: 4,
                  keyboardType: TextInputType.number,
                  onChanged: (String val) {
                    weight = val;
                  },
                ),
              ),
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
                      icon: Icon(MdiIcons.informationOutline),
                    ),
                    onChanged: (String val) {
                      description = val;
                    },
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                  ],
                ),
              ),
              addItemButton
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 60),
                      child: RaisedButton(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        color: Colors.green,
//                      elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        ),
                        child: Container(
                          width: double.infinity,
                          child: Text(
                            "Add Order",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                              fontSize: 19,
                            ),
                          ),
                        ),
                        onPressed: () {
                          var token = Provider.of<Auth>(context, listen: false).token;
                          var orderstripsProvider = Provider.of<OrdersTripsProvider>(context, listen: false);
                          String url = Api.orders;
                          if (title == null || from == null || to == null || weight == null || price == null) {
                            setState(() {
                              addItemButton = true;
                            });
                            Flushbar(
                              title: "Warning!",
                              message: "Fill all the fields and try again.",
                              padding: const EdgeInsets.all(8),
                              margin: const EdgeInsets.all(20),
                              borderRadius: 10,
                              duration: Duration(seconds: 3),
                            )..show(context);
                          } else {
                            setState(() {
                              addItemButton = false;
                            });
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
                              Map data = json.decode(response.body);
                              if (response.statusCode == 201) {
                                upload(data["id"].toString(), token, orderstripsProvider, context);
                              } else {
                                setState(() {
                                  addItemButton = true;
                                });
                                Flushbar(
                                  title: "Warning!",
                                  message: "Item couldn't be added, try again.",
                                  padding: const EdgeInsets.all(8),
                                  borderRadius: 10,
                                  duration: Duration(seconds: 3),
                                )..show(context);
                              }
                            });
                          }
                        },
                      ),
                    )
                  : ProgressIndicatorWidget(show: true),
            ],
          ),
        ),
      ),
    );
  }
}
