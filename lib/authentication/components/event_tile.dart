import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../pages/events/event_details_page.dart';

class EventTile extends StatelessWidget {
  final Map<String, dynamic> eventDetails;

  const EventTile({super.key, required this.eventDetails});

  @override
  Widget build(BuildContext context) {
    final String title = eventDetails['title'] ?? '',
        organisation = eventDetails['company-name'] ?? '',
        location = eventDetails['location'] ?? '';
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EventDetailsPage(
            eventDetails: eventDetails,
          ),
        ),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        tileColor: Colors.white70,
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
            )),
            Expanded(
                child: Text(
              location,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
            ))
          ],
        ),
      ),
    );
  }
}
