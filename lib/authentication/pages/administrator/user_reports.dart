import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gt_daily/authentication/components/page_title.dart';
import 'package:provider/provider.dart';

import '../../components/buttons/custom_back_button.dart';
import '../../providers/user_provider.dart';

class UserReportsPage extends StatelessWidget {
  const UserReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: 100,
              left: 15,
              right: 15,
              bottom: 10,
            ),
            child: SingleChildScrollView(
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: Column(
                  children: [
                    const PageTitle(title: 'User Reports'),
                    StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('All Feedbacks')
                          .snapshots(),
                      builder: (context, snapshot) {
                        // snapshot has no data
                        if (!snapshot.hasData) {
                          return const Center(
                            child: Text('No Report Yet'),
                          );
                        }

                        // error loading snapshot form firestore
                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                                'Error Loading Reports: ${snapshot.error}'),
                          );
                        }

                        final allFeedbacks = [];
                        final docs = snapshot.data!.docs;

                        // fetch all reports
                        for (var doc in docs) {
                          final data = doc.data();

                          // get user data
                          final email = doc.id.split('-')[0];
                          data['complainant-data'] =
                              Provider.of<UserProvider>(context, listen: false)
                                  .getUserDataFromEmail(email);

                          allFeedbacks.add(data);
                        }

                        return Column(
                          children: allFeedbacks
                              .map(
                                (feedback) => ListTile(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(color: Colors.grey[100]!),
                                  ),
                                  tileColor: Colors.grey[300],
                                  title: Text(feedback['subject']),
                                  subtitle: Text(
                                      feedback['complainant-data']['fullname']),
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
        ],
      ),
    );
  }
}
