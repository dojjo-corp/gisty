// ignore_for_file: prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gt_daily/authentication/components/buttons.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';

class UserAccountPage extends StatefulWidget {
  const UserAccountPage({super.key});

  @override
  State<UserAccountPage> createState() => _UserAccountPageState();
}

class _UserAccountPageState extends State<UserAccountPage> {
  final currentUser = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    final allUsers = Provider.of<UserProvider>(context, listen: false).allUsers;
    Map<String, dynamic> currentUserMap = {};
    for (var user in allUsers) {
      if (user['email'] == currentUser.email) {
        currentUserMap = user;
      }
    }

    return Column(
      children: [
        Icon(
          Icons.person,
          size: 100,
          color: Theme.of(context).primaryColor,
        ),
        const SizedBox(height: 20),
        ListTile(
          leading:
              Icon(Icons.person_rounded, color: Theme.of(context).primaryColor),
          title: Text(
            'Name',
            style: GoogleFonts.poppins(color: Colors.grey),
          ),
          subtitle: Text(currentUserMap['fullname']),
        ),
        ListTile(
          leading:
              Icon(Icons.email_rounded, color: Theme.of(context).primaryColor),
          title: Text(
            'Email',
            style: GoogleFonts.poppins(color: Colors.grey),
          ),
          subtitle: Text(currentUserMap['email']),
        ),
        ListTile(
          leading:
              Icon(Icons.phone_rounded, color: Theme.of(context).primaryColor),
          title: Text(
            'Contact',
            style: GoogleFonts.poppins(color: Colors.grey),
          ),
          subtitle: Text(currentUserMap['contact']),
        ),
        const SizedBox(height: 20),
        MyButton(
          onPressed: () {
            Navigator.pushNamed(context, '/edit-profile');
          },
          btnText: 'Edit Profile',
          isPrimary: true,
        ),
        const SizedBox(height: 10),
        MyButton(
          onPressed: () {
            Navigator.pushNamed(context, '/reset-password');
          },
          btnText: 'Reset Password',
          isPrimary: false,
        )
      ],
    );
  }
}
