// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UserAccountPage extends StatefulWidget {
  const UserAccountPage({super.key});

  @override
  State<UserAccountPage> createState() => _UserAccountPageState();
}

class _UserAccountPageState extends State<UserAccountPage> {
  @override
  Widget build(BuildContext context) {
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
          subtitle: Text('John '),
        ),
        ListTile(
          leading:
              Icon(Icons.email_rounded, color: Theme.of(context).primaryColor),
          title: Text(
            'Email',
            style: GoogleFonts.poppins(color: Colors.grey),
          ),
          subtitle: Text('john@gmail.com '),
        ),
        ListTile(
          leading:
              Icon(Icons.phone_rounded, color: Theme.of(context).primaryColor),
          title: Text(
            'Contact',
            style: GoogleFonts.poppins(color: Colors.grey),
          ),
          subtitle: Text('0241234567'),
        )
      ],
    );
  }
}
