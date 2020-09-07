import 'package:flutter/material.dart';
import 'package:briddgy/localization/localization_constants.dart';
import 'package:briddgy/models/order.dart';

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:briddgy/models/api.dart';
import 'package:briddgy/providers/auth.dart';
import 'package:briddgy/providers/ordersandtrips.dart';
import 'package:flushbar/flushbar.dart';
import 'package:briddgy/screens/my_orders.dart';
import 'package:briddgy/widgets/progress_indicator_widget.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:async/async.dart';

class EditOrderScreen extends StatefulWidget {
  static const routeName = '/orders/edit_order';
  Order order;
  @override
  EditOrderScreen(this.order);
  @override
  _EditOrderScreenState createState() => _EditOrderScreenState();
}

class _EditOrderScreenState extends State<EditOrderScreen> {
  Order order;
  String title;
  String from, to, description;
  String weight, price;
  List _suggested = [];
  List _cities = [];
  bool isLoading = true;
  var imageFile1, imageFile2, imageFile3;
  List imageFiles = [];
  bool addItemButton = true;
  bool errorInImageUpload = false;
  String orderId;

  final TextEditingController _typeAheadController = TextEditingController();
  final TextEditingController _typeAheadController2 = TextEditingController();

  Future upload(id, token, orderstripsProvider, context) async {
    var stream, length, multipartFile;
    var uri = Uri.parse(Api.addOrderImage);
    var request = new http.MultipartRequest("PUT", uri);
    request.headers['Authorization'] = "Token " + token;
    request.fields["order_id"] = id.toString();
    orderId = id.toString();

    for (var i = 0; i < imageFiles.length; i++) {
      stream = new http.ByteStream(DelegatingStream.typed(imageFiles[i].openRead()));
      length = await imageFiles[i].length();
      multipartFile = new http.MultipartFile('file', stream, length, filename: basename(imageFiles[i].path));
      request.files.add(multipartFile);
    }

    await request.send().then((response) {
      if (response.statusCode == 201) {
        errorInImageUpload = false;
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
          title: "${t(context, 'success')}!",
          message: t(context, 'item_added'),
          padding: const EdgeInsets.all(8),
          borderRadius: 10,
          duration: Duration(seconds: 3),
        )..show(context);
      } else {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(t(context, 'image_couldnt_be_added')),
            content: Text(t(context, 'another_image_prompt')),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  t(context, 'no'),
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () {
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
                },
              ),
              FlatButton(
                child: Text(t(context, 'pick_another_image')),
                onPressed: () {
                  setState(() {
                    addItemButton = true;
                    imageFiles = [];
                    errorInImageUpload = true;
                  });
                  Navigator.of(ctx).pop();
                },
              )
            ],
          ),
        );
      }
    });
  }

  Future<void> _showSelectionDialog(BuildContext context, i) {
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
                        _openGallery(context, i);
                      },
                    ),
                    Divider(),
                    GestureDetector(
                      child: Text("Camera"),
                      onTap: () {
                        _openCamera(context, i);
                      },
                    )
                  ],
                ),
              ));
        });
  }

  void _openGallery(BuildContext context, i) async {
    var picture = await ImagePicker.pickImage(source: ImageSource.gallery,maxHeight: 400, maxWidth: 400);
    this.setState(() {
      if (i == 1)
        imageFile1 = picture;
      else if (i == 2)
        imageFile2 = picture;
      else
        imageFile3 = picture;
      imageFiles.add(picture);
    });
    Navigator.of(context).pop();
  }

  void _openCamera(BuildContext context, i) async {
    var picture = await ImagePicker.pickImage(source: ImageSource.camera,maxHeight: 400, maxWidth: 400);
    this.setState(() {
      if (i == 1)
        imageFile1 = picture;
      else if (i == 2)
        imageFile2 = picture;
      else
        imageFile3 = picture;
      imageFiles.add(picture);
    });
    Navigator.of(context).pop();
  }

  Widget _setImageView(image) {
    if (image != null) {
      return Image.file(
        image,
        fit: BoxFit.fitWidth,
      );
    } else {
      return Text("Please select an image");
    }
  }

  FutureOr<Iterable> getSuggestions(String pattern) async {
    String url = Api.getCities + pattern;
    await http.get(
      url,
      headers: {HttpHeaders.contentTypeHeader: "application/json"},
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
  void initState() {
    order = widget.order;
    title = order.title;
    from = order.source.cityAscii;
    to = order.destination.cityAscii;
    description = order.description;
    super.initState();
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
                    "Edit Order",
                    style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                  ),
                  elevation: 1,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    InkWell(
                      child: Container(
                        height: 80,
                        width: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey, width: .5),
                        ),
                        child: imageFile1 == null
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
                            : _setImageView(imageFile1),
                      ),
                      onTap: () {
                        _showSelectionDialog(context, 1);
                      },
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
                        child: imageFile2 == null
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
                            : _setImageView(imageFile2),
                      ),
                      onTap: () {
                        _showSelectionDialog(context, 2);
                      },
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
                        child: imageFile3 == null
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
                            : _setImageView(imageFile3),
                      ),
                      onTap: () {
                        _showSelectionDialog(context, 3);
                      },
                    ),
                  ],
                ),
              ),
              errorInImageUpload
                  ? SizedBox()
                  : Column(
                      children: [
                        Container(
                          alignment: Alignment.center,
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
                                    this._typeAheadController.text =
                                        suggestion.toString().split(", ")[0] + ", " + suggestion.toString().split(", ")[1];
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
                                    this._typeAheadController2.text =
                                        suggestion.toString().split(", ")[0] + ", " + suggestion.toString().split(", ")[1];
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
                      ],
                    ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[],
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
                            "Save Changes",
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
                          if (errorInImageUpload) {
                            setState(() {
                              addItemButton = false;
                            });
                            upload(orderId.toString(), token, orderstripsProvider, context);
                          } else {
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

//class EditProductScreen extends StatefulWidget {
//  static const routeName = '/edit-order';
//
//  @override
//  _EditProductScreenState createState() => _EditProductScreenState();
//}

//class _EditProductScreenState extends State<EditProductScreen> {
//  final _priceFocusNode = FocusNode();
//  final _descriptionFocusNode = FocusNode();
//  final _imageUrlController = TextEditingController();
//  final _imageUrlFocusNode = FocusNode();
//  final _form = GlobalKey<FormState>();
//  var _editedProduct = Order(
//    id: null,
//    title: '',
//    price: 0,
//    description: '',
////    imageUrl: '',
//  );
//  var _initValues = {
//    'title': '',
//    'description': '',
//    'price': '',
//    'imageUrl': '',
//  };
//  var _isInit = true;
//  var _isLoading = false;
//
//  @override
//  void initState() {
//    _imageUrlFocusNode.addListener(_updateImageUrl);
//    super.initState();
//  }
//
//  @override
//  void didChangeDependencies() {
//    if (_isInit) {
//      final productId = ModalRoute.of(context).settings.arguments as String;
//      if (productId != null) {
////        _editedProduct = Provider.of<Products>(context, listen: false).findById(productId);
//        _initValues = {
//          'title': _editedProduct.title,
//          'description': _editedProduct.description,
//          'price': _editedProduct.price.toString(),
//          // 'imageUrl': _editedProduct.imageUrl,
//          'imageUrl': '',
//        };
////        _imageUrlController.text = _editedProduct.imageUrl;
//      }
//    }
//    _isInit = false;
//    super.didChangeDependencies();
//  }
//
//  @override
//  void dispose() {
//    _imageUrlFocusNode.removeListener(_updateImageUrl);
//    _priceFocusNode.dispose();
//    _descriptionFocusNode.dispose();
//    _imageUrlController.dispose();
//    _imageUrlFocusNode.dispose();
//    super.dispose();
//  }
//
//  void _updateImageUrl() {
//    if (!_imageUrlFocusNode.hasFocus) {
//      if ((!_imageUrlController.text.startsWith('http') && !_imageUrlController.text.startsWith('https')) ||
//          (!_imageUrlController.text.endsWith('.png') && !_imageUrlController.text.endsWith('.jpg') && !_imageUrlController.text.endsWith('.jpeg'))) {
//        return;
//      }
//      setState(() {});
//    }
//  }
//
//  Future<void> _saveForm() async {
//    final isValid = _form.currentState.validate();
//    if (!isValid) {
//      return;
//    }
//    _form.currentState.save();
//    setState(() {
//      _isLoading = true;
//    });
//    if (_editedProduct.id != null) {
////      await Provider.of<Products>(context, listen: false).updateProduct(_editedProduct.id, _editedProduct);
//    } else {
//      try {
////        await Provider.of<Products>(context, listen: false).addProduct(_editedProduct);
//      } catch (error) {
//        await showDialog(
//          context: context,
//          builder: (ctx) => AlertDialog(
//            title: Text('An error occurred!'),
//            content: Text('Something went wrong.'),
//            actions: <Widget>[
//              FlatButton(
//                child: Text('Okay'),
//                onPressed: () {
//                  Navigator.of(ctx).pop();
//                },
//              )
//            ],
//          ),
//        );
//      }
//      // finally {
//      //   setState(() {
//      //     _isLoading = false;
//      //   });
//      //   Navigator.of(context).pop();
//      // }
//    }
//    setState(() {
//      _isLoading = false;
//    });
//    Navigator.of(context).pop();
//    // Navigator.of(context).pop();
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//      appBar: AppBar(
//        title: Text('Edit Product'),
//        actions: <Widget>[
//          IconButton(
//            icon: Icon(Icons.save),
//            onPressed: _saveForm,
//          ),
//        ],
//      ),
//      body: _isLoading
//          ? Center(
//              child: CircularProgressIndicator(),
//            )
//          : Padding(
//              padding: const EdgeInsets.all(16.0),
//              child: Form(
//                key: _form,
//                child: ListView(
//                  children: <Widget>[
//                    TextFormField(
//                      initialValue: _initValues['title'],
//                      decoration: InputDecoration(labelText: 'Title'),
//                      textInputAction: TextInputAction.next,
//                      onFieldSubmitted: (_) {
//                        FocusScope.of(context).requestFocus(_priceFocusNode);
//                      },
//                      validator: (value) {
//                        if (value.isEmpty) {
//                          return 'Please provide a value.';
//                        }
//                        return null;
//                      },
//                      onSaved: (value) {
////                        _editedProduct = Product(
////                            title: value,
////                            price: _editedProduct.price,
////                            description: _editedProduct.description,
////                            imageUrl: _editedProduct.imageUrl,
////                            id: _editedProduct.id,
////                            isFavorite: _editedProduct.isFavorite);
//                      },
//                    ),
//                    TextFormField(
//                      initialValue: _initValues['price'],
//                      decoration: InputDecoration(labelText: 'Price'),
//                      textInputAction: TextInputAction.next,
//                      keyboardType: TextInputType.number,
//                      focusNode: _priceFocusNode,
//                      onFieldSubmitted: (_) {
//                        FocusScope.of(context).requestFocus(_descriptionFocusNode);
//                      },
//                      validator: (value) {
//                        if (value.isEmpty) {
//                          return 'Please enter a price.';
//                        }
//                        if (double.tryParse(value) == null) {
//                          return 'Please enter a valid number.';
//                        }
//                        if (double.parse(value) <= 0) {
//                          return 'Please enter a number greater than zero.';
//                        }
//                        return null;
//                      },
//                      onSaved: (value) {
////                        _editedProduct = Product(
////                            title: _editedProduct.title,
////                            price: double.parse(value),
////                            description: _editedProduct.description,
////                            imageUrl: _editedProduct.imageUrl,
////                            id: _editedProduct.id,
////                            isFavorite: _editedProduct.isFavorite);
//                      },
//                    ),
//                    TextFormField(
//                      initialValue: _initValues['description'],
//                      decoration: InputDecoration(labelText: 'Description'),
//                      maxLines: 3,
//                      keyboardType: TextInputType.multiline,
//                      focusNode: _descriptionFocusNode,
//                      validator: (value) {
//                        if (value.isEmpty) {
//                          return 'Please enter a description.';
//                        }
//                        if (value.length < 10) {
//                          return 'Should be at least 10 characters long.';
//                        }
//                        return null;
//                      },
//                      onSaved: (value) {
////                        _editedProduct = Product(
////                          title: _editedProduct.title,
////                          price: _editedProduct.price,
////                          description: value,
////                          imageUrl: _editedProduct.imageUrl,
////                          id: _editedProduct.id,
////                          isFavorite: _editedProduct.isFavorite,
////                        );
//                      },
//                    ),
//                    Row(
//                      crossAxisAlignment: CrossAxisAlignment.end,
//                      children: <Widget>[
//                        Container(
//                          width: 100,
//                          height: 100,
//                          margin: EdgeInsets.only(
//                            top: 8,
//                            right: 10,
//                          ),
//                          decoration: BoxDecoration(
//                            border: Border.all(
//                              width: 1,
//                              color: Colors.grey,
//                            ),
//                          ),
//                          child: _imageUrlController.text.isEmpty
//                              ? Text('Enter a URL')
//                              : FittedBox(
//                                  child: Image.network(
//                                    _imageUrlController.text,
//                                    fit: BoxFit.cover,
//                                  ),
//                                ),
//                        ),
//                        Expanded(
//                          child: TextFormField(
//                            decoration: InputDecoration(labelText: 'Image URL'),
//                            keyboardType: TextInputType.url,
//                            textInputAction: TextInputAction.done,
//                            controller: _imageUrlController,
//                            focusNode: _imageUrlFocusNode,
//                            onFieldSubmitted: (_) {
//                              _saveForm();
//                            },
//                            validator: (value) {
//                              if (value.isEmpty) {
//                                return 'Please enter an image URL.';
//                              }
//                              if (!value.startsWith('http') && !value.startsWith('https')) {
//                                return 'Please enter a valid URL.';
//                              }
//                              if (!value.endsWith('.png') && !value.endsWith('.jpg') && !value.endsWith('.jpeg')) {
//                                return 'Please enter a valid image URL.';
//                              }
//                              return null;
//                            },
//                            onSaved: (value) {
////                              _editedProduct = Product(
////                                title: _editedProduct.title,
////                                price: _editedProduct.price,
////                                description: _editedProduct.description,
////                                imageUrl: value,
////                                id: _editedProduct.id,
////                                isFavorite: _editedProduct.isFavorite,
////                              );
//                            },
//                          ),
//                        ),
//                      ],
//                    ),
//                  ],
//                ),
//              ),
//            ),
//    );
//  }
//}
