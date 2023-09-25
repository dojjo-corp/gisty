import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'navigation_reo.dart';

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  print('Notification Title: ${message.notification?.title}');
  print('Notification Body: ${message.notification?.body}');
  print('Notification Payload: ${message.data}');
}

class FireMessaging {
  FireMessaging();

  final messaging = FirebaseMessaging.instance;
  String? _fCMToken = '';
  String? get fCMToken => _fCMToken;

  final _androidChannel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description: 'This channel is used for important notifications.',
    importance: Importance.defaultImportance,
  );
  final _localNotifications = FlutterLocalNotificationsPlugin();

  void handleMessage(RemoteMessage? message) {
    if (message == null) return;
    NavigationService.instance.navigateTo('/notifications');
  }

  Future initPushNoifications() async {
    await messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    messaging.getInitialMessage().then(handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification == null) return;

      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _androidChannel.id,
            _androidChannel.name,
            channelDescription: _androidChannel.description,
            importance: _androidChannel.importance,
            priority: Priority.high,
            showWhen: false,
            icon: '@mipmap/ic_launcher',
          ),
        ),
        payload: jsonEncode(
          message.toMap(),
        ),
      );
    });
  }

  Future<void> initLocalNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _localNotifications.initialize(
      settings,
    );

    final platform = _localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await platform?.createNotificationChannel(_androidChannel);
  }

  // initialize firebase messaging
  Future<void> initNotifications() async {
    // request permission from user
    await messaging.requestPermission();
    // get firebase cloud messaging token of user
    final fCMToken = await messaging.getToken();
    _fCMToken = fCMToken;
    debugPrint(_fCMToken);
    messaging.onTokenRefresh.listen((newFcmToken) {
      // TODO: If necessary send token to application server.
      _fCMToken = newFcmToken;
      // Note: This callback is fired at each app startup and whenever a new
      // token is generated.
    }).onError((err) {
      // Error getting token.
    });
    initPushNoifications();
    initLocalNotifications();

    // handle background notifications
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
  }

  Future<void> handleNotification(RemoteMessage? message) async {
    if (message != null) {
      final notificationMap = {
        'title': message.notification!.title,
        'body': message.notification!.body,
        'time': Timestamp.fromDate(message.sentTime!),
        'type': message.data['type']
      };
      FirebaseFirestore.instance
          .collection('Notifications')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .update({
        'notifications': FieldValue.arrayUnion([notificationMap]),
      });
    }
  }
}
