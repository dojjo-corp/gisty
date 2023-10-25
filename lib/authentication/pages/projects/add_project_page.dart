import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gt_daily/authentication/components/textfields/multi_line_textfeld.dart';
import 'package:path/path.dart';
// ignore: depend_on_referenced_packages
import 'package:provider/provider.dart';

import '../../components/buttons/buttons.dart';
import '../../components/buttons/custom_back_button.dart';
import '../../components/textfields/simple_textfield.dart';
import '../../helper_methods.dart/projects.dart';
import '../../providers/projects_provider.dart';
import '../../repository/firebase_messaging.dart';

class NewProjectPage extends StatefulWidget {
  const NewProjectPage({super.key});

  @override
  State<NewProjectPage> createState() => _NewProjectPageState();
}

class _NewProjectPageState extends State<NewProjectPage> {
  final messaging = FireMessaging();
  bool _isLoading = false;
  final projectTitleController = TextEditingController();
  final yearController = TextEditingController();
  final studentController = TextEditingController();
  final supervisorController = TextEditingController();
  final supervisorEmailController = TextEditingController();
  final descriptionController = TextEditingController();
  final projectDocumentFileNameController = TextEditingController();
  String selectedCategory = 'Project Category';
  Color yearIconColor = Colors.grey;

  // to be ued in file upload method
  String absolutePathToDocument = '';

  @override
  Widget build(BuildContext context) {
    final projectCategories =
        context.watch<ProjectProvider>().categoryMap.keys.toList();

    final List<String> categories = ['Project Category'];
    categories.addAll(projectCategories);

    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              right: 15.0,
              left: 15,
              top: 100,
              bottom: 10,
            ),
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: SingleChildScrollView(
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
                    SimpleTextField(
                      controller: projectTitleController,
                      hintText: 'Project Title',
                      iconData: Icons.title_rounded,
                      isWithIcon: true,
                      autofillHints: null,
                    ),
                    const SizedBox(height: 10),
                    SimpleTextField(
                      controller: studentController,
                      hintText: 'Student Name',
                      iconData: Icons.school_rounded,
                      isWithIcon: true,
                      autofillHints: null,
                    ),
                    const SizedBox(height: 10),
                    // COMPANY NAME TEXT FIELD
                    TextFormField(
                      controller: yearController,
                      keyboardType: TextInputType.datetime,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: Icon(
                          Icons.calendar_month_rounded,
                          color: yearIconColor,
                        ),
                        hintText: 'Year',
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
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          setState(() {
                            yearIconColor = Theme.of(context).primaryColor;
                          });
                        } else {
                          setState(() {
                            yearIconColor = Colors.grey;
                          });
                        }
                      },
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
                      value: selectedCategory,
                      items: categories
                          .map(
                            (String category) => DropdownMenuItem<String>(
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

                    const SizedBox(height: 10),
                    // SUPERVISOR NAME TEXT FIELD
                    SimpleTextField(
                      controller: supervisorController,
                      hintText: 'Supervisor Name',
                      iconData: Icons.person_pin_rounded,
                      isWithIcon: true,
                      autofillHints: null,
                    ),
                    const SizedBox(height: 10),
                    // SUPERVISOR EMAIL TEXT FIELD
                    SimpleTextField(
                      controller: supervisorEmailController,
                      hintText: 'Supervisor Email',
                      iconData: Icons.mail,
                      isWithIcon: true,
                      autofillHints: null,
                    ),
                    const SizedBox(height: 10),
                    MultiLineTextField(
                      controller: descriptionController,
                      hintText: 'Project Description',
                      maxLines: 5,
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
                    ),

                    const SizedBox(height: 10),

                    // BUTTONS
                    MyButton(
                      onPressed: () async {
                        final result = await choosePDFFile();
                        if (result != null) {
                          final path = result.files.single.path!;
                          setState(() {
                            absolutePathToDocument = path;
                            projectDocumentFileNameController.text =
                                basename(path);
                          });
                        } else {
                          // User canceled the file picker
                        }
                      },
                      btnText: 'Choose Project Document',
                      isPrimary: false,
                    ),
                    const SizedBox(height: 20),
                    MyButton(
                      onPressed: () async {
                        if (selectedCategory == 'Project Category') {
                          return showCautionDialog(
                              context, 'Choose A Valid Project Category!');
                        }
                        if (projectDocumentFileNameController.text.isEmpty) {
                          return showCautionDialog(
                              context, 'Choose A Project Document');
                        }
                        setState(() {
                          _isLoading = true;
                        });
                        try {
                          await addProjectToDatabase(
                            context: context,
                            selectedCategory: selectedCategory,
                            isLoading: _isLoading,
                            projectDocumentFileNameController:
                                projectDocumentFileNameController,
                            projectTitleController: projectTitleController,
                            yearController: yearController,
                            studentController: studentController,
                            descriptionController: descriptionController,
                            supervisorController: supervisorController,
                            supervisorEmailController:
                                supervisorEmailController,
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text('Error Adding Project: ${e.toString()}'),
                            ),
                          );
                        } finally {
                          setState(() {
                            _isLoading = false;
                          });
                        }
                      },
                      btnText: 'Add Project',
                      isPrimary: true,
                    )
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
