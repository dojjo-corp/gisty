import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gt_daily/authentication/components/page_title.dart';
import 'package:gt_daily/authentication/helper_methods.dart/global.dart';
import 'package:gt_daily/authentication/pages/administrator/user_report_details.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

import '../../components/buttons/custom_back_button.dart';
import '../../providers/user_provider.dart';

class UserReportsPage extends StatefulWidget {
  const UserReportsPage({super.key});

  @override
  State<UserReportsPage> createState() => _UserReportsPageState();
}

class _UserReportsPageState extends State<UserReportsPage> {
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const PageTitle(title: 'User Reports'),
                    StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('All Feedbacks')
                          .orderBy('time')
                          .snapshots()
                          .throttleTime(const Duration(seconds: 2)),
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

                        List<Map<String, dynamic>> allFeedbacks = [];
                        final docs = snapshot.data!.docs;

                        // fetch all reports
                        for (var doc in docs) {
                          final data = doc.data();

                          // get user data
                          final email = doc.id.split('-')[0];
                          data['complainant-data'] =
                              Provider.of<UserProvider>(context, listen: false)
                                  .getUserDataFromEmail(email);
                          data['id'] = doc.id;

                          allFeedbacks.add(data);
                        }

                        return Column(
                          children: allFeedbacks
                              .map(
                                (feedback) => GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            UserReportDetailsPage(
                                          feedbackDetails: feedback,
                                        ),
                                      ),
                                    );
                                  },
                                  child: ListTile(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side:
                                          BorderSide(color: Colors.grey[100]!),
                                    ),
                                    tileColor: Colors.grey[300],
                                    title: Text(feedback['subject']),
                                    subtitle: Text(
                                      feedback['complainant-data']['fullname'],
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(
                                        Icons.delete_rounded,
                                        color: Colors.red,
                                      ),
                                      onPressed: () async {
                                        try {
                                          await FirebaseFirestore.instance
                                              .collection('All Feedbacks')
                                              .doc(feedback['id'])
                                              .delete();
                                          if (mounted) {
                                            showSnackBar(
                                              context,
                                              'Success!',
                                            );
                                          }
                                        } catch (e) {
                                          showSnackBar(context,
                                              'Error Deleting Feedback: ${e.toString()}');
                                        }
                                      },
                                    ),
                                  ),
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
