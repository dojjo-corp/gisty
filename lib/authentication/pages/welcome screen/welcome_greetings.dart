import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomeGreetings extends StatelessWidget {
  const WelcomeGreetings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon(Icons.),
            ClipRRect(
              borderRadius: BorderRadius.circular(45),
              child: Image.asset(
                'assets/ic_launcher_foreground.png',
                height: 200,
                width: 200,
                fit: BoxFit.cover,
              ),
            ),
            Text(
              'Welcome To GCTU Repo',
              style: GoogleFonts.poppins(
                  fontSize: 40, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
