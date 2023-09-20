import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FireMessaging {
  FireMessaging();

  final messaging = FirebaseMessaging.instance;

  // initialize firebase messaging
  Future<void> initNotifications() async {
    // request permission from user
    await messaging.requestPermission();
    // get firebase cloud messaging token of user
    final fCMToken = await messaging.getToken();
    messaging.onTokenRefresh.listen((fcmToken) {
      // TODO: If necessary send token to application server.

      // Note: This callback is fired at each app startup and whenever a new
      // token is generated.
    }).onError((err) {
      // Error getting token.
    });
  }

  Future<void> handleNotification(RemoteMessage? message) async {
    if (message != null) {
      final notificationMap = {
        'title': message.data['title'],
        'body': message.data['body'],
        'time': Timestamp.fromDate(message.sentTime!),
        'type': message.data['type']
      };
      FirebaseFirestore.instance
          .collection('notifications')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .update({
        'notifications': FieldValue.arrayUnion([notificationMap]),
      });
    }
  }
}
