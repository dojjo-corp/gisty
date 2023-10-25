import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../pages/jobs/job_details.dart';

class JobsTile extends StatelessWidget {
  final Map<String, dynamic> jobDetails;

  const JobsTile({super.key, required this.jobDetails});

  @override
  Widget build(BuildContext context) {
    final String title = jobDetails['title'] ?? '',
        organisation = jobDetails['company-name'] ?? '',
        location = jobDetails['location'] ?? '';
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => JobDetailsPage(
            jobDetails: jobDetails,
          ),
        ),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey[100]!),
        ),
        tileColor: Colors.grey[300],
        leading: Icon(
          Icons.assured_workload_rounded,
          color: Colors.yellow[800],
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
