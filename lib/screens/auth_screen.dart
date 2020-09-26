import 'package:briddgy/screens/web_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:briddgy/localization/localization_constants.dart';
import 'package:briddgy/screens/forgotPassword_screen.dart';
import 'package:briddgy/screens/verify_email_screen.dart';
import 'package:provider/provider.dart';
import '../providers/auth.dart';
import '../models/http_exception.dart';
// import 'package:google_sign_in/google_sign_in.dart';

//import 'package:flutter_facebook_login/flutter_facebook_login.dart';

import 'FirebaseMessaging.dart';

// GoogleSignIn _googleSignIn = GoogleSignIn(
//   scopes: <String>['profile', 'email'],
// );
// GoogleSignInAccount _currentUser;

enum AuthMode { Signup, Login }

//class AuthScreen extends StatelessWidget {
//  static const routeName = '/auth';
//
//  @override
//  Widget build(BuildContext context) {
//    final deviceSize = MediaQuery.of(context).size;
//    return Scaffold(
//      body: SingleChildScrollView(
//        child: Container(
//          height: deviceSize.height * .88,
//          margin: MediaQuery.of(context).padding,
//          width: deviceSize.width,
//          child: AuthCard(),
//        ),
//      ),
//    );
//  }
//}

class AuthScreen extends StatefulWidget {
  static const routeName = '/auth';
  const AuthScreen({
    Key key,
  }) : super(key: key);

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Login;
  Map<String, String> _authData = {
    'email': '',
    'password': '',
  };
  var _isLoading = false;
  final _passwordController = TextEditingController();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  String deviceToken;

  bool _obscureText1 = true;
  bool _obscureText2 = true;

  final FocusNode _emailFocus = FocusNode();
  final FocusNode _firstNameFocus = FocusNode();
  final FocusNode _lastNameFocus = FocusNode();
  final FocusNode _pass1Focus = FocusNode();
  final FocusNode _pass2Focus = FocusNode();

  @override
  void initState() {
    _getToken();

    // TODO: implement initState
    super.initState();
    // _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
    //   setState(() {
    //     _currentUser = account;
    //   });
    // });
    // _googleSignIn.signInSilently();
  }

