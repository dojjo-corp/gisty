import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gt_daily/authentication/repository/firestore_repo.dart';
import 'package:provider/provider.dart';

import '../components/buttons.dart';
import '../components/event_tile.dart';
import '../components/loading_list_tiles.dart';
import '../providers/user_provider.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
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

  Color prefixIconColorTitle = Colors.grey;
  Color prefixIconColorName = Colors.grey;
  Color prefixIconColorLocation = Colors.grey;

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      StreamBuilder(
          stream:
              FirebaseFirestore.instance.collection('All Events').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: Text('No Job Events Yet'),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('Error Loading Data: ${snapshot.error}'),
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingListTiles();
            }

            final docs = snapshot.data!.docs;
            List<Map<String, dynamic>> eventList = [];
            for (var doc in docs) {
              eventList.add(doc.data());
            }

            return ListView.separated(
              itemCount: eventList.length,
              itemBuilder: (context, index) {
                return EventTile(
                  eventDetails: eventList[index],
                );
              },
              separatorBuilder: (context, index) {
                return const SizedBox(height: 10);
              },
            );
          }),
      Provider.of<UserProvider>(context).userType != 'student'
          ? Positioned(
              bottom: 20,
              right: 20,
              child: FloatingActionButton(
                onPressed: () {
                  showModalBottomSheet(
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    isScrollControlled: true,
                    useSafeArea: true,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    context: context,
                    builder: (context) {
                      return Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Center(
                          child: ListView(
                            children: [
                              Text(
                                'Add New Job Opportunity',
                                style: GoogleFonts.montserrat(
                                  fontSize: 25,
                                  letterSpacing: 5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 10),
                              // JOB TITLE TEXT FIELD
                              TextFormField(
                                controller: jobTitleController,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  prefixIcon: const Icon(Icons.school),
                                  prefixIconColor: prefixIconColorTitle,
                                  hintText: 'Job Title',
                                  labelText: 'Job Title',
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Field can\'t be empty!';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: locationController,
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.white,
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide.none,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        prefixIcon: const Icon(
                                            Icons.location_on_rounded),
                                        prefixIconColor:
                                            prefixIconColorLocation,
                                        hintText: 'Location',
                                        labelText: 'Location',
                                      ),
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return 'Field can\'t be empty!';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  // COMPANY NAME TEXT FIELD
                                  Expanded(
                                    child: TextFormField(
                                      controller: companyNameController,
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.white,
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide.none,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        prefixIcon:
                                            const Icon(Icons.title_rounded),
                                        prefixIconColor: prefixIconColorName,
                                        hintText: 'Company Name',
                                        labelText: 'Company Name',
                                      ),
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return 'Field can\'t be empty!';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 10),
                              // LOCATION TEXT FIELD
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: contactController,
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.white,
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide.none,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        prefixIcon:
                                            const Icon(Icons.phone_rounded),
                                        prefixIconColor:
                                            prefixIconColorLocation,
                                        hintText: 'Company Contacts',
                                        labelText: 'Company Contacts',
                                      ),
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
                                            borderRadius:
                                                BorderRadius.circular(12)),
                                      ),
                                      value: selectedJobType,
                                      items: jobTypes
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
                                          selectedJobType = value!;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 10),
                              TextFormField(
                                controller: descriptionController,
                                decoration: InputDecoration(
                                    alignLabelWithHint: true,
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    hintText: 'Description',
                                    labelText: 'Description'),
                                maxLines: 6,
                                minLines: 5,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Field can\'t be empty!';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 10),
                              MyButton(
                                onPressed: () async {
                                  List<String> contacts;
                                  if (contactController.text.characters
                                      .contains(',')) {
                                    contacts = contactController.text
                                        .trim()
                                        .split(',');
                                  } else if (contactController.text.characters
                                      .contains('/')) {
                                    contacts = contactController.text
                                        .trim()
                                        .split('/');
                                  } else {
                                    contacts = [contactController.text.trim()];
                                  }
                                  final id =
                                      '$selectedJobType${companyNameController.text}${jobTitleController.text}${descriptionController.text.characters.takeLast(10)}';
                                  final Map<String, dynamic> eventDetails = {
                                    'id': id,
                                    'title': jobTitleController.text.trim(),
                                    'company-name':
                                        companyNameController.text.trim(),
                                    'location': locationController.text.trim(),
                                    'company-contacts': contacts,
                                    'details':
                                        descriptionController.text.trim(),
                                  };

                                  Navigator.pop(context);
                                  // store job event in firestore
                                  try {
                                    await FirestoreRepo()
                                        .addJobsOrIntershipEvents(eventDetails);
                                  } catch (e) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      content: Text(
                                          'Error Adding Event: ${e.toString()}'),
                                    ));
                                  }
                                },
                                btnText: 'Add Event',
                                isPrimary: true,
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                child: const Icon(Icons.add),
              ),
            )
          : const Text(''),
    ]);
  }
}
