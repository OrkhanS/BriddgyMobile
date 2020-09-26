// import 'dart:io';
// import 'package:flushbar/flushbar.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:google_sign_in/google_sign_in.dart';
//
//
// GoogleSignIn _googleSignIn = GoogleSignIn(
//   scopes:  <String> ['profile', 'email'],
// );
//
//
// class GoogleAuth extends StatefulWidget {
//   @override
//   _GoogleAuthState createState() => _GoogleAuthState();
// }
//
//
// class _GoogleAuthState extends State<GoogleAuth> {
//   GoogleSignInAccount _currentUser;
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account){
//       setState(() {
//         _currentUser = account;
//       });
//     });
//     _googleSignIn.signInSilently();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold();
//   }
// }
