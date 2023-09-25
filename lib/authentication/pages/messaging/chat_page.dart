import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gt_daily/authentication/providers/user_provider.dart';
import 'package:gt_daily/authentication/repository/firestore_repo.dart';
import 'package:provider/provider.dart';

import '../../components/chat_bubble.dart';
import '../../components/custom_back_button.dart';

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

class _ChatPageState extends State<ChatPage> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final messageController = TextEditingController();
  bool hasRoom = false;
  final store = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    createChatRoom().then((value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          hasRoom = true;
        });
      });
    });
  }

  Future<void> createChatRoom() async {
    FirestoreRepo().createChatRoom(widget.receiverEmail);
  }

  Future<void> sendMessage() async {
    log('room id: ${widget.roomId}');
    log('my email: ${currentUser.email}');
    log('receiver email: ${widget.receiverEmail}');
    try {
      if (messageController.text.isNotEmpty) {
        await FirestoreRepo().sendMessage(
          messageController.text,
          widget.roomId,
        );
        messageController.clear();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error Sending Message: ${e.toString()}'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final receiverData =
        context.read<UserProvider>().getUserDataFromEmail(widget.receiverEmail);

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
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(
                top: 100, right: 15, bottom: 80, left: 15),
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Do Not Remove This Row!!! I Know It's Empty, But For Your Own Good, Do Not Remove It From The Code!!!
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(''),
                      ],
                    ),
                    StreamBuilder(
                      stream: FirebaseFirestore.instance
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
                            log('${e['sender']}\n${e['text']}');
                            final alignment = e['sender'] !=
                                    FirebaseAuth.instance.currentUser!.email
                                ? Alignment.centerLeft
                                : Alignment.centerRight;
                            return Container(
                              alignment: alignment,
                              child: ChatBubble(
                                text: e['text'],
                                isIncomingText: e['sender'] !=
                                    FirebaseAuth.instance.currentUser!.email,
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Positioned(
            top: 40,
            left: 5,
            child: MyBackButton(),
          ),
          Positioned(
            top: 100,
            child: Container(
              color: Colors.grey[200],
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    receiverData!['fullname'] ?? receiverData['full-name'],
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
              bottom: 0,
              child: Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(20))),
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
                        ),
                      ),
                      IconButton(
                          onPressed: sendMessage,
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
}
