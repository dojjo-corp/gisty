import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:gt_daily/authentication/helper_methods.dart/global.dart';
import 'package:gt_daily/authentication/repository/firebase_messaging.dart';
import 'package:path/path.dart';

import '../models/project_model.dart';
import '../repository/firestore_repo.dart';

final messaging = FireMessaging();
final store = FirebaseFirestore.instance;

// todo: upload project document to firebase storage
Future<void> uploadPDF(
    {required File file, ConnectivityResult? connectionResult}) async {
  try {
    // Throw error if device is not connected to the internet
    if (connectionResult == ConnectivityResult.none) {
      throw 'You are not connected to the internet';
    }
    String fileName = basename(file.path);
    Reference storageReference =
        FirebaseStorage.instance.ref().child('Project Documents/$fileName');
    await storageReference.putFile(file);
  } catch (e) {
    rethrow;
  }
}

// todo: send project to firestore
Future<void> addProjectToDatabase(
    {required BuildContext context,
    required String selectedCategory,
    required isLoading,
    required TextEditingController projectDocumentFileNameController,
    required TextEditingController projectTitleController,
    required TextEditingController yearController,
    required TextEditingController studentController,
    required TextEditingController descriptionController,
    required TextEditingController supervisorController,
    required TextEditingController supervisorEmailController,
    String? absolutePathToDocument,
    ConnectivityResult? connectionResult}) async {
  final projectObj = ProjectModel(
    title: projectTitleController.text.trim(),
    year: yearController.text.trim(),
    studentName: studentController.text.trim(),
    description: descriptionController.text.trim(),
    category: selectedCategory,
    supervisorName: supervisorController.text.trim(),
    supervisorEmail: supervisorEmailController.text,
    projectDocumentFileName: projectDocumentFileNameController.text,
  );

  // store job event in firestore
  try {
    // Throw error if device is not connected to the internet
    if (connectionResult == ConnectivityResult.none) {
      throw 'You are not connected to the internet';
    }
    await uploadPDF(file: File(absolutePathToDocument!));
    await FirestoreRepo().addProjectToDatabase(projectData: projectObj.toMap());

    // todo: send notification to all users
    FireMessaging().sendPushNotifiationToAllUsers(
      title: 'New Project In $selectedCategory',
      body: projectTitleController.text.trim(),
      type: 'project',
      routeName: '/project-details',
      routeArgs: {'project-data': projectObj.toMap()},
    );

    if (context.mounted) {
      showSnackBar(context, 'Project Added Successfully!');
      Navigator.pop(context);
    }
  } catch (e) {
    rethrow;
  }
}

// todo: show caution dialog
void showCautionDialog(BuildContext context, String cautionText) {
  showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Caution'),
        content: Text(cautionText),
        actions: <Widget>[
          TextButton(
            child: const Text('Okay'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

// todo: choose project document
Future<FilePickerResult?> choosePDFFile() async {
  return await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['pdf'],
  );
}

// todo: comment on project
void sendComment({
  required GlobalKey<FormFieldState<dynamic>> key,
  required TextEditingController commentController,
  required String pid,
  required BuildContext context,
  ConnectivityResult? connectionResult
}) async {
  // Only send non-empty comments
  if (commentController.text.isNotEmpty) {
    try {
       // Throw error if device is not connected to the internet
    if (connectionResult == ConnectivityResult.none) {
      throw 'You are not connected to the internet';
    }
      key.currentState!.save();
      final commentData = {
        'commenter': FirebaseAuth.instance.currentUser!.email!,
        'comment-text': commentController.text,
        'timestamp': Timestamp.now(),
      };
      commentController.clear();
      await store.collection('All Projects').doc(pid).update({
        'comments': FieldValue.arrayUnion([commentData])
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sending comment: ${e.toString()}'),
        ),
      );
    }
  }
}