  _getToken() async{
    deviceToken = await _firebaseMessaging.getToken();
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t(context, 'error_occurred')),
        content: Text(message),
        actions: <Widget>[
          FlatButton(
            child: Text(t(context, 'okay')),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });
    try {
      if (_authMode == AuthMode.Login) {
        // Log user in
        await Provider.of<Auth>(context, listen: false).login(_authData['email'], _authData['password'], deviceToken, context);
      } else {
        // Sign user up
        await Provider.of<Auth>(context, listen: false)
            .signup(_authData['email'], _authData['password'], _authData['firstname'], _authData['lastname'], deviceToken);
      }
    } on HttpException catch (error) {
      var errorMessage = 'Authentication failed';
      if (error.toString().contains('EMAIL_EXISTS')) {
        errorMessage = 'This email address is already in use.';
      } else if (error.toString().contains('INVALID_EMAIL')) {
        errorMessage = 'This is not a valid email address';
      } else if (error.toString().contains('WEAK_PASSWORD')) {
        errorMessage = 'This password is too weak.';
      } else if (error.toString().contains('EMAIL_NOT_FOUND')) {
        errorMessage = 'Could not find a user with that email.';
      } else if (error.toString().contains('INVALID_PASSWORD')) {
        errorMessage = 'Invalid password.';
      }
      _showErrorDialog(errorMessage);
    } catch (error) {
      const errorMessage = 'Could not authenticate you. Please try again later.';
      _showErrorDialog(errorMessage);
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.Signup;
      });
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
    }
  }

  void _toggle1() {
    setState(() {
      _obscureText1 = !_obscureText1;
    });
  }

  void _toggle2() {
    setState(() {
      _obscureText2 = !_obscureText2;
    });
  }

  _fieldFocusChange(BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        height: deviceSize.height,
        alignment: Alignment.center,
        margin: EdgeInsets.only(top: 20),
//        height: deviceSize.height * 0.88,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    _authMode == AuthMode.Login ? t(context, 'login') : t(context, 'sign_up'),
                    style: TextStyle(
                      fontSize: 30,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
//                    color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  TextFormField(
                    focusNode: _emailFocus,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (term) {
                      _fieldFocusChange(context, _emailFocus, (_authMode == AuthMode.Signup) ? _firstNameFocus : _pass1Focus);
                    },
                    decoration: InputDecoration(
                      labelText: t(context, 'email'),
                      icon: Icon(Icons.alternate_email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value.isEmpty || !value.contains('@')) {
                        return t(context, 'invalid_email');
                      } else
                        return null;
                    },
                    onSaved: (value) {
                      _authData['email'] = value;
                    },
                  ),
                  if (_authMode == AuthMode.Signup) ...[
                    TextFormField(
                      focusNode: _firstNameFocus,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (term) {
                        _fieldFocusChange(context, _firstNameFocus, _lastNameFocus);
                      },
                      enabled: _authMode == AuthMode.Signup,
                      decoration: InputDecoration(
                        labelText: t(context, 'name'),
                        icon: Icon(Icons.person_outline),
                      ),
                      //validator: _authMode == AuthMode.Signup ? (value) {} : null,
                      onSaved: (value) {
                        _authData['firstname'] = value;
                      },
                    ),
                    TextFormField(
                      focusNode: _lastNameFocus,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (term) {
                        _fieldFocusChange(context, _lastNameFocus, _pass1Focus);
                      },
                      enabled: _authMode == AuthMode.Signup,
                      decoration: InputDecoration(
                        labelText: t(context, 'last_name'),
                        icon: Icon(MdiIcons.accountTie),
                      ),
                      //validator: _authMode == AuthMode.Signup ? (value) {} : null,
                      onSaved: (value) {
                        _authData['lastname'] = value;
                      },
                    ),
                  ],
                  TextFormField(
                    focusNode: _pass1Focus,
                    textInputAction: (_authMode == AuthMode.Signup) ? TextInputAction.next : TextInputAction.done,
                    onFieldSubmitted: (term) {
                      if (_authMode == AuthMode.Signup) {
                        _fieldFocusChange(context, _pass1Focus, _pass2Focus);
                      } else {
                        _pass1Focus.unfocus();
                        _submit();
                      }
                    },
                    decoration: InputDecoration(
                      labelText: t(context, 'password'),
                      icon: Icon(Icons.vpn_key),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureText1 ? Icons.visibility_off : Icons.visibility),
                        onPressed: _toggle1,
                      ),
                    ),
                    obscureText: _obscureText1,
                    controller: _passwordController,
                    validator: (value) {
                      if (value.isEmpty || value.length < 5) {
                        return t(context, 'short_password_error');
                      } else
                        return null;
                    },
                    onSaved: (value) {
                      _authData['password'] = value;
                    },
                  ),
                  if (_authMode == AuthMode.Signup)
                    TextFormField(
                      focusNode: _pass2Focus,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (term) {
                        _pass2Focus.unfocus();
                        _submit();
                      },
                      enabled: _authMode == AuthMode.Signup,
                      decoration: InputDecoration(
                        labelText: t(context, 'repeat_password'),
                        icon: Icon(Icons.repeat),
                        suffixIcon: IconButton(
                          icon: Icon(_obscureText2 ? Icons.visibility_off : Icons.visibility),
                          onPressed: _toggle2,
                        ),
                      ),
                      obscureText: _obscureText2,
                      validator: _authMode == AuthMode.Signup
                          ? (value) {
                              if (value != _passwordController.text) {
                                return t(context, 'passwords_dont_match');
                              } else
                                return null;
                            }
                          : null,
                    ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
//                Expanded(
//                  child: new Container(
//                      margin: const EdgeInsets.only(left: 10.0, right: 20.0),
//                      child: Divider(
//                        color: Colors.black,
//                        height: 36,
//                      )),
//                ),
//                  Text(
//                    "Or",
//                    style: TextStyle(color: Colors.grey[500], fontSize: 20),
//                  ),
//                Expanded(
//                  child: new Container(
//                      margin: const EdgeInsets.only(left: 20.0, right: 10.0),
//                      child: Divider(
//                        color: Colors.black,
//                        height: 36,
//                      )),
//                ),
                  ]),
