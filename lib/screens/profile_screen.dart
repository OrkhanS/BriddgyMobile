import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './auth_screen.dart';
import '../providers/auth.dart';
import 'splash_screen.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var auth = Provider.of<Auth>(context, listen: false);
    return Scaffold(
      body: auth.isAuth
          ? Column(children: [
              Center(
                child: Text("Profile"),
              ),
              ListTile(
                leading: Icon(Icons.exit_to_app),
                title: Text('Logout'),
                onTap: () {
                  Navigator.of(context).pushReplacementNamed('/orders');

                  // Navigator.of(context)
                  //     .pushReplacementNamed(UserProductsScreen.routeName);
                  Provider.of<Auth>(context, listen: false).logout();
                },
              ),
            ])
          : FutureBuilder(
              future: auth.tryAutoLogin(),
              builder: (ctx, authResultSnapshot) =>
                  authResultSnapshot.connectionState == ConnectionState.waiting
                      ? SplashScreen()
                      : AuthScreen(),
            ),
//
    );
  }
}
