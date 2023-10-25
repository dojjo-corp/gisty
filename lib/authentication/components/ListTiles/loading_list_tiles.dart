import 'package:flutter/material.dart';

import 'event_tile.dart';

class LoadingListTiles extends StatelessWidget {
  const LoadingListTiles({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        EventTile(
          eventDetails: {},
        ),
        SizedBox(height: 10),
        EventTile(
          eventDetails: {},
        ),
        SizedBox(height: 10),
        EventTile(
          eventDetails: {},
        ),
      ],
    );
  }
}
