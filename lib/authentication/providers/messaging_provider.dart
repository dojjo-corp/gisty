import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MessagingProvider extends ChangeNotifier {
  MessagingProvider();
  
  final store = FirebaseFirestore.instance;

  Future<List?> getMessageList(String roomId) async {
    try {
      final messageDoc = await store.collection('Chat Rooms').doc(roomId).get();
      if (messageDoc.exists && messageDoc.data() != null) {
        return messageDoc.data()!['messages'];
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sendMesage() async {}
}
