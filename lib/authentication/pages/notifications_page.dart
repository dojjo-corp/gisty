import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Center(
            child: Text('No Notifications Yet'),
          )),
    );
  }
}
