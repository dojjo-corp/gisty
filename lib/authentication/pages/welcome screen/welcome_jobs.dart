import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../components/buttons.dart';

class WelcomeJobs extends StatelessWidget {
  const WelcomeJobs({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.assured_workload_rounded,
          color: Theme.of(context).primaryColor.withOpacity(0.5),
          size: 150,
        ),
        Text(
          'Shape Your Future Today',
          style: GoogleFonts.poppins(fontSize: 40, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          'Explore a wide range of job openings and internships relevant to your field of study. Your dream job might be just a click away!',
          style: GoogleFonts.montserrat(
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 50),
        Row(mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(
              width: 150,
              child: MyButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                btnText: 'Join Us!',
                isPrimary: true,
              ),
            ),
          ],
        )
      ],
    );
  }
}
