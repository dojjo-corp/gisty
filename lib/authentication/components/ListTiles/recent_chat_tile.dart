// import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gt_daily/authentication/pages/user%20account/other_user_account_page.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

import '../../pages/messaging/chat_page.dart';
import '../../providers/user_provider.dart';

class RecentChatTile extends StatefulWidget {
  final String? receiver;
  final Map<String, dynamic>? lastTextData;
  final bool hasUnreadText;
  const RecentChatTile({
    super.key,
    required this.receiver,
    required this.lastTextData,
    required this.hasUnreadText,
  });

  @override
  State<RecentChatTile> createState() => _RecentChatTileState();
}

class _RecentChatTileState extends State<RecentChatTile> {
  Map<String, dynamic> receiverData = {};
  bool _isReceiverDeleted = true;

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
      if (user['email'] == widget.receiver) {
        receiverData = user;
        setState(() {
          _isReceiverDeleted = false;
        });
        break;
      }
    }
    final lastTextSender = widget.lastTextData?['sender'];
    final DateTime tempTime = widget.lastTextData?['time'].toDate();
    final date = '${tempTime.day} ${tempTime.month}, ${tempTime.year}';
    final time =
        '${tempTime.hour.toString().padLeft(2, '0')}:${tempTime.minute.toString().padLeft(2, '0')}';
    final lastTextSenderName = context
        .watch<UserProvider>()
        .getUserDataFromEmail(lastTextSender)?['fullname'];

    return GestureDetector(
      onTap: () async {
        // udpate last-text's read status to true
        final String roomId = getRoomId(widget.receiver ?? '');
        final lastTextData = widget.lastTextData;

        // only update read status if the last text is not sent by the current user
        if (lastTextData?['sender'] !=
            FirebaseAuth.instance.currentUser!.email) {
          lastTextData?['read'] = true;
          await FirebaseFirestore.instance
              .collection('Chat Rooms')
              .doc(roomId)
              .update({
            'last-text': lastTextData,
          });
        }

        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPage(
                receiverEmail: widget.receiver ?? '',
                roomId: getRoomId(widget.receiver ?? ''),
                isReceiverDeleted: _isReceiverDeleted,
              ),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 3),
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey[100]!),
          ),
          tileColor: Colors.grey[300],
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),

          // RECEIVER'S PROFILE PICTURE
          leading: GestureDetector(
            onTap: () async {
              if (context.mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        OtherUserAccountPage(otherUserEmail: widget.receiver!),
                  ),
                );
              }
            },
            child: widget.hasUnreadText
                ? Badge(child: getProfilePicture())
                : getProfilePicture(),
          ),

          // RECEIVER'S NAME
          title: Text(
            receiverData['fullname'] ?? 'Deleted User',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
          ),

          // LAST SENT TEXT
          subtitle: Row(
            children: [
              Text(
                lastTextSenderName.contains(
                        FirebaseAuth.instance.currentUser!.displayName)
                    ? 'You '
                    : '${lastTextSenderName.split(' ')[0]}',
                style: GoogleFonts.poppins(
                  color: Colors.blue.withOpacity(0.5),
                ),
              ),
              Expanded(
                child: Text(
                  widget.lastTextData?['text'],
                  maxLines: 1,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          // TIME LAST TEXT WAS SENT
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                date,
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 9),
              ),
              Text(
                time,
                style: const TextStyle(
                  fontSize: 9,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget getProfilePicture() {
    final noUserProfileIcon =
        receiverData['user-type']?.toLowerCase() == 'university professional'
            ? const Icon(Icons.school, color: Colors.blue, size: 40)
            : const Icon(Icons.work_rounded, color: Colors.blue, size: 40);
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(receiverData['uid'])
          .snapshots()
          .throttleTime(const Duration(milliseconds: 100)),
      builder: (context, snapshot) {
        if (!snapshot.hasData ||
            snapshot.hasError ||
            snapshot.connectionState == ConnectionState.waiting) {
          return CircleAvatar(
            backgroundColor: Colors.grey[200],
            child: noUserProfileIcon,
          );
        }

        final String? profilePicture = snapshot.data?.data()?['profile-picture'];

        // return circular image if user has profile picture
        if (profilePicture != null) {
          return SizedBox(
            width: 40,
            child: CircleAvatar(
              maxRadius: 20,
              foregroundImage: Image.network(profilePicture).image,
              onForegroundImageError: (exception, stackTrace) => CircleAvatar(
                backgroundColor: Colors.grey[200],
                child: noUserProfileIcon,
              ),
            ),
          );
        }
        // return an icon ohterwise
        return noUserProfileIcon;
      },
    );
  }
}
