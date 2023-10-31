import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../helper_methods.dart/global.dart';
import '../../pages/jobs/job_details.dart';

class JobsTile extends StatelessWidget {
  final Map<String, dynamic> jobDetails;
  final bool showSettings;

  JobsTile({super.key, required this.jobDetails, required this.showSettings});

  final store = FirebaseFirestore.instance;

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
            jobId: jobDetails['id'],
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
              ),
            ),
            Expanded(
              child: Text(
                location,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
              ),
            )
          ],
        ),
        trailing: showSettings
            ? IconButton(
                onPressed: () async {
                  await showOptions(context);
                },
                icon: const Icon(
                  Icons.settings_rounded,
                  color: Colors.grey,
                ),
              )
            : null,
      ),
    );
  }

  Future<void> showOptions(BuildContext context) async {
    showGeneralDialog(
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) => SimpleDialog(
        backgroundColor: Colors.grey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        children: [
          /// Edit Button
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => JobDetailsPage(jobId: jobDetails['id']),
                ),
              );
            },
            child: const Text(
              'Edit',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),

          /// Delete Button
          TextButton(
            onPressed: () async {
              await deleteEvent(context);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> deleteEvent(BuildContext context) async {
    final id = jobDetails['id'];
    try {
      final Reference eventFilesRef =
          FirebaseStorage.instance.ref().child('Job Files/$id}');
      await eventFilesRef.delete();
      await store.collection('All Jobs').doc(id).delete();

      // show success message
      if (context.mounted) {
        showSnackBar(context, 'Success!');
      }
    } catch (e) {
      showSnackBar(context, 'Error Deleting Event Files: ${e.toString()}');
    }
  }
}
