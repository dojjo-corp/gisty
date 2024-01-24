import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
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

void showCautionDialog(
  BuildContext context,
  String cautionText, {
  String? title,
  Color? titleColor,
}) {
  showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          title ?? 'Caution',
          style: TextStyle(color: titleColor ?? Colors.red),
        ),
        content: Text(cautionText),
        actions: <Widget>[
          TextButton(
            child: const Text('Okay'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

showCustomDialog(BuildContext context,
    {String? title, String? contentText, void Function()? onAccept}) {
  showDialog(
      context: context,
      builder: (context) {
        // set default callback for onAccpet
        onAccept ??= () {
          Navigator.pop(context);
        };

        return AlertDialog(
          title: Text(title ?? 'Alert'),
          content: Text(contentText ?? ''),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: onAccept,
              child: const Text('Ok'),
            )
          ],
        );
      });
}

Stream getThrottledStream(
    {required String collectionPath, String? docPath, int? throttleDuration}) {
  // default throttle time is 5 seconds
  final duration = Duration(milliseconds: throttleDuration ?? 100);
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

Future<void> refreshPage(BuildContext context,
    {ConnectivityResult? connectionResult,
    String? docPath,
    String? collectionPath}) async {
  try {
    // At least one of docPath and collectionPath should be passed to method
    assert(docPath != null || collectionPath != null,
        'Unable to read from firestore');

    // Throw error if device is not connected to the internet
    if (connectionResult == ConnectivityResult.none) {
      throw 'You are not connected to the internet';
    }

    // No connectivity errors / user is connected to the internet
  } on AssertionError catch (e) {
    showCautionDialog(context, e.message.toString());
  } on FirebaseException catch (e) {
    showCautionDialog(context, e.message!);
  } catch (e) {
    showSnackBar(context, e.toString());
  }
}
