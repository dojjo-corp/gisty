import 'package:flutter/material.dart';

import '../components/event_tile.dart';

class EventsPage extends StatelessWidget {
  const EventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: 4,
      itemBuilder: (context, index) {
        return const EventTile(
          title: 'Event Title',
          organisation: 'Organisation',
          location: 'Location',
        );
      },
      separatorBuilder: (context, index) {
        return const SizedBox(height: 10);
      },
    );
  }
}
