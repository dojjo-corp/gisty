import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../global/homepage.dart';
import '../pages/analytics/project_analysis.dart';
import '../pages/messaging/chat_list_page.dart';
import '../pages/projects/project_archive.dart';
import '../pages/user authentication/login.dart';
import '../providers/user_provider.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser!;
    final userType = context.watch<UserProvider>().userType;

    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              UserAccountsDrawerHeader(
                currentAccountPicture:
                    Image.asset('assets/GCTU-Logo-600x600.png'),
                accountName: Text(
                  currentUser.displayName ?? 'user name',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                currentAccountPictureSize: const Size(90, 90),
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
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProjectArchive(),
                      ));
                },
                child: ListTile(
                  leading: Icon(
                    Icons.archive_rounded,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: const Text(
                    'Project Archive',
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AllProjectsAnalytics(
                        rawData: {},
                      ),
                    ),
                  );
                },
                child: ListTile(
                  leading: Icon(
                    Icons.data_exploration,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: const Text(
                    'Analytics',
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Navigate to Contact page
                  Navigator.pushNamed(context, '/saved-projects');
                },
                child: ListTile(
                  leading: Icon(
                    Icons.bookmark,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: const Text(
                    'Saved Projects',
                  ),
                ),
              ),
              userType != 'student'
                  ? GestureDetector(
                      onTap: () {
                        // Navigate to internship page
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatListPage(),
                            ));
                      },
                      child: ListTile(
                        leading: Icon(
                          Icons.message_rounded,
                          color: Theme.of(context).primaryColor,
                        ),
                        title: const Text(
                          'Add Job/Internship',
                        ),
                      ),
                    )
                  : Container(),
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
                  title: const Text(
                    'View Internships Or Jobs',
                  ),
                ),
              ),
              userType != 'student'
                  ? GestureDetector(
                      onTap: () {
                        // Navigate to internship page
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatListPage(),
                            ));
                      },
                      child: ListTile(
                        leading: Icon(
                          Icons.message_rounded,
                          color: Theme.of(context).primaryColor,
                        ),
                        title: const Badge(
                          child: Text(
                            'Messages',
                          ),
                        ),
                      ),
                    )
                  : Container(),
              GestureDetector(
                onTap: () {
                  // Navigate to About us
                  Navigator.pushNamed(context, '/about-us');
                },
                child: ListTile(
                  leading: Icon(
                    Icons.info_rounded,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: const Text(
                    'About Us',
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Navigate to Contact page
                  Navigator.pushNamed(context, '/contact-us');
                },
                child: ListTile(
                  leading: Icon(
                    Icons.contact_mail_rounded,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: const Text(
                    'Contact Us',
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
