import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gt_daily/authentication/pages/jobs/jobs_page.dart';
import 'package:provider/provider.dart';

import '../../global/homepage.dart';
import '../pages/analytics/project_analysis.dart';
import '../pages/jobs/add_job_opportunity.dart';
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
                currentAccountPicture: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MyHomePage(pageIndex: 3),
                      ),
                    );
                  },
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(currentUser.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const CircleAvatar(
                          child: Icon(Icons.person),
                        );
                      }

                      if (snapshot.hasError) {
                        return const CircleAvatar(
                          child: Icon(Icons.person),
                        );
                      }

                      final String? profilePicture =
                          snapshot.data!.data()!['profile-picture'];
                      if (profilePicture != null) {
                        return CircleAvatar(
                          foregroundImage: Image.network(profilePicture).image,
                          onForegroundImageError: (exception, stackTrace) =>
                              const CircleAvatar(
                            child: Icon(Icons.person),
                          ),
                        );
                      }
                      return const CircleAvatar(
                        child: Icon(Icons.person),
                      );
                    },
                  ),
                ),
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
                  color: Theme.of(context).primaryColor.withOpacity(0.5),
                ),
              ),

              // ARCHIVE
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

              // ALL PROJECTS ANALYTICS
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AllProjectsAnalytics(),
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
                              builder: (context) => const AddJobOrInternship(),
                            ));
                      },
                      child: ListTile(
                        leading: Icon(
                          Icons.assured_workload_rounded,
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AllJobsPage(),
                    ),
                  );
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
                        title: StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection('Chat Rooms')
                                .orderBy('last-text.time', descending: true)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData ||
                                  snapshot.hasError ||
                                  snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                return const Text('Messages');
                              }
                              final docs = snapshot.data!.docs;
                              bool hasUnread = false;
                              for (final doc in docs) {
                                final data = doc.data();
                                if (data['users'].contains(currentUser.email) &&
                                    data['last-text']['sender'] !=
                                        currentUser.email &&
                                    data['last-text']['read'] == false) {
                                  hasUnread = true;
                                  break;
                                }
                              }
                              return hasUnread
                                  ? Badge(
                                      child: Text(
                                        'Messages'.toString(),
                                      ),
                                    )
                                  : const Text('Messages');
                            }),
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
        ],
      ),
    );
  }
}
