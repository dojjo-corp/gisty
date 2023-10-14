import 'package:flutter/material.dart';
import 'package:gt_daily/authentication/components/multi_line_textfeld.dart';

import '../../components/buttons.dart';
import '../../components/custom_back_button.dart';
import '../../components/my_textfield.dart';
import '../../components/page_title.dart';
import '../../repository/firestore_repo.dart';

class AddJobOrInternship extends StatefulWidget {
  const AddJobOrInternship({super.key});

  @override
  State<AddJobOrInternship> createState() => _AddJobOrInternshipState();
}

class _AddJobOrInternshipState extends State<AddJobOrInternship> {
  final jobTitleController = TextEditingController();
  final companyNameController = TextEditingController();
  final locationController = TextEditingController();
  final descriptionController = TextEditingController();
  final contactController = TextEditingController();
  String selectedJobType = 'Internship';
  final List<String> jobTypes = [
    'Internship',
    'Full Time',
    'Part Time',
    'Contract',
  ];

  Color prefixIconColorTitle = Colors.grey;
  Color prefixIconColorName = Colors.grey;
  Color prefixIconColorLocation = Colors.grey;

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(
                top: 100.0, left: 15, right: 15, bottom: 15),
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: SingleChildScrollView(
                  child: Column(
                children: [
                  const PageTitle(title: 'Add Job Opportunity'),
                  MyTextField(
                    autofillHints: null,
                    controller: jobTitleController,
                    hintText: 'Job Title',
                    iconData: Icons.school_rounded,
                    isWithIcon: true,
                  ),
                  const SizedBox(height: 10),
                  MyTextField(
                    autofillHints: null,
                    controller: companyNameController,
                    hintText: 'Company Name',
                    iconData: Icons.assured_workload_outlined,
                    isWithIcon: true,
                  ),
                  const SizedBox(height: 10),
                  MyTextField(
                    autofillHints: null,
                    controller: locationController,
                    hintText: 'Location',
                    iconData: Icons.location_on_rounded,
                    isWithIcon: true,
                  ),
                  const SizedBox(height: 10),
                  MyTextField(
                    autofillHints: null,
                    controller: contactController,
                    hintText: 'Contact(s)',
                    iconData: Icons.phone_rounded,
                    isWithIcon: true,
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    value: selectedJobType,
                    items: jobTypes
                        .map(
                          (String category) => DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedJobType = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  MultiLineTextField(
                    controller: descriptionController,
                    hintText: 'Description',
                    maxLines: 5,
                  ),
                  const SizedBox(height: 20),
                  MyButton(
                    onPressed: () async {
                      setState(() {
                        _isLoading = true;
                      });
                      List<String> contacts;
                      if (contactController.text.characters.contains(',')) {
                        contacts = contactController.text.trim().split(',');
                      } else if (contactController.text.characters
                          .contains('/')) {
                        contacts = contactController.text.trim().split('/');
                      } else {
                        contacts = [contactController.text.trim()];
                      }
                      final id =
                          '$selectedJobType${companyNameController.text}${jobTitleController.text}${descriptionController.text.characters.takeLast(10)}';
                      final Map<String, dynamic> jobDetails = {
                        'id': id,
                        'title': jobTitleController.text.trim(),
                        'company-name': companyNameController.text.trim(),
                        'location': locationController.text.trim(),
                        'company-contacts': contacts,
                        'details': descriptionController.text.trim(),
                      };

                      // store job event in firestore
                      try {
                        await FirestoreRepo().addJobsOrIntershipEvents(jobDetails);
                        setState(() {
                          _isLoading = false;
                        });
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text('Job Posted Successfully'),
                        ));
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Error Adding Event: ${e.toString()}'),
                        ));
                      } finally {
                        setState(() {
                          _isLoading = false;
                        });
                      }
                    },
                    btnText: 'Add Job',
                    isPrimary: true,
                  )
                ],
              )),
            ),
          ),
          const MyBackButton()
        ],
      ),
      floatingActionButton:
          _isLoading ? const CircularProgressIndicator() : Container(),
    );
  }
}
