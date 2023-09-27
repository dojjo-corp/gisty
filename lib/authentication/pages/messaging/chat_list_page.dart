import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gt_daily/authentication/components/round_profile.dart';
import 'package:provider/provider.dart';

import '../../components/custom_back_button.dart';
import '../../components/recent_chat_tile.dart';
import '../../providers/user_provider.dart';
import 'chat_page.dart';

class ChatListPage extends StatelessWidget {
  ChatListPage({super.key});

  final currentUser = FirebaseAuth.instance.currentUser;

  String getRoomId(String receiverEmail) {
    String roomId = '';
    final ids = [currentUser!.email, receiverEmail];
    ids.sort();
    roomId = ids.join();
    return roomId;
  }

  @override
  Widget build(BuildContext context) {
    final allUsers = Provider.of<UserProvider>(context).allUsers;
    debugPrint('This is the room id: ${getRoomId(allUsers[0]['email'])}');

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
                                e['user-type'].toLowerCase() != 'student') {
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
                          .snapshots(),
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
                        Map<String, Map<String, dynamic>> roomsData = {};
                        for (var doc in docs) {
                          // Only Display Rooms With Current User's Email
                          if (doc.id.contains(currentUser!.email!)) {
                            final data = doc.data();
                            roomsData[doc.id] = data;
                            // Check For Last Message Sent In Room
                            if (data['messages'].isNotEmpty) {
                              roomsData[doc.id]?['last-text'] =
                                  data['messages'].last;
                            }

                            // retrieve receiver's email from room's [users] property
                            String receiverEmail = '';
                            for (var email in data['users']) {
                              if (email != currentUser!.email) {
                                receiverEmail = email;
                              }
                            }
                            roomsData[doc.id]!['receiver'] = receiverEmail;
                          }
                        }

                        return Column(
                          children: roomsData.values.map(
                            (value) {
                              return value['messages'].isNotEmpty
                                  ? RecentChatTile(
                                      receiver: value['receiver']!,
                                      lastTextData: value['last-text']!,
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
          const Positioned(top: 40, left: 5, child: MyBackButton())
        ],
      ),
    );
  }
}
