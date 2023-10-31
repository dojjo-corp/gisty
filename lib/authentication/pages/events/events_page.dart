import 'package:flutter/material.dart';
import 'package:gt_daily/authentication/helper_methods.dart/global.dart';
import 'package:provider/provider.dart';

import '../../components/ListTiles/event_tile.dart';
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
        stream: getThrottledStream(collectionPath: 'All Events'),
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

          /// Firestore job documents
          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(
              child: Text('No Job Events Yet'),
            );
          }
          
          List<Map<String, dynamic>> eventList = [];
          for (var doc in docs) {
            eventList.add(doc.data());
          }

          return Consumer<UserProvider>(
            builder: (context, userProvider, child) {
              final isuserAdmin = userProvider.isUserAdmin;

              return ListView.separated(
                itemCount: eventList.length,
                itemBuilder: (context, index) {
                  return EventTile(
                    eventDetails: eventList[index],
                    showSettings: isuserAdmin,
                  );
                },
                separatorBuilder: (context, index) {
                  return const SizedBox(height: 3);
                },
              );
            },
          );
        },
      ),
      Provider.of<UserProvider>(context, listen: false).userType != 'student'
          ? Positioned(
              bottom: 10,
              right: 10,
              child: FloatingActionButton(
                backgroundColor: const Color.fromARGB(255, 75, 125, 200),
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
