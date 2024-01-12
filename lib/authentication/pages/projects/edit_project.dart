import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:gt_daily/authentication/components/buttons/buttons.dart';
import 'package:gt_daily/authentication/components/buttons/custom_back_button.dart';
import 'package:gt_daily/authentication/components/loading_circle.dart';
import 'package:gt_daily/authentication/components/textfields/multi_line_textfeld.dart';
import 'package:gt_daily/authentication/components/textfields/simple_textfield.dart';
import 'package:gt_daily/authentication/helper_methods.dart/global.dart';
import 'package:gt_daily/authentication/repository/firestore_repo.dart';

import '../../components/page_title.dart';

class EditProjectDetailsPage extends StatefulWidget {
  final String pid;
  const EditProjectDetailsPage({super.key, required this.pid});

  @override
  State<EditProjectDetailsPage> createState() => _EditProjectDetailsPageState();
}

class _EditProjectDetailsPageState extends State<EditProjectDetailsPage> {
  final titleController = TextEditingController();
  final studentNameController = TextEditingController();
  final supervisorNameController = TextEditingController();
  final supervisorEmailController = TextEditingController();
  final descriptionController = TextEditingController();
  final yearController = TextEditingController();
  final documentFileController = TextEditingController();
  late String category;
  bool _dataLoaded = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    loadProject().then((value) {
      setState(() {
        _dataLoaded = true;
        titleController.text = value['title'];
        studentNameController.text = value['student-name'];
        supervisorEmailController.text = value['supervisor-email'];
        supervisorNameController.text = value['supervisor-name'];
        yearController.text = value['year'];
        descriptionController.text = value['description'];
        documentFileController.text = value['project-document'];
        category = value['category'];
      });
    }).onError(
      (error, stackTrace) => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error', style: TextStyle(color: Colors.red)),
          content: Text(error.toString()),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Go back'),
            ),
          ],
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> loadProject({
    ConnectivityResult? connectionResult,
  }) async {
    try {
      // Throw error if device is not connected to the internet
      if (connectionResult == ConnectivityResult.none) {
        throw 'You are not connected to the internet';
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('All Projects')
          .doc(widget.pid)
          .get();
      if (!snapshot.exists) throw 'Project Details Could Not Be Found';
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
            body: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    top: 100,
                    left: 15,
                    right: 15,
                    bottom: 10,
                  ),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const PageTitle(title: 'Edit Project'),
                          Text(
                            'Title',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          SimpleTextField(
                            controller: titleController,
                            hintText: 'Title',
                            iconData: Icons.title_rounded,
                            isWithIcon: true,
                            autofillHints: null,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Student Name',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          SimpleTextField(
                            controller: studentNameController,
                            hintText: 'Student Name',
                            iconData: Icons.school_rounded,
                            isWithIcon: true,
                            autofillHints: null,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Supervisor Name',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          SimpleTextField(
                            controller: supervisorNameController,
                            hintText: 'Suprevisor Name',
                            iconData: Icons.person_pin_rounded,
                            isWithIcon: true,
                            autofillHints: null,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Supervisor Email',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          SimpleTextField(
                            controller: supervisorEmailController,
                            hintText: 'Supervisor Email',
                            iconData: Icons.mail,
                            isWithIcon: true,
                            autofillHints: null,
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
                            onPressed: updateProjectDetails,
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
            floatingActionButton:
                _isLoading ? const LinearProgressIndicator() : null,
          );
  }

  void updateProjectDetails({
    ConnectivityResult? connectionResult,
  }) async {
    setState(() {
      _isLoading = true;
    });
    try {
      // Throw error if device is not connected to the internet
      if (connectionResult == ConnectivityResult.none) {
        throw 'You are not connected to the internet';
      }
      final projectDetails = {
        'title': titleController.text,
        'year': yearController.text,
        'student-name': studentNameController.text,
        'category': category,
        'supervisor-name': supervisorNameController.text.trim(),
        'supervisor-email': supervisorEmailController.text.trim(),
        'description': descriptionController.text.trim(),
      };

      /// Update job details in firestore
      await FirestoreRepo()
          .updateProjectDetails(projectDetails: projectDetails, id: widget.pid);
      if (mounted) {
        showSnackBar(
          context,
          'Success!',
        );
        Navigator.pop(context);
      }
    } catch (e) {
      showSnackBar(context, 'Error updating project details: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
