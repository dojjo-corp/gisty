// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gt_daily/authentication/helper_methods.dart/global.dart';
import 'package:gt_daily/authentication/pages/jobs/jobs_page.dart';
import 'package:gt_daily/authentication/pages/messaging/chat_list_page.dart';
import 'package:gt_daily/authentication/pages/projects/project_details.dart';
import 'package:gt_daily/authentication/repository/navigation_repo.dart';

import '../../../global/homepage.dart';
import '../../components/buttons/custom_back_button.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final String currentUserEmail = FirebaseAuth.instance.currentUser!.email!;
  final store = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(
                top: 100, bottom: 10, right: 15, left: 15),
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: SingleChildScrollView(
                // reverse: true,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notifications',
                      style: GoogleFonts.poppins(
                          fontSize: 40, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    StreamBuilder(
                      stream: getThrottledStream(
                        collectionPath: 'Notifications',
                        docPath: FirebaseAuth.instance.currentUser?.email,
                      ),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData || snapshot.hasError) {
                          return const Center(
                            child: Text('No Notifications Yet'),
                          );
                        }

                        if (snapshot.data!.data() == null) {
                          return const Center(
                            child: Text('No Notifications Yet'),
                          );
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              'Error Loading Notifications: ${snapshot.error}',
                            ),
                          );
                        }

                        // No Errors And Data Available
                        final myNotifications =
                            snapshot.data!.data()!['my-notifications'] as List;

                        return Column(
                          children: myNotifications.reversed.map(
                            (notification) {
                              int index = myNotifications.indexOf(notification);
                              String title = notification['title'];
                              String body = notification['body'];
                              bool read = notification['read'];
                              String routeName =
                                  notification['route-name'] ?? '/';
                              Map<String, dynamic>? routeArgs =
                                  notification['route-arguments'];

                              late IconData iconData;

                              /// Get icon to use based on notification type
                              final type = notification['type'];

                              switch (type) {
                                case 'job':
                                  iconData = Icons.assured_workload_rounded;
                                  break;
                                case 'event':
                                  iconData = Icons.event_note_rounded;
                                  break;
                                case 'project':
                                  iconData = Icons.school_rounded;
                                  break;
                                case 'chat':
                                  iconData = Icons.message_rounded;
                                default:
                                  iconData = Icons.notifications;
                              }

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 5.0),
                                child: GestureDetector(
                                  onTap: () async {
                                    updateRead(index);
                                    if (context.mounted) {
                                      // page to navigate to based on notifiation type
                                      NavigationService.instance.navigateTo(
                                          routeName,
                                          arguments: routeArgs);
                                    }
                                  },
                                  child: ListTile(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side:
                                          BorderSide(color: Colors.grey[100]!),
                                    ),
                                    tileColor: Colors.grey[300],
                                    contentPadding:
                                        const EdgeInsets.only(left: 5),
                                    leading: Icon(iconData,
                                        color: read
                                            ? Colors.grey
                                            : Theme.of(context).primaryColor),
                                    title: Text(
                                      title,
                                      style: TextStyle(
                                          fontWeight: read
                                              ? FontWeight.normal
                                              : FontWeight.bold),
                                    ),
                                    subtitle: Text(body),
                                  ),
                                ),
                              );
                            },
                          ).toList(),
                        );
                      },
                    )
                  ],
                ),
              ),
            ),
          ),
          const MyBackButton()
        ],
      ),
    );
  }

  void goToChatPage(BuildContext _context) {
    Navigator.push(
      _context,
      MaterialPageRoute(
        builder: (_context) => ChatListPage(),
      ),
    );
  }

  void goToEventPage(BuildContext _context) {
    Navigator.push(
      _context,
      MaterialPageRoute(
        builder: (_context) => MyHomePage(
          pageIndex: 2,
        ),
      ),
    );
  }

  void goToJobPage(BuildContext _context) {
    Navigator.push(
      _context,
      MaterialPageRoute(
        builder: (_context) => const AllJobsPage(),
      ),
    );
  }

  void goToProjectPage(BuildContext _context) {
    Navigator.push(
      _context,
      MaterialPageRoute(
        builder: (_context) =>
            const ProjectDetails(goToComment: false, projectData: {}),
      ),
    );
  }

  Future<void> updateRead(int index) async {
    final docSnapshot =
        await store.collection('Notifications').doc(currentUserEmail).get();
    if (docSnapshot.exists) {
      final docData = docSnapshot.data();
      docData!['my-notifications'][index]['read'] = true;
      await store
          .collection('Notifications')
          .doc(currentUserEmail)
          .update(docData);
    }
  }
}
