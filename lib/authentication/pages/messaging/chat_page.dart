import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gt_daily/authentication/components/buttons.dart';
import 'package:gt_daily/authentication/repository/firestore_repo.dart';

import '../../components/custom_back_button.dart';

class ChatPage extends StatefulWidget {
  final String roomId;
  const ChatPage({
    super.key,
    required this.roomId,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late String receiverEmail;

  @override
  void initState() {
    super.initState();
    receiverEmail =
        widget.roomId.replaceAll(FirebaseAuth.instance.currentUser!.email!, '');
  }

  void createChatRoom() async {
    FirestoreRepo().createChatRoom(receiverEmail);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(
                top: 100, right: 15, bottom: 10, left: 15),
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(receiverEmail),
                      ],
                    ),
                    MyButton(
                        onPressed: createChatRoom,
                        btnText: 'Create Room',
                        isPrimary: true),
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
