import 'package:flutter/material.dart';


class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: 0,
      itemBuilder: (context, index) {
        return const ListTile();
      },
      separatorBuilder: (context, index) {
        return const SizedBox(height: 10);
      },
    );
  }
}
