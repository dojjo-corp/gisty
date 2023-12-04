import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

import '../../components/buttons/custom_back_button.dart';
import '../../components/ListTiles/recent_chat_tile.dart';
import '../../components/round_profile.dart';
import '../../helper_methods.dart/messaging.dart';
import '../../providers/user_provider.dart';
import 'chat_page.dart';

class ChatListPage extends StatelessWidget {
  ChatListPage({super.key});

  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    final allUsers = Provider.of<UserProvider>(context).allUsers;

    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(
                top: 100, right: 15, left: 15, bottom: 10),
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Available Professionals',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                    // Display All Reigstered Professionals (Except Current User)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white54,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      padding: const EdgeInsets.all(15),
                      width: MediaQuery.of(context).size.width,
                      height: 110,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: allUsers.map(
                          (e) {
                            if (currentUser!.email != e['email'] &&
                                e['user-type'].toLowerCase() != 'student' && e['online']) {
                              return RoundProfile(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatPage(
                                        receiverEmail: e['email'],
                                        roomId: getRoomId(e['email']),
                                      ),
                                    ),
                                  );
                                },
                                role: e['user-type'],
                                image: '',
                                userName: e['fullname']?.split(' ')[0] ??
                                    e['full-name']?.split(' ')[0],
                              );
                            }
                            return Container();
                          },
                        ).toList(),
                      ),
                    ),
                    Text(
                      'Recent Chats',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('Chat Rooms')
                          .orderBy('last-text.time', descending: true)
                          .snapshots()
                          .throttleTime(const Duration(milliseconds: 1500)),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: Text(
                                'Tap On Any Of The Profiles Above To Start A Chat!'),
                          );
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child:
                                Text('Error Loading Chats: ${snapshot.error}'),
                          );
                        }

                        final docs = snapshot.data!.docs;
                        Map<String, Map<String, dynamic>> allRoomsData = {};
                        for (var doc in docs) {
                          // Only Display Rooms With Current User's Email
                          if (doc.id.contains(currentUser!.email!)) {
                            final data = doc.data();
                            final messages = data['messages'] as List;
                            allRoomsData[doc.id] = data;

                            // Check For Last Message Sent In Room
                            if (messages.isNotEmpty) {
                              // get last message's read status
                              allRoomsData[doc.id]?['last-read'] =
                                  messages.last['read'];
                            }

                            // retrieve receiver's email from room's [users] property
                            String receiverEmail = '';
                            for (var email in data['users']) {
                              if (email != currentUser!.email) {
                                receiverEmail = email;
                              }
                            }
                            allRoomsData[doc.id]!['receiver'] = receiverEmail;
                          }
                        }

                        return Column(
                          children: allRoomsData.values.map(
                            (singleRoomData) {
                              return singleRoomData['messages'].isNotEmpty
                                  ? RecentChatTile(
                                      hasUnreadText: singleRoomData['last-text']
                                                  ['sender'] ==
                                              singleRoomData['receiver'] &&
                                          !singleRoomData['last-read'],
                                      receiver: singleRoomData['receiver']!,
                                      lastTextData:
                                          singleRoomData['last-text']!,
                                    )
                                  : Container();
                            },
                          ).toList(),
                        );
                      },
                    ),
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
}
