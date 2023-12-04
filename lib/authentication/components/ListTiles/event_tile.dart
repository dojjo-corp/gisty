import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gt_daily/authentication/helper_methods.dart/global.dart';

import '../../pages/events/edit_event.dart';
import '../../pages/events/event_details_page.dart';

class EventTile extends StatelessWidget {
  final Map<String, dynamic> eventDetails;
  final bool showSettings;
  EventTile({
    super.key,
    required this.eventDetails,
    required this.showSettings,
  });

  final store = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final String title = eventDetails['title'] ?? '',
        organisation = eventDetails['organizers'] ?? '',
        location = eventDetails['location'] ?? '';
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EventDetailsPage(
            eventId: eventDetails['id'],
          ),
        ),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey[100]!),
        ),
        tileColor: Colors.grey[300],
        leading: const Icon(
          Icons.event,
          color: Colors.yellow,
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        subtitle: Row(
          children: [
            Expanded(
              child: Text(
                organisation,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              child: Text(
                location,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
              ),
            )
          ],
        ),
        trailing: showSettings
            ? IconButton(
                onPressed: () async {
                  await showOptions(context);
                },
                icon: const Icon(
                  Icons.settings_rounded,
                  color: Colors.grey,
                ),
              )
            : null,
      ),
    );
  }

  /// CONVENIENCE METHODS
  Future<void> showOptions(BuildContext context) async {
    showGeneralDialog(
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) => SimpleDialog(
        backgroundColor: Colors.grey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        children: [
          /// Edit Button
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      EditEventDetailsPage(eventId: eventDetails['id']),
                ),
              );
            },
            child: const Text(
              'Edit',
              style: TextStyle(color: Colors.white),
            ),
          ),

          /// Delete Button
          TextButton(
            onPressed: () async {
              await deleteEvent(context);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> deleteEvent(BuildContext context,
      {ConnectivityResult? connectionResult}) async {
    final id = eventDetails['id'];
    log(id);
    try {
      // Throw error if device is not connected to the internet
      if (connectionResult == ConnectivityResult.none) {
        throw 'You are not connected to the internet';
      }
      final Reference eventFilesRef =
          FirebaseStorage.instance.ref().child('/Event Files/$id}');

      /// The list of all files (images) in the event's folder
      ListResult listResult = await eventFilesRef.listAll();
      for (Reference ref in listResult.items) {
        await ref.delete();
      }
      await store.collection('All Events').doc(id).delete();

      // show success message
      if (context.mounted) {
        showSnackBar(context, 'Success!');
        Navigator.pop(context);
      }
    } catch (e) {
      showSnackBar(context, 'Error Deleting Event Files: ${e.toString()}');
    }
  }
}
