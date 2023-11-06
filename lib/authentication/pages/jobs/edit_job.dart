import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gt_daily/authentication/components/buttons/buttons.dart';
import 'package:gt_daily/authentication/components/loading_circle.dart';
import 'package:gt_daily/authentication/components/textfields/multi_line_textfeld.dart';
import 'package:gt_daily/authentication/components/textfields/simple_textfield.dart';
import 'package:gt_daily/authentication/helper_methods.dart/global.dart';
import 'package:gt_daily/authentication/pages/jobs/jobs_page.dart';
import 'package:gt_daily/authentication/repository/firestore_repo.dart';

import '../../components/buttons/custom_back_button.dart';
import '../../components/page_title.dart';

class EditJobDetailsPage extends StatefulWidget {
  final String jobId;
  const EditJobDetailsPage({super.key, required this.jobId});

  @override
  State<EditJobDetailsPage> createState() => _EditJobDetailsPageState();
}

class _EditJobDetailsPageState extends State<EditJobDetailsPage> {
  /// textEditingControllers
  final jobTitleController = TextEditingController();
  final companyNameController = TextEditingController();
  final locationController = TextEditingController();
  final contactController = TextEditingController();
  final descriptionController = TextEditingController();
  late String selectedJobType;
  final List<String> jobTypes = [
    'Internship',
    'Full Time',
    'Part Time',
    'Contract',
  ];
  late String deadline;
  bool _dataLoaded = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    loadJobDetails().then((value) {
      setState(() {
        _dataLoaded = true;
        jobTitleController.text = value['title'];
        companyNameController.text = value['company-name'];
        locationController.text = value['location'];
        deadline = value['deadline'];
        descriptionController.text = value['details'];
        contactController.text = value['company-contacts'].join(', ');
        selectedJobType = value['job-type'];
      });
    }).onError(
      (error, stackTrace) => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error!'),
          content: Text(error.toString()),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AllJobsPage(),
                  ),
                );
              },
              child: const Text('Go back'),
            )
          ],
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> loadJobDetails() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('All Jobs')
          .doc(widget.jobId)
          .get();
      if (!snapshot.exists) throw 'Job Details Not Found';
      return snapshot.data()!;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return !_dataLoaded
        ? const LoadingCircle()
        : Scaffold(
            floatingActionButton:
                _isLoading ? const LinearProgressIndicator() : null,
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
                          const PageTitle(title: 'Edit Job'),
                          Text(
                            'Job Title',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          SimpleTextField(
                            controller: jobTitleController,
                            hintText: 'Job Title',
                            iconData: Icons.work_rounded,
                            isWithIcon: true,
                            autofillHints: null,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Company Name',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          SimpleTextField(
                            controller: companyNameController,
                            hintText: 'Company Name',
                            iconData: Icons.assured_workload_rounded,
                            isWithIcon: true,
                            autofillHints: null,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Location',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          SimpleTextField(
                            controller: locationController,
                            hintText: 'Location',
                            iconData: Icons.location_on_rounded,
                            isWithIcon: true,
                            autofillHints: null,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Contacts',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          SimpleTextField(
                            controller: contactController,
                            hintText: 'Contacts',
                            iconData: Icons.phone_rounded,
                            isWithIcon: true,
                            autofillHints: null,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Job Type',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          DropdownButtonFormField(
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(12),
                              ),
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
                          const SizedBox(height: 5),
                          Text(
                            'Description',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          MultiLineTextField(
                            controller: descriptionController,
                            hintText: 'Description',
                            maxLines: 20,
                          ),
                          const SizedBox(height: 20),
                          MyButton(
                            onPressed: uploadJobChanges,
                            btnText: 'Save Changes',
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
          );
  }

  void uploadJobChanges() async {
    setState(() {
      _isLoading = true;
    });
    try {
      List<String> contacts;
      if (contactController.text.characters.contains(',')) {
        contacts = contactController.text.trim().split(',');
      } else if (contactController.text.characters.contains('/')) {
        contacts = contactController.text.trim().split('/');
      } else {
        contacts = [contactController.text.trim()];
      }

      final data = {
        'title': jobTitleController.text.trim(),
        'company-name': companyNameController.text.trim(),
        'location': locationController.text.trim(),
        'company-contacts': contacts,
        'details': descriptionController.text.trim(),
        'job-type': selectedJobType,
        'deadline': deadline
      };

      await FirestoreRepo()
          .updateJobDetails(id: widget.jobId, jobDetails: data);

      if (mounted) {
        showSnackBar(
          context,
          'Success!',
        );
        Navigator.pop(context);
      }
    } catch (e) {
      showSnackBar(
        context,
        'Error Updating Job Details: ${e.toString()}',
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
