import 'package:flutter/material.dart';
import 'package:gt_daily/authentication/components/buttons/custom_back_button.dart';
import 'package:gt_daily/authentication/components/ListTiles/jobs_tile.dart';
import 'package:gt_daily/authentication/components/page_title.dart';
import 'package:gt_daily/authentication/helper_methods.dart/global.dart';
import 'package:gt_daily/authentication/providers/user_provider.dart';
import 'package:provider/provider.dart';

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
                  const PageTitle(
                    title: 'All Jobs And Internships',
                  ),
                  StreamBuilder(
                    stream: getThrottledStream(collectionPath: 'All Jobs'),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Text('No Jobs Posted Yet');
                      }
                      if (snapshot.hasError) {
                        return Text('Error Loading Jobs: ${snapshot.error}');
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const LinearProgressIndicator();
                      }

                      /// Firestore job documents
                      final docs = snapshot.data!.docs;

                      if (docs.isEmpty) {
                        return const Center(
                          child: Text('No Job Events Yet'),
                        );
                      }

                      List<Map<String, dynamic>> jobList = [];
                      for (var doc in docs) {
                        jobList.add(doc.data());
                      }

                      return Column(
                        children: jobList
                            .map(
                              (job) => Consumer<UserProvider>(
                                builder: (context, userProvider, child) {
                                  final isUserAdmin = userProvider.isUserAdmin;
                                  return JobsTile(
                                    jobDetails: job,
                                    showSettings: isUserAdmin,
                                  );
                                },
                              ),
                            )
                            .toList(),
                      );
                    },
                  ),
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
