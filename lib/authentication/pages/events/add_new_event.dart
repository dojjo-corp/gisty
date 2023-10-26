import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gt_daily/authentication/components/buttons/custom_back_button.dart';
import 'package:gt_daily/authentication/helper_methods.dart/global.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

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

  List<Image> eventImages = [];
  List<File> imageFiles = [];

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
                  crossAxisAlignment: CrossAxisAlignment.start,
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

                          // todo: EVENT TITLE TEXT FIELD
                          SimpleTextField(
                            autofillHints: null,
                            controller: jobTitleController,
                            hintText: 'Event Title',
                            iconData: Icons.title_rounded,
                            isWithIcon: true,
                          ),

                          const SizedBox(height: 5),

                          // todo: LOCATION TEXTFIELD
                          SimpleTextField(
                            autofillHints: null,
                            controller: locationController,
                            hintText: 'Location',
                            iconData: Icons.location_on_rounded,
                            isWithIcon: true,
                          ),

                          const SizedBox(height: 5),

                          // todo: COMPANY NAME
                          SimpleTextField(
                            autofillHints: null,
                            controller: companyNameController,
                            hintText: 'Organizers',
                            iconData: Icons.groups_rounded,
                            isWithIcon: true,
                          ),

                          const SizedBox(height: 5),

                          // todo: CONTACT TEXT FIELD
                          SimpleTextField(
                            autofillHints: null,
                            controller: contactController,
                            hintText: 'Contact',
                            iconData: Icons.phone_rounded,
                            isWithIcon: true,
                          ),

                          const SizedBox(height: 5),

                          // todo: DATE FIELD
                          const Row(
                            children: [
                              Expanded(child: DateTile()),
                              Expanded(child: TimeTile())
                            ],
                          ),

                          const SizedBox(height: 5),

                          // todo: EVENT DESCRIPTION TEXTFIELD
                          MultiLineTextField(
                            controller: descriptionController,
                            hintText: 'Description',
                            maxLines: 10,
                          ),

                          const SizedBox(height: 5),

                          // todo: ADD IMAGES
                          TextButton(
                            onPressed: chooseImages,
                            child: const Row(
                              children: [
                                Icon(Icons.add),
                                Text('Add Images'),
                              ],
                            ),
                          ),

                          const SizedBox(height: 5),

                          eventImages.isNotEmpty
                              ? SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  height: 109,
                                  child: ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      itemBuilder: (context, index) {
                                        return showEventImage(index);
                                      },
                                      separatorBuilder: (context, index) =>
                                          const SizedBox(width: 5),
                                      itemCount: eventImages.length),
                                )
                              : Container(),

                          const SizedBox(height: 10),

                          MyButton(
                            onPressed: () async {
                              if (_key.currentState!.validate()) {
                                _key.currentState!.save();

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

                                final id = FirebaseFirestore.instance
                                    .collection('All Events')
                                    .doc()
                                    .id;

                                final Map<String, dynamic> eventDetails = {
                                  'id': id,
                                  'title': jobTitleController.text.trim(),
                                  'organizers':
                                      companyNameController.text.trim(),
                                  'location': locationController.text.trim(),
                                  'contacts': contacts,
                                  'details': descriptionController.text.trim(),
                                  'event-date': dateController.text.trim(),
                                  'time-added': DateTime.now()
                                      .toIso8601String() // used String for easy encoding to json format (notifications)
                                };

                                // show loading indicator
                                setState(() {
                                  _isLoading = true;
                                });

                                try {
                                  // todo: send notification to all users
                                  await FireMessaging()
                                      .sendPushNotifiationToAllUsers(
                                    title:
                                        'New Event By ${eventDetails['organizers']}',
                                    body: '${eventDetails['title']}',
                                    type: 'event',
                                    routeName: '/event-details',
                                    routeArgs: {'event-details': eventDetails},
                                  );

                                  // todo store event in firestore
                                  // convert from DateTime to Timestamp for firestore
                                  final date = eventDetails['time-added'];
                                  eventDetails['time-added'] =
                                      Timestamp.fromDate(DateTime.parse(date));
                                  await FirestoreRepo().addEvents(eventDetails);

                                  // todo upload images to firebase storage
                                  await uploadImages(
                                    imageFiles: imageFiles,
                                    eventId: id,
                                  );

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

  // todo: CONVINIENCE METHODS

  Future<List<Image>> chooseImages() async {
    try {
      List<XFile?> images = await ImagePicker().pickMultiImage();
      List<Image> imagesChosen = [];

      for (var image in images) {
        if (image == null) continue;
        final imageFile = File(image.path);

        final imageAsset = Image.file(
          imageFile,
          height: 60,
        );
        imagesChosen.add(imageAsset);
      }
      setState(() {
        eventImages.addAll(imagesChosen);
      });
      return imagesChosen;
    } catch (e) {
      showSnackBar(context, 'Error Choosing Images: ${e.toString()}');
      return Future.value([]);
    }
  }

  Widget showEventImage(int index) {
    return Column(
      children: [
        GestureDetector(
          onTap: () async {
            await showGeneralDialog(
              context: context,
              barrierDismissible: true,
              barrierLabel: 'Exit',
              pageBuilder: (context, animation, secondaryAnimation) {
                return AspectRatio(
                  aspectRatio: 16 / 9,
                  child: AlertDialog(
                    backgroundColor: Colors.grey[400],
                    content: Image(image: eventImages[index].image),
                    contentPadding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                );
              },
            );
          },
          child: CircleAvatar(
            radius: 30,
            foregroundImage: eventImages[index].image,

            // show icon if image fails to load
            onForegroundImageError: (exception, stackTrace) => const Icon(
              Icons.event,
              color: Colors.grey,
            ),
          ),
        ),
        IconButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            setState(() {
              eventImages.removeAt(index);
            });
          },
          icon: const Icon(
            Icons.delete_rounded,
            color: Colors.red,
            size: 20,
          ),
        )
      ],
    );
  }

  // todo: Upload Images To Firebase Storage
  Future<void> uploadImages({
    required List<File> imageFiles,
    required String eventId,
  }) async {
    try {
      for (var file in imageFiles) {
        String fileName = path.basename(file.path);
        Reference storageReference = FirebaseStorage.instance
            .ref()
            .child('Job Files/$eventId/$fileName');
        await storageReference.putFile(file);
      }
    } catch (e) {
      rethrow;
    }
  }
}
