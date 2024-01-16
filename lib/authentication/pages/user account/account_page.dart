// ignore_for_file: prefer_const_constructors

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gt_daily/authentication/helper_methods.dart/global.dart';
import 'package:gt_daily/authentication/pages/user%20account/view_profile_picture.dart';
import 'package:provider/provider.dart';

import '../../components/buttons/buttons.dart';
import '../../helper_methods.dart/profile.dart';
import '../../providers/connectivity_provider.dart';

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
    final connectivity = Provider.of<ConnectivityProvider>(context);

    return StreamBuilder(
      stream: getThrottledStream(
        collectionPath: 'users',
        docPath: auth.currentUser!.uid,
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.hasError) {
          return Column(
            children: [
              Icon(
                Icons.person,
                size: 100,
                color: Theme.of(context).primaryColor,
              ),
              ListTile(
                leading: Icon(Icons.person_rounded,
                    color: Theme.of(context).primaryColor),
                title: Text(
                  'Name',
                  style: GoogleFonts.poppins(color: Colors.grey),
                ),
                 subtitle: Text(
                    'Loading...',
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
                    'Loading...',
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
                    'Loading...',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
              ),
              ListTile(
                leading: Icon(Icons.school_rounded,
                    color: Theme.of(context).primaryColor),
                title: Text(
                  'Faculty',
                  style: GoogleFonts.poppins(color: Colors.grey),
                ),
                subtitle: Text(
                    'Loading...',
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
                    'Loading...',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
              ),
            ],
          );
        }

        // TODO Upon loading successfully
        final currentUserMap = snapshot.data!.data();
        final role = currentUserMap['user-type'].toLowerCase();
        final profilePicture = currentUserMap?['profile-picture'];
        bool _showFaculty = role == 'student' || role == 'university professional';

        /// The Widget to display as user's profile Image (depending on device's connectivity state)
        Widget profileWidget;
        if (connectivity.connectivityResult == ConnectivityResult.none ||
            profilePicture == null) {
          profileWidget = showNoProfilePicture(context);
        } else {
          profileWidget = showProfilePicture(profilePicture, context);
        }

        return SizedBox(
          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            ViewProfilePicture(uid: currentUser.uid)));
                  },
                  child: profileWidget,
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
                _showFaculty ?
                ListTile(
                  leading: Icon(Icons.school_rounded,
                      color: Theme.of(context).primaryColor),
                  title: Text(
                    'Faculty',
                    style: GoogleFonts.poppins(color: Colors.grey),
                  ),
                  subtitle: Text(
                    currentUserMap?['faculty'] ?? 'Faculty',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ) : Container(),
                  
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: MyButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/edit-profile');
                        },
                        btnText: 'Edit Profile',
                        isPrimary: true,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: MyButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/reset-password');
                        },
                        btnText: 'Reset Password',
                        isPrimary: false,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    showDeletePromptDialog(
                      context: context,
                      uid: currentUser.uid,
                      email: currentUser.email!,
                    );
                  },
                  child: Text(
                    'Delete Account',
                    style: GoogleFonts.poppins(color: Colors.red),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
