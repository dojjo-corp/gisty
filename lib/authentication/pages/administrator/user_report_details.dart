import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gt_daily/authentication/components/buttons/custom_back_button.dart';
import 'package:gt_daily/authentication/components/page_title.dart';
import 'package:gt_daily/authentication/helper_methods.dart/profile.dart';
import 'package:gt_daily/authentication/pages/user%20account/other_user_account_page.dart';
import 'package:gt_daily/authentication/providers/user_provider.dart';
import 'package:provider/provider.dart';

class UserReportDetailsPage extends StatelessWidget {
  final Map<String, dynamic> feedbackDetails;
  const UserReportDetailsPage({
    super.key,
    required this.feedbackDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(
                top: 100, left: 15, right: 15, bottom: 10),
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PageTitle(title: feedbackDetails['subject']),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Reported By: '),
                        Consumer<UserProvider>(
                            builder: (context, userProvider, child) {
                          final otherUserData =
                              userProvider.getUserDataFromEmail(
                                  feedbackDetails['complainant']);

                          final uid = otherUserData!['uid'];
                          final downloadUrl = otherUserData['profile-picture'];

                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: showOtherUserProfilePicture(
                                uid, downloadUrl, context, 30),
                            title: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => OtherUserAccountPage(
                                      otherUserEmail:
                                          feedbackDetails['complainant-data']
                                              ['email'],
                                    ),
                                  ),
                                );
                              },
                              child: Text(
                                feedbackDetails['complainant-data']['fullname'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            subtitle: Text(otherUserData['user-type']),
                          );
                        })
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Feedback Details',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 25,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(feedbackDetails['description'])
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
