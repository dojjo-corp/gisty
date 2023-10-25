import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../components/buttons/custom_back_button.dart';

class JobDetailsPage extends StatelessWidget {
  final Map<String, dynamic> jobDetails;
  const JobDetailsPage({super.key, required this.jobDetails});

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding:
                const EdgeInsets.only(top: 100, bottom: 10, right: 20, left: 20),
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: ListView(
                children: [
                  Text(
                    jobDetails['title'],
                    style: GoogleFonts.poppins(
                        fontSize: 40, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 30),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.apartment_rounded,
                            color: Colors.grey[800],
                          ),
                          const SizedBox(width: 5),
                          Text(
                            jobDetails['company-name'],
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600, fontSize: 20),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: Colors.grey[800],
                          ),
                          const SizedBox(width: 5),
                          Text(
                            jobDetails['location'],
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                      // const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(
                            Icons.phone,
                            color: Colors.grey[800],
                          ),
                          const SizedBox(width: 5),
                          Text(
                            jobDetails['company-contacts'].join('/'),
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),
                      Text(
                        jobDetails['details'],
                        style: GoogleFonts.poppins(
                          height: 2,
                          wordSpacing: 2,
                          // fontSize: 18,
                          color: Colors.black87,
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
          const MyBackButton(),
        ],
      ),
    );
  }
}
