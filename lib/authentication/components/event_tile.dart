import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EventTile extends StatelessWidget {
  final String title, organisation, location;
  const EventTile({
    super.key,
    required this.title,
    required this.organisation,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      tileColor: Colors.white70,
      leading: const Icon(Icons.event, color: Colors.yellow,),
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
    );
  }
}
