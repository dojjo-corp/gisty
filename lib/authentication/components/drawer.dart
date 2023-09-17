import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gt_daily/authentication/pages/login.dart';
import 'package:gt_daily/global/homepage.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser!;
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              UserAccountsDrawerHeader(
                accountName: Text(
                  currentUser.displayName ?? 'user name',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                accountEmail: Text(
                  currentUser.email ?? 'user email',
                  style: GoogleFonts.poppins(),
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Navigate to project archive
                  Navigator.popAndPushNamed(context, '/add-project');
                },
                child: ListTile(
                  leading: Icon(
                    Icons.add,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: Text(
                    'Add Project',
                    style: GoogleFonts.poppins(
                        color: Theme.of(context).primaryColor),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Navigate to project archive
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MyHomePage(pageIndex: 0),
                      ));
                },
                child: ListTile(
                  leading: Icon(
                    Icons.archive_rounded,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: Text(
                    'Project Archive',
                    style: GoogleFonts.poppins(
                        color: Theme.of(context).primaryColor),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Navigate to internship page
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MyHomePage(pageIndex: 2),
                      ));
                },
                child: ListTile(
                  leading: Icon(
                    Icons.work_rounded,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: Text(
                    'View Internships Or Jobs',
                    style: GoogleFonts.poppins(
                        color: Theme.of(context).primaryColor),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Navigate to About us
                },
                child: ListTile(
                  leading: Icon(
                    Icons.info_rounded,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: Text(
                    'About Us',
                    style: GoogleFonts.poppins(
                        color: Theme.of(context).primaryColor),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Navigate to Contact page
                },
                child: ListTile(
                  leading: Icon(
                    Icons.contact_mail_rounded,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: Text(
                    'Contact Us',
                    style: GoogleFonts.poppins(
                        color: Theme.of(context).primaryColor),
                  ),
                ),
              ),
            ],
          ),
          // SIGN OUT
          GestureDetector(
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                    (route) => false);
              }
            },
            child: ListTile(
              leading: const Icon(
                Icons.logout_rounded,
                color: Colors.red,
              ),
              title: Text(
                'Logout',
                style: GoogleFonts.poppins(color: Colors.red),
              ),
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.only(bottom: 10),
          //   child: ElevatedButton(
          //     onPressed: () async {
          //       await FirebaseAuth.instance.signOut();
          //       if (FirebaseAuth.instance.currentUser == null) {
          //         // ignore: use_build_context_synchronously
          //         Navigator.pushNamed(context, '/login');
          //       }
          //     },
          //     style: ElevatedButton.styleFrom(
          //       backgroundColor: Theme.of(context).primaryColor,
          //       foregroundColor: Colors.white,
          //       minimumSize: const Size(double.infinity, 60),
          //       shape: RoundedRectangleBorder(
          //         borderRadius: BorderRadius.circular(15),
          //       ),
          //     ),
          //     child: const Text('Sign out'),
          //   ),
          // ),
        ],
      ),
    );
  }
}
