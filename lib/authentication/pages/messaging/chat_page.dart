// import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gt_daily/authentication/components/buttons/buttons.dart';
import 'package:gt_daily/authentication/components/textfields/multi_line_textfeld.dart';
import 'package:gt_daily/authentication/helper_methods.dart/global.dart';
import 'package:gt_daily/authentication/helper_methods.dart/messaging.dart';
import 'package:gt_daily/authentication/providers/connectivity_provider.dart';
import 'package:provider/provider.dart';

import '../../components/chat_bubble.dart';
import '../../providers/user_provider.dart';
import '../../repository/firestore_repo.dart';

class ChatPage extends StatefulWidget {
  final String roomId, receiverEmail;
  final bool isReceiverDeleted;
  const ChatPage({
    super.key,
    required this.roomId,
    required this.receiverEmail,
    required this.isReceiverDeleted,
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
      appBar: chatCustomAppBar(
        context: context,
        receiverEmail: widget.receiverEmail,
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 15, bottom: 10),
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              SingleChildScrollView(
                reverse: true,
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 15.0, right: 15.0, bottom: 80),
                  child: StreamBuilder(
                    stream: getThrottledStream(
                      collectionPath: 'Chat Rooms',
                      docPath: widget.roomId,
                    ),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Send A Text, Quick!'),
                          ],
                        );
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Text('Error Loading Chat: ${snapshot.error}'),
                        );
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: Text(
                            'Loading...',
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                        );
                      }

                      // get all messages
                      final List messages = snapshot.data!.data()!['messages'];

                      return Column(
                        children: [
                          // PLEASE DO NOT REMOVE THIS ROW.
                          // I KNOW IT'S EMPTY, BUT IF YOU DON'T WANT TO SPEND
                          // THE NEXT HALF OF YOUR LIFE FIXING AN UNFIXABLE,
                          // DO NOT TOUCH THIS EMPTY ROW!
                          Row(
                            children: [Container()],
                          ),
                          Column(
                            children: messages
                                .map(
                                  (message) => GestureDetector(
                                    onLongPressStart: (details) {
                                      showCustomDialog(
                                        context,
                                        contentText: 'Delete this text?',
                                        title: 'Caution',
                                        onAccept: () async {
                                          messages.removeWhere((element) =>
                                              element['time'] ==
                                              message['time']);

                                          // update firestore document
                                          await store
                                              .collection('Chat Rooms')
                                              .doc(widget.roomId)
                                              .update(
                                            {'messages': messages},
                                          );

                                          // rebuild page
                                          if (mounted) {
                                            Navigator.pop(context);
                                          }
                                        },
                                      );
                                    },
                                    child: ChatBubble(
                                      isDeleted: message!['deleted'] ?? false,
                                      timeSent: message!['time'].toDate(),
                                      text: message!['text'],
                                      isIncomingText: message!['sender'] !=
                                          FirebaseAuth
                                              .instance.currentUser!.email,
                                    ),
                                  ),
                                )
                                .toList(),
                          )
                        ],
                      );
                    },
                  ),
                ),
              ),

              // todo: INPUT BOX
              Positioned(
                bottom: 0,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(10),
                    ),
                  ),
                  child: widget.isReceiverDeleted
                      ? MyButton(
                          onPressed: () {
                            showCautionDialog(
                                context, 'You can\'t text deleted users.');
                          },
                          btnText: 'Deleted User',
                          isPrimary: false,
                        )
                      : Padding(
                          padding: const EdgeInsets.only(left: 10.0, right: 5),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: MultiLineTextField(
                                  controller: messageController,
                                  hintText: 'Message',
                                  maxLines: 5,
                                ),
                              ),
                              Consumer<ConnectivityProvider>(builder:
                                  (context, connectivityProvider, child) {
                                final connectionResult =
                                    connectivityProvider.connectivityResult;
                                return FloatingActionButton(
                                  mini: true,
                                  onPressed: () async {
                                    final messageText = messageController.text;
                                    messageController.clear();
                                    await sendMessage(
                                      token: fcmToken,
                                      roomId: widget.roomId,
                                      receiverEmail: widget.receiverEmail,
                                      messageText: messageText,
                                      context: context,
                                      connectionResult: connectionResult,
                                    );
                                  },
                                  backgroundColor:
                                      const Color.fromARGB(255, 75, 125, 200),
                                  child: const Icon(
                                    Icons.double_arrow_rounded,
                                    size: 35,
                                  ),
                                );
                              })
                            ],
                          ),
                        ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // CUSTOM METHODS

  Future<void> createChatRoom() async {
    FirestoreRepo().createChatRoom(widget.receiverEmail);
  }
}
