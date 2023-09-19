import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gt_daily/authentication/repository/firestore_repo.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart';

import '../components/buttons.dart';
import '../components/custom_back_button.dart';
import '../models/project_model.dart';

class NewProjectPage extends StatefulWidget {
  const NewProjectPage({super.key});

  @override
  State<NewProjectPage> createState() => _NewProjectPageState();
}

class _NewProjectPageState extends State<NewProjectPage> {
  final projectTitleController = TextEditingController();
  final yearController = TextEditingController();
  final studentController = TextEditingController();
  final supervisorController = TextEditingController();
  final descriptionController = TextEditingController();
  final projectDocumentFileNameController = TextEditingController();
  String selectedCategory = 'Project Category';
  final List<String> categories = [
    'Project Category',
    'Web',
    'Mobile',
    'Data',
    'Hardware'
  ];

  // to be ued in file upload method
  String absolutePathToDocument = '';

  @override
  Widget build(BuildContext context) {
    Future<void> uploadPDF(File file) async {
      try {
        String fileName = basename(file.path);
        Reference storageReference =
            FirebaseStorage.instance.ref().child('Project Documents/$fileName');
        await storageReference.putFile(file);
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF Uploaded Successfully!'),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error Uploading PDf: ${e.toString()}'),
          ),
        );
      }
    }

    void addProjectToDatabase() async {
      if (selectedCategory == 'Project Category') {
        return showDialog<void>(
          context: context,
          barrierDismissible: false, // user must tap button!
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Caution'),
              content: Text('Choose A Valid Project Category!'),
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
      if (projectDocumentFileNameController.text.isEmpty){
        return showDialog<void>(
          context: context,
          barrierDismissible: false, // user must tap button!
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Caution'),
              content: Text('Choose A Project Document!'),
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
      final projectObj = ProjectModel(
        title: projectTitleController.text.trim(),
        year: yearController.text.trim(),
        studentName: studentController.text.trim(),
        description: descriptionController.text.trim(),
        category: selectedCategory,
        supervisorName: supervisorController.text.trim(),
        projectDocumentFileName: projectDocumentFileNameController.text,
      );

      // store job event in firestore
      try {
        await uploadPDF(File(absolutePathToDocument));
        await FirestoreRepo()
            .addProjectToDatabase(projectData: projectObj.toMap());
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Project Added Successfully!'),
          ),
        );
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error Adding Project: ${e.toString()}'),
          ),
        );
      }
    }

    Future<void> choosePDFFile() async {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (result != null) {
        final path = result.files.single.path!;
        setState(() {
          absolutePathToDocument = path;
          projectDocumentFileNameController.text = basename(path);
        });
      } else {
        // User canceled the file picker
      }
    }

    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
              child: SingleChildScrollView(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Add New Project',
                        style: GoogleFonts.poppins(
                            fontSize: 40, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 30),
                      // JOB TITLE TEXT FIELD
                      TextFormField(
                        controller: projectTitleController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.title_rounded),
                          hintText: 'Project Title',
                          labelText: 'Project Title',
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Field can\'t be empty!';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: studentController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.school_rounded),
                          hintText: 'Student Name',
                          labelText: 'Student Name',
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Field can\'t be empty!';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      // COMPANY NAME TEXT FIELD
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: yearController,
                              keyboardType: TextInputType.datetime,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon:
                                    const Icon(Icons.calendar_month_rounded),
                                hintText: 'Year',
                                labelText: 'Year',
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9]'),
                                ), // Allow only numbers
                                LengthLimitingTextInputFormatter(4)
                              ],
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Field can\'t be empty!';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: DropdownButtonFormField(
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              value: selectedCategory,
                              items: categories
                                  .map(
                                    (String category) =>
                                        DropdownMenuItem<String>(
                                      value: category,
                                      child: Text(category),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedCategory = value!;
                                });
                              },
                            ),
                          )
                        ],
                      ),

                      const SizedBox(height: 10),
                      // LOCATION TEXT FIELD
                      TextFormField(
                        controller: supervisorController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon:
                              const Icon(Icons.perm_contact_calendar_rounded),
                          hintText: 'Supervisor',
                          labelText: 'Supervisor',
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Field can\'t be empty!';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: descriptionController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.edit_note_rounded),
                          hintText: 'Short Description',
                          labelText: 'Short Description',
                        ),
                        maxLines: 3,
                        minLines: 1,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Field can\'t be empty!';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: projectDocumentFileNameController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.file_present_rounded),
                          hintText: 'Project Document File Name',
                          enabled: false,
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Field can\'t be empty!';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 10),
                      MyButton(
                        onPressed: choosePDFFile,
                        btnText: 'Choose Project Document',
                        isPrimary: false,
                      ),
                      const SizedBox(height: 20),
                      MyButton(
                        onPressed: addProjectToDatabase,
                        btnText: 'Add Project',
                        isPrimary: true,
                      )
                    ],
                  ),
                ),
              ),
            ),
            const Positioned(top: 20, left: 20, child: MyBackButton())
          ],
        ),
      ),
    );
  }
}
