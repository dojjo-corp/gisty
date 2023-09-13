import 'package:flutter/material.dart';
import 'package:gt_daily/authentication/pages/login.dart';

import '../../global/homepage.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(builder: (context, snapshot) {
      if (!snapshot.hasData){
        return const LoginPage();
      }
      return const MyHomePage(title: '',);
    },);
  }
}