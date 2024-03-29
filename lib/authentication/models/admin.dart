import 'dart:convert';
// import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gt_daily/authentication/repository/firebase_messaging.dart';
import 'package:gt_daily/authentication/repository/firestore_repo.dart';
import 'package:http/http.dart' as http;

class Administrator {
  Administrator();
  final store = FirebaseFirestore.instance;
  final messaging = FireMessaging();
  final adminUser = FirebaseAuth.instance.currentUser;

  // todo: make user admin
  Future<void> makeUserAdmin(String uid,
      {ConnectivityResult? connectionResult}) async {
    // get user data from firestore
    final docRef = store.collection('users').doc(uid);
    final snapshot = await docRef.get();

    if (snapshot.exists) {
      try {
        // Throw error if device is not connected to the internet
        if (connectionResult == ConnectivityResult.none) {
          throw 'You are not connected to the internet';
        }
        await docRef.update({'admin': true});
      } catch (e) {
        rethrow;
      }
    }
    // throw Exception if not
    else {
      throw 'Error Finding User\'s Records.\nCheck Your Internet';
    }
  }

  // todo: unmake user admin
  Future<void> removeUserAsAdmin(String uid,
      {ConnectivityResult? connectionResult}) async {
    // get user data from firestore
    final docRef = store.collection('users').doc(uid);
    final snapshot = await docRef.get();

    if (snapshot.exists) {
      try {
        // Throw error if device is not connected to the internet
        if (connectionResult == ConnectivityResult.none) {
          throw 'You are not connected to the internet';
        }
        await docRef.update({'admin': false});
      } catch (e) {
        rethrow;
      }
    }
    // throw Exception if not
    else {
      throw 'Error Finding User\'s Records.\nCheck Your Internet';
    }
  }

  // todo: server requests template
  Future<http.Response?> sendServerRequestTemplate(
      {required String endpoint,
      Map<String, dynamic>? payload,
      ConnectivityResult? connectionResult}) async {
    var url = Uri.parse('https://repo-server.onrender.com/$endpoint');
    var body = jsonEncode(payload);
    var headers = {'Content-Type': 'application/json'};

    try {
      // Throw error if device is not connected to the internet
      if (connectionResult == ConnectivityResult.none) {
        throw 'You are not connected to the internet';
      }
      return await http.post(
        url,
        headers: headers,
        body: body,
      );
    } catch (e) {
      rethrow;
    }
  }

  // todo: delete user records
  Future<void> deleteUserAccount({
    required String uid,
    required String email,
    ConnectivityResult? connectionResult,
  }) async {
    final payload = {'uid': uid};
    try {
      // Throw error if device is not connected to the internet
      if (connectionResult == ConnectivityResult.none) {
        throw 'You are not connected to the internet';
      }
      final response = await sendServerRequestTemplate(
        endpoint: 'delete_user',
        payload: payload,
      ).timeout(
        const Duration(seconds: 20),
        onTimeout: () => null,
      );
      if (response == null || response.statusCode != 200) {
        // delete user's records in database if server-side admin deletion does not work
        await FirestoreRepo().deleteUserRecords(uid: uid, email: email);
      }
    } catch (e) {
      rethrow;
    }
  }

  // todo: delete event
  Future<void> deleteEvent(
    String eventId, {
    ConnectivityResult? connectionResult,
  }) async {
    try {
      // Throw error if device is not connected to the internet
      if (connectionResult == ConnectivityResult.none) {
        throw 'You are not connected to the internet';
      }
      await store.collection('All Events').doc(eventId).delete();
    } catch (e) {
      rethrow;
    }
  }

  // todo: delete job posting
  Future<void> deleteJob(
    String jobId, {
    ConnectivityResult? connectionResult,
  }) async {
    try {
      // Throw error if device is not connected to the internet
      if (connectionResult == ConnectivityResult.none) {
        throw 'You are not connected to the internet';
      }
      await store.collection('All Jobs').doc(jobId).delete();
    } catch (e) {
      rethrow;
    }
  }

  // todo: send notice to all users
  Future<Map<String, String?>?> sendNoticeToAllUsers({
    required String noticeText,
    required String title,
  }) async {
    try {
      final resultMap = messaging.sendPushNotifiationToAllUsers(
        title: title,
        body: noticeText,
        type: 'admin',
      );

      // update in admin's firestore documemnt
      await store.collection('users').doc(adminUser!.uid).update({
        'notices-sent': FieldValue.arrayUnion([resultMap])
      });

      return resultMap;
    } catch (e) {
      rethrow;
    }
  }

  // todo: send notice to particular users
  Future<Map<String, String>?> sendNoticeToSomeUsers({
    required String noticeText,
    required String title,
    required List<String> userEmails,
  }) async {
    final resultMap = messaging.sendPushNotifiationToSomeUsers(
      title: title,
      body: noticeText,
      type: 'admin',
      userEmails: userEmails,
    );

    // update in admin's firestore documemnt
    await store.collection('users').doc(adminUser!.uid).update({
      'notices-sent': FieldValue.arrayUnion([resultMap])
    });

    return resultMap;
  }

  // todo:
}
