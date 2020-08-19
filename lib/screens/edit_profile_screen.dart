import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:optisend/models/api.dart';
import 'package:flushbar/flushbar.dart';
import 'package:optisend/widgets/progress_indicator_widget.dart';
import 'package:path/path.dart';
import 'package:async/async.dart';
import 'package:provider/provider.dart';
import 'package:optisend/providers/auth.dart';
import 'dart:convert';
import 'package:optisend/models/user.dart';

class EditProfileScreen extends StatefulWidget {
  var user;
  var auth;
  EditProfileScreen({@required this.user, @required this.auth});
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  var imageFile;
  var imageUrl;
  User user;
  bool picturePosting = false;
  void _openGallery(BuildContext context) async {
    var picture = await ImagePicker.pickImage(source: ImageSource.gallery);
    this.setState(() {
      imageFile = picture;
    });
    upload(context);
  }

  @override
  void initState() {
    user = widget.user;
    // TODO: implement initState
    super.initState();
  }

  Future upload(context) async {
    setState(() {
      picturePosting = true;
    });
    var stream = new http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
    var length = await imageFile.length();

    var uri = Uri.parse(Api.addUserImage);
    var token = Provider.of<Auth>(context, listen: false).myTokenFromStorage;
    var request = new http.MultipartRequest("PUT", uri);
    var multipartFile = new http.MultipartFile('file', stream, length, filename: basename(imageFile.path));
    request.headers['Authorization'] = "Token " + token;

    request.files.add(multipartFile);
    var response = await request.send().then((value) {
      if (value.statusCode == 201) {
        value.stream.transform(utf8.decoder).listen((value) {
          setState(() {
            picturePosting = false;
            Provider.of<Auth>(context, listen: false).changeUserAvatar(json.decode(value)["name"].toString());
            imageUrl = Api.storageBucket + json.decode(value)["name"].toString();
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      if (widget.auth.userdetail != null) {
        user = widget.auth.userdetail;
        imageUrl = widget.auth.userdetail.avatarpic == null
            ? Api.noPictureImage
            : Api.storageBucket + user.avatarpic.toString();
      }
    }
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
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
                  "Edit Profile",
                  style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                ),
                elevation: 1,
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: <Widget>[
                    Text(user.firstName + " " + user.lastName),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          "Profile Picture",
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
                        ),
                        Text(
                          "Edit",
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 20,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 45,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: NetworkImage(
                            imageUrl,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            _openGallery(context);
                          },
                          child: CircleAvatar(
                            radius: 45,
                            backgroundColor: Color.fromRGBO(190, 190, 190, 90),
                            child: Icon(
                              Icons.edit,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          "Name",
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
                        ),
                        Text(
                          "Edit",
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 20,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(color: Colors.white54),
                        child: TextField(
//                          enabled: false,
                          decoration: InputDecoration(
                              fillColor: Colors.blue,
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              contentPadding: EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                              hintText: "Name"),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          "Surname",
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
                        ),
                        Text(
                          "Edit",
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 20,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(color: Colors.white54),
                        child: TextField(
//                          enabled: false,
                          decoration: InputDecoration(
                              fillColor: Colors.blue,
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              contentPadding: EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                              hintText: "Surname"),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          "Phone number",
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
                        ),
                        Text(
                          "Edit",
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 20,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(color: Colors.white54),
                        child: TextField(
//                          enabled: false,
                          decoration: InputDecoration(
                              fillColor: Colors.blue,
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              contentPadding: EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                              hintText: "+12456787654"),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            picturePosting
                ? ProgressIndicatorWidget(show: true)
                : RaisedButton.icon(
                    icon: Icon(
                      Icons.save,
                      size: 20,
                    ),
                    label: Text(
                      'Save',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    onPressed: () {},
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15.0),
                    color: Theme.of(context).primaryColor,
                    textColor: Theme.of(context).primaryTextTheme.button.color,
                  ),
            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}
