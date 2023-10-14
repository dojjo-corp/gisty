// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gt_daily/authentication/pages/events/events_page.dart';
import 'package:gt_daily/authentication/pages/messaging/chat_list_page.dart';

import '../../components/custom_back_button.dart';

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
                      stream: FirebaseFirestore.instance
                          .collection('Notifications')
                          .doc(FirebaseAuth.instance.currentUser?.email)
                          .snapshots(),
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
                            snapshot.data!.data()!['my-notifications'];
                        log(jsonEncode(myNotifications));

                        return ListView.builder(
                          reverse: true,
                          shrinkWrap: true,
                          itemCount: myNotifications.length,
                          itemBuilder: (context, index) {
                            String title = myNotifications[index]['title'];
                            String body = myNotifications[index]['body'];
                            bool read = myNotifications[index]['read'];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 5.0),
                              child: GestureDetector(
                                onTap: () async {
                                  await updateRead(index);
                                  if (context.mounted) {
                                    goToChatPage(context);
                                  }
                                },
                                child: ListTile(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(color: Colors.grey[100]!),
                                  ),
                                  tileColor: Colors.grey[300],
                                  contentPadding:
                                      const EdgeInsets.only(left: 5),
                                  leading: Icon(Icons.chat,
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
        builder: (_context) => const EventsPage(),
      ),
    );
  }

  void goToJobPage(BuildContext _context) {
    Navigator.push(
      _context,
      MaterialPageRoute(
        builder: (_context) => const EventsPage(),
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
