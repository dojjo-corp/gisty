import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../pages/messaging/chat_page.dart';
import '../providers/user_provider.dart';

class RecentChatTile extends StatelessWidget {
  final String? receiver;
  Map<String, dynamic> receiverData = {};
  final Map<String, dynamic>? lastTextData;
  RecentChatTile({
    super.key,
    required this.receiver,
    required this.lastTextData,
  });

  String getRoomId(String receiverEmail) {
    String roomId = '';
    final ids = [FirebaseAuth.instance.currentUser!.email, receiverEmail];
    ids.sort();
    roomId = ids.join();
    return roomId;
  }

  @override
  Widget build(BuildContext context) {
    final allUsers = context.watch<UserProvider>().allUsers;
    for (var user in allUsers) {
      if (user['email'] == receiver) {
        receiverData = user;
      }
    }
    final lastTextSender = lastTextData?['sender'];
    final DateTime tempTime = lastTextData?['time'].toDate();
    final date = '${tempTime.day}/${tempTime.month}/${tempTime.year}';
    final time = '${tempTime.hour}:${tempTime.minute}';
    final lastTextSenderName =
        context.watch<UserProvider>().getUserDataFromEmail(lastTextSender)?['fullname'];

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(
              receiverEmail: receiver ?? '',
              roomId: getRoomId(receiver ?? ''),
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 3),
        child: ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            tileColor: Colors.white70,
            title: Text(
              receiverData['fullname'],
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600, color: Colors.yellow[800]),
            ),
            subtitle: Row(
              children: [
                Flexible(
                  child: Text(
                    lastTextSenderName
                            .contains(FirebaseAuth.instance.currentUser!.displayName)
                        ? 'You '
                        : '${lastTextSenderName.split(' ')[0]} ',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: Colors.yellow[800]?.withOpacity(0.5),
                    ),
                  ),
                ),
                Flexible(
                  child: Text(lastTextData?['text']),
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  date,
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.yellow[800]?.withOpacity(0.5)),
                ),
                Text(
                  time,
                  style: TextStyle(color: Colors.yellow[800]?.withOpacity(0.5)),
                )
              ],
            )),
      ),
    );
  }
}
