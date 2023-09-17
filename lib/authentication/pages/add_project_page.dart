import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../components/buttons.dart';
import '../components/custom_back_button.dart';

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
  String selectedCategory = 'Web';
  final List<String> categories = ['Web', 'Mobile', 'Data', 'Hardware'];

  @override
  Widget build(BuildContext context) {
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
                      TextFormField(
                        controller: yearController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.calendar_month_rounded),
                          hintText: 'Year',
                          labelText: 'Year',
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Field can\'t be empty!';
                          }
                          return null;
                        },
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
                      const Text('Project Category'),
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
                      MyButton(
                        onPressed: () async {},
                        btnText: 'Upload Project Document',
                        isPrimary: false,
                      ),
                      const SizedBox(height: 20),
                      MyButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          // store job event in firestore
                          // await FirebaseFirestore.instance
                          //     .collection('Events')
                          //     .doc()
                          //     .set(jobDetails);
                        },
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
