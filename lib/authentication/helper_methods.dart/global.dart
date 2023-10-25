import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

showSnackBar(BuildContext context, message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
    ),
  );
}

Stream getThrottledStream(
    {required String collectionPath, String? docPath, int? throttleDuration}) {
  // default throttle time is 5 seconds
  final duration = Duration(seconds: throttleDuration ?? 5);
  return docPath != null
      ? FirebaseFirestore.instance
          .collection(collectionPath)
          .doc(docPath)
          .snapshots()
          .throttleTime(duration)
      : FirebaseFirestore.instance
          .collection(collectionPath)
          .snapshots()
          .throttleTime(duration);
}

Future<void> updateUserOnlineStatus(bool isOnline) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .update(
        {'online': isOnline, 'last-seen': Timestamp.now()},
      );
    } catch (e) {
      rethrow;
    }
  }

