// ignore: unused_import
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:twitter/main.dart';

class AuthGate extends StatelessWidget {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey();
  const AuthGate({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        //user is logged in
        if (snapshot.hasData) {
          return ProfilePage();
        }
        //user is not logged in
        else {
          return LoginPage();
        }
      },
    ));
  }
}
