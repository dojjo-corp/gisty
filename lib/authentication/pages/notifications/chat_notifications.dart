import 'package:flutter/material.dart';
import 'package:gt_daily/authentication/helper_methods.dart/global.dart';

class ChatNotifications extends StatelessWidget {
  const ChatNotifications({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: getThrottledStream(collectionPath: 'Notifications'),
        builder: (context, snapshot) {
          return ListView();
        });
  }
}
