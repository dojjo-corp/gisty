import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gt_daily/authentication/components/round_profile.dart';
import 'package:gt_daily/authentication/repository/firestore_repo.dart';
import 'package:provider/provider.dart';

import '../../components/custom_back_button.dart';
import '../../components/recent_chat_tile.dart';
import '../../providers/user_provider.dart';
import 'chat_page.dart';

class ChatListPage extends StatelessWidget {
  const ChatListPage({super.key});

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
    final repo = FirestoreRepo();

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
                    Container(
                      decoration: const BoxDecoration(color: Colors.white54),
                      padding: const EdgeInsets.all(15),
                      width: MediaQuery.of(context).size.width,
                      height: 110,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: allUsers
                            .map(
                              (e) => RoundProfile(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ChatPage(
                                          roomId: getRoomId(e['email']),
                                        ),
                                      ),
                                    );
                                  },
                                  image: '',
                                  userName: e['fullname']?.split(' ')[0] ??
                                      e['full-name']?.split(' ')[0]),
                            )
                            .toList(),
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
                              child: Text(
                                  'Error Loading Chats: ${snapshot.error}'),
                            );
                          }

                          final docs = snapshot.data!.docs;
                          Map<String, Map<String, dynamic>> roomsData = {};
                          for (var doc in docs) {
                            roomsData[doc.id] = doc.data();
                            if (doc.data()['messages'].isNotEmpty) {
                              roomsData[doc.id]?['last-text'] =
                                  doc.data()['messages'].last();
                            } else {
                              roomsData[doc.id]
                                  ?['last-text'] = {'text': 'No Messages Yet!'};
                            }
                          }

                          return Column(
                            children: roomsData.values
                                .map((value) => RecentChatTile(
                                      sender: value['room-id']!,
                                      receiver: '',
                                      lastTextData: value['last-text']!,
                                    ))
                                .toList(),
                          );
                        }),
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
