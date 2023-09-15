import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Greetings extends StatelessWidget {
  const Greetings({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Row(
        children: [
          Text(
            'Hello, ',
            style: GoogleFonts.poppins(fontSize: 25),
          ),
          Text(
            FirebaseAuth.instance.currentUser!.displayName!,
            style:
                GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 25),
          ),
        ],
      ),
    );
  }
}
