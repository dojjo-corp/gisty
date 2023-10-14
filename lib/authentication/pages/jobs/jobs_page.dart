import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gt_daily/authentication/components/custom_back_button.dart';
import 'package:gt_daily/authentication/components/jobs_tile.dart';
import 'package:gt_daily/authentication/components/page_title.dart';

class AllJobsPage extends StatelessWidget {
  const AllJobsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        Padding(
          padding:
              const EdgeInsets.only(top: 100, left: 15, right: 15, bottom: 10),
          child: SingleChildScrollView(
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: [
                  const PageTitle(title: 'All Jobs And Internships'),
                  StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('All Jobs')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Text('No Jobs Posted Yet');
                        }
                        if (snapshot.hasError) {
                          return Text('Error Loading Jobs: ${snapshot.error}');
                        }

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }

                        final docs = snapshot.data!.docs;
                        List<Map<String, dynamic>> jobList = [];
                        for (var doc in docs) {
                          jobList.add(doc.data());
                        }
                        return Column(
                          children: jobList
                              .map((job) => JobsTile(jobDetails: job))
                              .toList(),
                        );
                      }),
                ],
              ),
            ),
          ),
        ),
        const MyBackButton(),
      ]),
    );
  }
}
