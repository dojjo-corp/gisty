import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatNotifications extends StatelessWidget {
  const ChatNotifications({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream:
            FirebaseFirestore.instance.collection('Notifications').snapshots(),
        builder: (context, snapshot) {
          return ListView();
        });
  }
}
