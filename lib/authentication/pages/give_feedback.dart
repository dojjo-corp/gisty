import 'package:flutter/material.dart';
import 'package:gt_daily/authentication/components/buttons/buttons.dart';
import 'package:gt_daily/authentication/components/buttons/custom_back_button.dart';
import 'package:gt_daily/authentication/components/page_title.dart';
import 'package:gt_daily/authentication/components/textfields/multi_line_textfeld.dart';
import 'package:gt_daily/authentication/components/textfields/simple_textfield.dart';
import 'package:gt_daily/authentication/helper_methods.dart/global.dart';

import '../repository/firestore_repo.dart';

class GiveFeedbackPage extends StatefulWidget {
  const GiveFeedbackPage({super.key});

  @override
  State<GiveFeedbackPage> createState() => _GiveFeedbackPageState();
}

class _GiveFeedbackPageState extends State<GiveFeedbackPage> {
  bool _isLoading = false;
  final subjectController = TextEditingController();
  final descriptionController = TextEditingController();
  final repo = FirestoreRepo();
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
                  children: [
                    const PageTitle(title: 'Feedbacks & Reports'),
                    SimpleTextField(
                      controller: subjectController,
                      hintText: 'Subject',
                      iconData: Icons.subject_rounded,
                      isWithIcon: true,
                      autofillHints: null,
                    ),
                    const SizedBox(height: 15),
                    MultiLineTextField(
                      controller: descriptionController,
                      hintText: 'Description',
                      maxLines: 20,
                    ),
                    const SizedBox(height: 15),
                    MyButton(
                      onPressed: () async {
                        try {
                          setState(() {
                            _isLoading = true;
                          });
                          await repo.sendFeedback(
                            subject: subjectController.text,
                            description: descriptionController.text,
                          );
                          if (context.mounted) {
                            subjectController.clear();
                            descriptionController.clear();
                            showSnackBar(
                                context, 'Feedback Sent Successfully!');
                          }
                        } catch (e) {
                          showSnackBar(
                            context,
                            'Error Sending Feedback: ${e.toString()}',
                          );
                        } finally {
                          setState(() {
                            _isLoading = false;
                          });
                        }
                      },
                      btnText: 'Send',
                      isPrimary: true,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const MyBackButton()
        ],
      ),
      floatingActionButton: _isLoading ? const LinearProgressIndicator() : null,
    );
  }
}
