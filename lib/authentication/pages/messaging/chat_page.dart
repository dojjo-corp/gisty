import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../components/chat_bubble.dart';
import '../../helper_methods.dart/profile.dart';
import '../../providers/user_provider.dart';
import '../../repository/firebase_messaging.dart';
import '../../repository/firestore_repo.dart';
import '../user account/other_user_account_page.dart';

class ChatPage extends StatefulWidget {
  final String roomId, receiverEmail;
  const ChatPage({
    super.key,
    required this.roomId,
    required this.receiverEmail,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with WidgetsBindingObserver {
  final messageController = TextEditingController();
  bool hasRoom = false;
  bool isOnline = false;
  bool isConnected = false;
  final store = FirebaseFirestore.instance;
  final repo = FirestoreRepo();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    createChatRoom().then((value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          hasRoom = true;
        });
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final receiverData =
        context.read<UserProvider>().getUserDataFromEmail(widget.receiverEmail);
    final fcmToken = receiverData?['fcm-token'];

    if (!hasRoom) {
      return Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: Colors.white70,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: customAppBar(),
      body: Stack(
        children: [
          Padding(
            padding:
                const EdgeInsets.only(top: 15, right: 15, bottom: 55, left: 15),
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: [
                  // Do Not Remove This Row!!! I Know It's Empty, But For Your Own Good, Do Not Remove It From The Code!!!
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(),
                    ],
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      reverse: true,
                      child: StreamBuilder(
                        stream: store
                            .collection('Chat Rooms')
                            .doc(widget.roomId)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData || !snapshot.data!.exists) {
                            return const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Send A Text Quick!'),
                              ],
                            );
                          }
                          // iot

                          if (snapshot.hasError) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Center(
                                  child: Text(
                                      'Error Loading Chat: ${snapshot.error}'),
                                ),
                              ],
                            );
                          }

                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Row(
                              children: [
                                Center(
                                  child: Text('Loading...'),
                                ),
                              ],
                            );
                          }

                          final List messages =
                              snapshot.data!.data()!['messages'];
                          return Column(
                            children: messages.map((e) {
                              return ChatBubble(
                                isDeleted: e['deleted'] ?? false,
                                timeSent: e['time'].toDate(),
                                text: e['text'],
                                isIncomingText: e['sender'] !=
                                    FirebaseAuth.instance.currentUser!.email,
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // MESSAGE INPUT BOX
          Positioned(
              bottom: 0,
              child: Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.5),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(10),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: messageController,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Message',
                          ),
                          minLines: 1,
                          maxLines: 5,
                        ),
                      ),
                      IconButton(
                          onPressed: () async {
                            await sendMessage(fcmToken);
                          },
                          icon: Icon(Icons.arrow_circle_right_rounded,
                              color: Theme.of(context).primaryColor, size: 35))
                    ],
                  ),
                ),
              ))
        ],
      ),
    );
  }

  // CUSTOM METHODS

  AppBar customAppBar() {
    final receiverData =
        context.read<UserProvider>().getUserDataFromEmail(widget.receiverEmail);
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
                otherUserEmail: receiverData['email'],
              ),
            ),
          );
        },
        child: Row(
          children: [
            // RECEIPIENT'S PROFILE PICTURE (OR ICON, IF IT'S NULL)
            StreamBuilder(
              stream: store
                  .collection('users')
                  .doc(receiverData!['uid'])
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData ||
                    snapshot.connectionState == ConnectionState.waiting) {
                  return showNoOtherUserProfilePicture(context, 30);
                }

                final String? profilePicture =
                    snapshot.data!.data()!['profile-picture'];
                if (profilePicture != null) {
                  return showOtherUserProfilePicture(
                      profilePicture, context, 15);
                }
                return showNoOtherUserProfilePicture(context, 30);
              },
            ),
            const SizedBox(width: 5),

            // RECEIPIENT'S NAME
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
                      receiverData['fullname'],
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    StreamBuilder(
                      stream: store
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Text('Loading...');
                        }
            
                        if (snapshot.hasError) {
                          return const Text('Connecting...');
                        }
            
                        return Text(
                          snapshot.data!.data()!['new'].toString(),
                          style: GoogleFonts.montserrat(
                              color: Colors.grey, fontSize: 12),
                        );
                      },
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          onPressed: showChatOptions,
          icon: const Icon(Icons.more_vert),
        ),
      ],
    );
  }

  Future<void> createChatRoom() async {
    FirestoreRepo().createChatRoom(widget.receiverEmail);
  }

  Future<void> sendMessage(String token) async {
    try {
      if (messageController.text.isNotEmpty) {
        String text = messageController.text;
        String senderFullName =
            getUserFullname(FirebaseAuth.instance.currentUser!.email!);
        messageController.clear();
        // sned to firstore
        await repo.sendMessage(
          text,
          widget.roomId,
        );
        await repo.sendNotificationToFirestore(
          to: widget.receiverEmail,
          type: 'chat',
          title: senderFullName,
          body: text,
        );
        // notify receiver's device of message
        final response = await FireMessaging().sendPushNotifiation(
          token: token,
          title: senderFullName,
          body: text,
          type: 'chat',
        );
        log(response!.statusCode.toString());
        log(token);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error Sending Message: ${e.toString()}'),
        ),
      );
    }
  }

  String getUserFullname(String email) {
    return context
        .read<UserProvider>()
        .getUserDataFromEmail(email)?['fullname'];
  }

  showChatOptions() {
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
}