//                SizedBox(
//                  height: 10,
//                ),
//                Row(
//                  mainAxisSize: MainAxisSize.max,
//                  mainAxisAlignment: MainAxisAlignment.center,
//                  children: <Widget>[
//                    _facebook(),
//                    SizedBox(
//                      width: 15,
//                    ),
//                    _google(),
//                  ],
//                ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      if (_isLoading)
                        CircularProgressIndicator()
                      else
                        RaisedButton(
                          child: Text(
                            _authMode == AuthMode.Login ? t(context, 'login') : t(context, 'sign_up'),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          onPressed: () {
                            _submit();
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: deviceSize.width * 0.3, vertical: 15.0),
                          color: Theme.of(context).primaryColor,
                          textColor: Theme.of(context).primaryTextTheme.button.color,
                        ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        _authMode == AuthMode.Login ? t(context, 'dont_have_an_acc') : t(context, 'already_member'),
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      InkWell(
                        child: Text(
                          '${_authMode == AuthMode.Login ? ' ${t(context, 'sign_up')}' : ' ${t(context, 'login')}'} ',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).accentColor),
                        ),
                        onTap: () {
                          FocusScope.of(context).unfocus();
                          _switchAuthMode();
                        },
                      ),
                    ],
                  ),
                  InkWell(
                    child: Text(
                      '${t(context, 'forgot')} ?',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).accentColor),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (__) => ForgotPasswordScreen()),
                      );
                    },
                  ),
                  if (_authMode == AuthMode.Signup)
                    SizedBox(
                      height: 20,
                    ),
                  if (_authMode == AuthMode.Signup)
                    Column(
                      children: <Widget>[
                        Center(
                          child: Container(
                            width: deviceSize.width * 0.6,
                            child: Text(
                              t(context, 'by_creating'),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[500],
                              ),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            InkWell(
                              child: Text(
                                ' ${t(context, 'privacy')} ',
                                style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).accentColor, fontSize: 13),
                              ),
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (__) => WebScreen(
                                        title: t(context, "privacy"),
                                        url: 'https://briddgy.com/privacy',
                                      ),
                                    ));
                              },
                            ),
                            Text(
                              t(context, 'and'),
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[500],
                              ),
                            ),
                            InkWell(
                              child: Text(
                                ' ${t(context, 'terms')} ',
                                style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).accentColor, fontSize: 13),
                              ),
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (__) => WebScreen(
                                        title: t(context, "terms"),
                                        url: 'https://briddgy.com/terms',
                                      ),
                                    ));
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  SizedBox(
                    height: 30,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget _google() {
  Future<void> googleSignIN() async {
    try {
      // await _googleSignIn.signIn();
    } catch (error) {
      print(error);
    }
  }

  return OutlineButton(
    splashColor: Colors.grey,
    onPressed: () {},
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    highlightElevation: 0,
    borderSide: BorderSide(color: Colors.grey),
    child: Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image(image: AssetImage("assets/photos/google_logo.png"), height: 25.0),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Text(
              'Google',
              style: TextStyle(
                fontSize: 20,
                color: Colors.grey,
              ),
            ),
          )
        ],
      ),
    ),
  );
}

Widget _facebook() {
  return OutlineButton(
    splashColor: Colors.grey,
    onPressed: () {},
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    highlightElevation: 0,
    borderSide: BorderSide(color: Colors.grey),
    child: Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image(image: AssetImage("assets/photos/facebook_logo.png"), height: 25.0),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Text(
              'Facebook',
              style: TextStyle(
                fontSize: 20,
                color: Colors.grey,
              ),
            ),
          )
        ],
      ),
    ),
  );
}
