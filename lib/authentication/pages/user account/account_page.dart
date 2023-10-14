// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gt_daily/authentication/pages/user%20account/view_profile_picture.dart';

import '../../components/buttons.dart';
import '../../helper_methods.dart/profile.dart';

class UserAccountPage extends StatefulWidget {
  const UserAccountPage({super.key});

  @override
  State<UserAccountPage> createState() => _UserAccountPageState();
}

class _UserAccountPageState extends State<UserAccountPage> {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final currentUser = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    final auth = FirebaseAuth.instance;
    final store = FirebaseFirestore.instance;

    return StreamBuilder(
        stream:
            store.collection('users').doc(auth.currentUser!.uid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData ||
              snapshot.connectionState == ConnectionState.waiting) {
            return Icon(
              Icons.person,
              size: 100,
              color: Theme.of(context).primaryColor,
            );
          }
          final currentUserMap = snapshot.data!.data();
          final profilePicture = currentUserMap?['profile-picture'];
          return Column(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          ViewProfilePicture(profilePicture: profilePicture)));
                },
                child: profilePicture != null
                    ? showProfilePicture(profilePicture, context)
                    : showNoProfilePicture(context),
              ),
              // const SizedBox(height: 20),
              ListTile(
                leading: Icon(Icons.person_rounded,
                    color: Theme.of(context).primaryColor),
                title: Text(
                  'Name',
                  style: GoogleFonts.poppins(color: Colors.grey),
                ),
                subtitle: Text(
                  currentUserMap?['fullname'] ?? 'Fullname',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              ListTile(
                leading: Icon(Icons.email_rounded,
                    color: Theme.of(context).primaryColor),
                title: Text(
                  'Email',
                  style: GoogleFonts.poppins(color: Colors.grey),
                ),
                subtitle: Text(
                  currentUserMap?['email'] ?? 'Email',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              ListTile(
                leading: Icon(Icons.phone_rounded,
                    color: Theme.of(context).primaryColor),
                title: Text(
                  'Contact',
                  style: GoogleFonts.poppins(color: Colors.grey),
                ),
                subtitle: Text(
                  currentUserMap?['contact'] ?? 'Contact',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              ListTile(
                leading: Icon(Icons.work_rounded,
                    color: Theme.of(context).primaryColor),
                title: Text(
                  'Role',
                  style: GoogleFonts.poppins(color: Colors.grey),
                ),
                subtitle: Text(
                  currentUserMap?['user-type'] ?? 'Role',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
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
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  showDeletePromptDialog(context);
                },
                child: Text(
                  'Delete Account',
                  style: GoogleFonts.poppins(color: Colors.red),
                ),
              ),
            ],
          );
        });
  }
}
