// ignore_for_file: unused_import

import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gt_daily/authentication/helper_methods.dart/global.dart';
import 'package:gt_daily/authentication/helper_methods.dart/profile.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

import '../pages/user account/other_user_account_page.dart';
import '../providers/user_provider.dart';
import '../repository/firebase_messaging.dart';
import '../repository/firestore_repo.dart';

final repo = FirestoreRepo();
final store = FirebaseFirestore.instance;
String getRoomId(String receiverEmail) {
  String roomId = '';
  final ids = [FirebaseAuth.instance.currentUser!.email, receiverEmail];
  ids.sort();
  roomId = ids.join();
  return roomId;
}

showChatOptions(BuildContext context) {
  showMenu<Widget>(
    context: context,
    position: RelativeRect.fromDirectional(
        textDirection: TextDirection.ltr,
        start: MediaQuery.of(context).size.width * 0.5,
        top: 50,
        end: 40,
        bottom: 100),
    items: [
      const PopupMenuItem(child: Text('Option 1')),
      const PopupMenuItem(child: Text('Option 1')),
      const PopupMenuItem(child: Text('Option 1')),
      const PopupMenuItem(child: Text('Option 1'))
    ],
  );
}

String getUserFullname(String email, BuildContext context) {
  return context.read<UserProvider>().getUserDataFromEmail(email)?['fullname'];
}

Future<void> sendMessage({
  required String token,
  required String roomId,
  required String receiverEmail,
  required String messageText,
  required BuildContext context,
  ConnectivityResult? connectionResult,
  bool isReceiverDeleted = false,
}) async {
  // only send a message if the message text field is not empty
  // and receiver's account is not deleted
  if (messageText.characters.isNotEmpty && !isReceiverDeleted) {
    String text = messageText;
    String senderFullName = getUserFullname(
      FirebaseAuth.instance.currentUser!.email!,
      context,
    );
    log(senderFullName);

    try {
      // Throw error if device is not connected to the internet
      if (connectionResult == ConnectivityResult.none) {
        throw 'You are not connected to the internet';
      }
      // sned to firstore
      await repo.sendMessage(
        text,
        roomId,
      );

      // notify receiver's device of message
      // ignore: unused_local_variable
      final response = await FireMessaging().sendPushNotifiation(
        token: token,
        receiverEmail: receiverEmail,
        title: senderFullName,
        body: text,
        type: 'chat',
        routeName: '/chat-page',
        routeArgs: {
          'room-id': roomId,
          'receiver-email': FirebaseAuth.instance.currentUser!.email!,
          'isReceiverDeleted': isReceiverDeleted,
        },
      );
    } catch (e) {
      showSnackBar(context, 'Error Sending Message: ${e.toString()}');
    }
  }
}

AppBar chatCustomAppBar({
  required BuildContext context,
  required String receiverEmail,
}) {
  final receiverData =
      context.read<UserProvider>().getUserDataFromEmail(receiverEmail);
  return AppBar(
    centerTitle: false,
    leading: GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Icon(
        Icons.arrow_back_ios_rounded,
        color: Colors.grey[600],
      ),
    ),
    title: GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtherUserAccountPage(
              otherUserEmail: receiverEmail,
            ),
          ),
        );
      },
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(receiverData?['uid'])
            .snapshots()
            .throttleTime(const Duration(milliseconds: 100)),
        builder: (context, snapshot) {
          if (!snapshot.hasData ||
              snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Text(
                'Loading',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            );
          }

          final data = snapshot.data!.data() ?? {};
          if (data.isEmpty) {
            return Center(
              child: Row(
                children: [
                  const CircleAvatar(
                    child: Icon(
                      Icons.person,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Deleted User ',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            );
          }
          final String? profilePictureUrl = data['profile-picture'];
          final isOnline = snapshot.data!.data()!['online'] ?? false;
          return Row(
            children: [
              _getReceiverProfile(
                profilePictureUrl: profilePictureUrl,
                context: context,
                uid: data['uid'],
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        receiverData?['fullname'],
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600, fontSize: 16),
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      Text(
                        isOnline
                            ? 'Onilne'
                            : showLastSeen(
                                receiverData?['last-seen']?.toDate()),
                        style: GoogleFonts.montserrat(
                            color: Colors.grey, fontSize: 12),
                      )
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    ),
    // todo: Add Chat Options (Optional...)
  );
}

Widget _getReceiverProfile(
    {required String? profilePictureUrl,
    required BuildContext context,
    required String uid}) {
  return profilePictureUrl != null
      ? showOtherUserProfilePicture(uid, profilePictureUrl, context, 15)
      : showNoOtherUserProfilePicture(context, 30);
}

// todo: Format Last Seen
String showLastSeen(DateTime? lastSeen) {
  if (lastSeen == null) return 'Offline';

  // format month
  final monthNum = lastSeen.month;
  String month = '';
  switch (monthNum) {
    case 1:
      month = 'Jan';
      break;
    case 2:
      month = 'Feb';
      break;
    case 3:
      month = 'Mar';
      break;
    case 4:
      month = 'Apr';
      break;
    case 5:
      month = 'May';
      break;
    case 6:
      month = 'Jun';
      break;
    case 7:
      month = 'Jul';
      break;
    case 8:
      month = 'Aug';
      break;
    case 9:
      month = 'Sep';
      break;
    case 10:
      month = 'Oct';
      break;
    case 11:
      month = 'Nov';
      break;
    case 12:
      month = 'Dec';
      break;
    default:
      month = 'unknown';
  }
  String day = lastSeen.day.toString().padLeft(2, '0');
  String hour = lastSeen.hour.toString().padLeft(2, '0');
  String min = lastSeen.minute.toString().padLeft(2, '0');
  final date = '$day $month';
  return 'Last Seen $date at $hour:$min';
}
