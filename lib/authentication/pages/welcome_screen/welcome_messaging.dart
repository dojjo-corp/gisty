import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomeMessaging extends StatelessWidget {
  const WelcomeMessaging({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.message_rounded,
          color: Color.fromARGB(255, 75, 125, 200),
          size: 150,
        ),
        Text(
          'Connect and Collaborate',
          style: GoogleFonts.poppins(fontSize: 40, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          'Build a network that can help you throughout your academic and professional journey.',
          style: GoogleFonts.montserrat(
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        )
      ],
    );
  }
}
