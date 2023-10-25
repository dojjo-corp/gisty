import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gt_daily/authentication/components/buttons/custom_back_button.dart';
import 'package:gt_daily/authentication/helper_methods.dart/global.dart';

import '../../components/ListTiles/time_tile.dart';
import '../../components/buttons/buttons.dart';
import '../../components/ListTiles/date_tile.dart';
import '../../components/textfields/multi_line_textfeld.dart';
import '../../components/textfields/simple_textfield.dart';
import '../../repository/firebase_messaging.dart';
import '../../repository/firestore_repo.dart';

class AddNewEventPage extends StatefulWidget {
  const AddNewEventPage({super.key});

  @override
  State<AddNewEventPage> createState() => _AddNewEventPageState();
}

class _AddNewEventPageState extends State<AddNewEventPage> {
  bool _isLoading = false;
  final _key = GlobalKey<FormState>();
  final jobTitleController = TextEditingController();
  final companyNameController = TextEditingController();
  final locationController = TextEditingController();
  final descriptionController = TextEditingController();
  final contactController = TextEditingController();
  final dateController = TextEditingController();
  String dateText = 'Set Event Date';
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
                    Form(
                      key: _key,
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
                          SimpleTextField(
                            autofillHints: null,
                            controller: jobTitleController,
                            hintText: 'Event Title',
                            iconData: Icons.title_rounded,
                            isWithIcon: true,
                          ),
                          const SizedBox(height: 10),

                          // LOCATION TEXTFIELD
                          SimpleTextField(
                            autofillHints: null,
                            controller: locationController,
                            hintText: 'Location',
                            iconData: Icons.location_on_rounded,
                            isWithIcon: true,
                          ),
                          const SizedBox(height: 10),

                          // COMPANY NAME
                          SimpleTextField(
                            autofillHints: null,
                            controller: companyNameController,
                            hintText: 'Organizers',
                            iconData: Icons.groups_rounded,
                            isWithIcon: true,
                          ),

                          const SizedBox(height: 10),

                          // CONTACT TEXT FIELD
                          SimpleTextField(
                            autofillHints: null,
                            controller: contactController,
                            hintText: 'Contact',
                            iconData: Icons.phone_rounded,
                            isWithIcon: true,
                          ),
                          const SizedBox(height: 10),

                          // DATE FIELD
                          const Row(
                            children: [
                              Expanded(child: DateTile()),
                              Expanded(child: TimeTile())
                            ],
                          ),
                          const SizedBox(height: 10),

                          // JOB DESCRIPTION TEXTFIELD
                          MultiLineTextField(
                            controller: descriptionController,
                            hintText: 'Description',
                            maxLines: 10,
                          ),
                          const SizedBox(height: 10),

                          MyButton(
                            onPressed: () async {
                              List<String> contacts;
                              if (contactController.text.characters
                                  .contains(',')) {
                                contacts =
                                    contactController.text.trim().split(',');
                              } else if (contactController.text.characters
                                  .contains('/')) {
                                contacts =
                                    contactController.text.trim().split('/');
                              } else {
                                contacts = [contactController.text.trim()];
                              }

                              final id =
                                  '$selectedJobType${companyNameController.text}${jobTitleController.text}${descriptionController.text.characters.takeLast(10)}';
                              final Map<String, dynamic> eventDetails = {
                                'id': id,
                                'title': jobTitleController.text.trim(),
                                'organizers': companyNameController.text.trim(),
                                'location': locationController.text.trim(),
                                'contacts': contacts,
                                'details': descriptionController.text.trim(),
                                'event-date': dateController.text.trim(),
                                'time-added': DateTime.now()
                                    .toIso8601String() // use String for easy encoding to json format (notifications)
                              };
                              setState(() {
                                _isLoading = true;
                              });

                              try {
                                // todo: send notification to all users
                                final responseMap = await FireMessaging()
                                    .sendPushNotifiationToAllUsers(
                                  title:
                                      'New Event In ${eventDetails['organizers']}',
                                  body: '${eventDetails['title']}',
                                  type: 'event',
                                  routeName: '/event-details',
                                  routeArgs: {'event-details': eventDetails},
                                );

                                // store event in firestore
                                // convert from DateTime to Timestamp for firestore
                                final date = eventDetails['time-added'];
                                eventDetails['time-added'] =
                                    Timestamp.fromDate(DateTime.parse(date));
                                await FirestoreRepo().addEvents(eventDetails);

                                log('This is the response: ${jsonEncode(responseMap)}');

                                if (context.mounted) {
                                  setState(() {
                                    _isLoading = false;
                                  });
                                  showSnackBar(
                                    context,
                                    'Event Posted Successfully',
                                  );
                                  Navigator.pop(context);
                                }
                              } catch (e) {
                                showSnackBar(
                                  context,
                                  'Error Adding Event: ${e.toString()}',
                                );
                              } finally {
                                setState(() {
                                  _isLoading = false;
                                });
                              }
                            },
                            btnText: 'Add Event',
                            isPrimary: true,
                          )
                        ],
                      ),
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
