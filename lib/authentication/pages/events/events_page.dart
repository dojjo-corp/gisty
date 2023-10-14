import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../components/event_tile.dart';
import '../../components/loading_list_tiles.dart';
import '../../providers/user_provider.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  Color prefixIconColorTitle = Colors.grey;
  Color prefixIconColorName = Colors.grey;
  Color prefixIconColorLocation = Colors.grey;

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      StreamBuilder(
          stream:
              FirebaseFirestore.instance.collection('All Events').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: Text('No Job Events Yet'),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('Error Loading Data: ${snapshot.error}'),
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingListTiles();
            }

            final docs = snapshot.data!.docs;
            List<Map<String, dynamic>> eventList = [];
            for (var doc in docs) {
              eventList.add(doc.data());
            }

            return ListView.separated(
              itemCount: eventList.length,
              itemBuilder: (context, index) {
                return EventTile(
                  eventDetails: eventList[index],
                );
              },
              separatorBuilder: (context, index) {
                return const SizedBox(height: 3);
              },
            );
          }),
      Provider.of<UserProvider>(context).userType != 'student'
          ? Positioned(
              bottom: 10,
              right: 10,
              child: FloatingActionButton(
                backgroundColor:
                    Theme.of(context).primaryColor.withOpacity(0.5),
                onPressed: () {
                  Navigator.pushNamed(context, '/new-event');
                },
                child: const Icon(Icons.add),
              ),
            )
          : const Text(''),
    ]);
  }
}
