import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RoundProfile extends StatelessWidget {
  const RoundProfile({
    super.key,
    required this.onTap,
    required this.image,
    required this.userName,
  });
  final VoidCallback onTap;
  final String image, userName;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              child: image.isNotEmpty
                  ? Image.asset(image)
                  : Icon(
                      Icons.person_2,
                      size: 30,
                      color: Colors.yellow[800],
                    ),
            ),
            Text(
              userName,
              style: GoogleFonts.montserrat(fontSize: 12),
            )
          ],
        ),
      ),
    );
  }
}
