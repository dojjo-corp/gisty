import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gt_daily/authentication/components/custom_back_button.dart';

class EventDetailsPage extends StatelessWidget {
  final Map<String, dynamic> eventDetails;
  const EventDetailsPage({super.key, required this.eventDetails});

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
                    eventDetails['title'],
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
                            eventDetails['company-name'],
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
                            eventDetails['location'],
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
                            eventDetails['company-contacts'].join('/'),
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
                        eventDetails['details'],
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
          const Positioned(
            top: 40,
            left: 5,
            child: MyBackButton(),
          ),
        ],
      ),
    );
  }
}
