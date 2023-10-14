import 'package:firebase_auth/firebase_auth.dart';

String getRoomId(String receiverEmail) {
    String roomId = '';
    final ids = [FirebaseAuth.instance.currentUser!.email, receiverEmail];
    ids.sort();
    roomId = ids.join();
    return roomId;
  }