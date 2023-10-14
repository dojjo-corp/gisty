import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gt_daily/authentication/components/custom_back_button.dart';
import 'package:gt_daily/authentication/components/my_textfield.dart';

import '../../components/buttons.dart';
import '../../components/multi_line_textfeld.dart';
import '../../repository/firestore_repo.dart';

class AddNewEventPage extends StatefulWidget {
  const AddNewEventPage({super.key});

  @override
  State<AddNewEventPage> createState() => _AddNewEventPageState();
}

class _AddNewEventPageState extends State<AddNewEventPage> {
  // MODAL BOTTOM SHEET STATE VARIABLES
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(
              top: 100.0, left: 15, right: 15, bottom: 10),
          child: SingleChildScrollView(
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: [
                  Text(
                    'Add New Event',
                    style: GoogleFonts.montserrat(
                        fontSize: 40, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),

                  // JOB TITLE TEXT FIELD
                  MyTextField(autofillHints: null,
                    controller: jobTitleController,
                    hintText: 'Job Title',
                    iconData: Icons.school_rounded,
                    isWithIcon: true,
                  ),
                  const SizedBox(height: 10),

                  // LOCATION TEXTFIELD
                  MyTextField(autofillHints: null,
                    controller: locationController,
                    hintText: 'Location',
                    iconData: Icons.location_on_rounded,
                    isWithIcon: true,
                  ),
                  const SizedBox(height: 10),

                  // COMPANY NAME
                  MyTextField(autofillHints: null,
                    controller: companyNameController,
                    hintText: 'Company Name',
                    iconData: Icons.assured_workload_outlined,
                    isWithIcon: true,
                  ),

                  const SizedBox(height: 10),

                  // LOCATION TEXT FIELD
                  MyTextField(autofillHints: null,
                    controller: contactController,
                    hintText: 'Contact',
                    iconData: Icons.phone_rounded,
                    isWithIcon: true,
                  ),
                  const SizedBox(height: 10),

                  // JOB CATEGORY DROPDOWN MENU
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

                  // JOB DESCRIPTION TEXTFIELD
                  MultiLineTextField(
                    controller: descriptionController,
                    hintText: 'Description',
                    maxLines: 6,
                  ),
                  const SizedBox(height: 10),
                  MyButton(
                    onPressed: () async {
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
                      final Map<String, dynamic> eventDetails = {
                        'id': id,
                        'title': jobTitleController.text.trim(),
                        'company-name': companyNameController.text.trim(),
                        'location': locationController.text.trim(),
                        'company-contacts': contacts,
                        'details': descriptionController.text.trim(),
                      };

                      // store job event in firestore
                      try {
                        await FirestoreRepo()
                            .addJobsOrIntershipEvents(eventDetails);
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('Error Adding Event: ${e.toString()}'),
                          ),
                        );
                      }
                    },
                    btnText: 'Add Event',
                    isPrimary: true,
                  )
                ],
              ),
            ),
          ),
        ),
        const MyBackButton()
      ],
    ));
  }
}
