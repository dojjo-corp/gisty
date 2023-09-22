import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gt_daily/authentication/pages/user%20authentication/login.dart';

import '../../global/homepage.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
      if (!snapshot.hasData){
        return const LoginPage();
      }
      return MyHomePage(pageIndex: 0,);
    },);
  }
}