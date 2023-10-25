import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:gt_daily/authentication/helper_methods.dart/messaging.dart';
import 'package:http/http.dart' as http;

import 'navigation_repo.dart';

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  log('Notification Title: ${message.notification?.title}');
  log('Notification Body: ${message.notification?.body}');
  log('Notification Payload: ${message.data}');
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
    importance: Importance.high,
  );
  final _localNotifications = FlutterLocalNotificationsPlugin();

  // todo: Handle Clicked Notifications
  void handleMessage(RemoteMessage? message) {
    if (message == null) return;

    // navigate to corresponding route (screen/page)
    final args = message.data;
    final routeName = args['route-name'];
    final routeArgs = jsonDecode(args['route-arguments']);
    NavigationService.instance.navigateTo(
      routeName ?? '/',
      arguments: routeArgs,
    );
  }

  // todo: Initialize Firebase Messaging
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

      // display notification on device's notification panel
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

  // todo: Initialize Local Notifications
  Future<void> initLocalNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) async {
        try {
          if (response.payload != null) {
            final message = RemoteMessage.fromMap(
              jsonDecode(response.payload!),
            );
            handleMessage(message);
          }
        } catch (e) {
          rethrow;
        }
      },
    );

    final platform = _localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await platform?.createNotificationChannel(_androidChannel);
  }

  // todo: Perform All Notifications Initialization
  Future<void> initNotifications() async {
    // request permission from user
    await messaging.requestPermission();
    // get firebase cloud messaging token of user
    final fCMToken = await messaging.getToken();
    _fCMToken = fCMToken;
    debugPrint(_fCMToken);
    messaging.onTokenRefresh.listen((newFcmToken) {
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

  // todo: Send Notification To Users Device
  Future<http.Response?> sendPushNotifiation({
    required String token,
    required String title,
    required String body,
    required String type,
    required String receiverEmail,
    String? routeName,
    Map<String, dynamic>? routeArgs,
  }) async {
    try {

      // send to user's device
      final response = await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'key=AAAAfXLHx9k:APA91bHTBtAIcv0OSWJk24mmuShliPB3DDJyjKskkLMpINNCQgf893G1kKCzwKsLxfwTELTpFV6EuIiTkm_Nmwklwj9bENTRwAmyafhJISXnsrpg-HvDT4yh1sM32bJDNKzYxdBHoVb0',
        },
        body: jsonEncode({
          "to": token,
          "priority": "high", // 'normal
          "notification": {
            "android_notification_channel": "high_importance_channel",
            "title": title,
            "body": body,
          },
          "data": {
            "route-name": routeName,
            "route-arguments": routeArgs,
            "click_action": "FLUTTER_NOTIFICATION_CLICK",
            "status": "done",
            "type": type,
            "title": title,
            "body": body,
          }
        }),
      );

      // send notification to firestore
      await repo.sendNotificationToFirestore(
        to: receiverEmail,
        type: type,
        title: title,
        body: body,
        routeArgs: routeArgs,
        routeName: routeName,
      );

      // send to user's device
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // todo: Notification To All Users
  Future<Map<String, String?>?> sendPushNotifiationToAllUsers({
    required String title,
    required String body,
    required String type,
    String? routeName,
    Map<String, dynamic>? routeArgs,
  }) async {
    Map<String, String?> resultMap = {};

    try {
      // get all user tokens and emails
      final usersSnapshot =
          await FirebaseFirestore.instance.collection('users').get();
      final docs = usersSnapshot.docs;
      List tokens = [];
      List emails = [];
      for (var doc in docs) {
        tokens.add(doc.data()['fcm-token']);
        emails.add(doc.data()['email']);
      }

      // send notifications
      for (var i = 0; i < tokens.length; i++) {
        final response = await sendPushNotifiation(
          token: tokens[i],
          receiverEmail: emails[i],
          title: title,
          body: body,
          type: type,
          routeArgs: routeArgs,
          routeName: routeName,
        );
        log('This is the token for ${emails[i]}: ${tokens[i]}}');
        resultMap[emails[i]] = response?.statusCode.toString();
      }
      return resultMap;
    } catch (e) {
      rethrow;
    }
  }

  // todo: send to particular users
  Future<Map<String, String>?> sendPushNotifiationToSomeUsers({
    required String title,
    required String body,
    required String type,
    required List<String> userEmails,
    String? routeName,
    Map<String, dynamic>? routeArgs,
  }) async {
    Map<String, String> resultMap = {};

    try {
      // get all user tokens and emails
      final allUsersSnapshot =
          await FirebaseFirestore.instance.collection('users').get();
      final docs = allUsersSnapshot.docs;
      final usersDataSnapshot = docs
          .where((doc) => userEmails.contains(doc.data()['email']))
          .toList();

      // send notifications
      for (var snapshot in usersDataSnapshot) {
        final data = snapshot.data();
        final response = await sendPushNotifiation(
          token: data['fcm-token'],
          receiverEmail: data['email'],
          title: title,
          body: body,
          type: 'admin',
          routeArgs: routeArgs,
          routeName: routeName,
        );
        resultMap[data['email']] = response.toString();
      }
      return resultMap;
    } catch (e) {
      rethrow;
    }
  }
}
