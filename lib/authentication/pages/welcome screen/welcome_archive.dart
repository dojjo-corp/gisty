import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomeArchive extends StatelessWidget {
  const WelcomeArchive({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.archive_rounded,
          color: Theme.of(context).primaryColor.withOpacity(0.5),
          size: 150,
        ),
        Text(
          'Showcase Your Achievements',
          style: GoogleFonts.poppins(fontSize: 40, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          'Your hard work deserves recognition. Get your projects showcased to peers, professors, and potential employers.',
          style: GoogleFonts.montserrat(
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        )
      ],
    );
  }
}
