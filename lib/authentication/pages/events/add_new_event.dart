import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gt_daily/authentication/components/buttons/custom_back_button.dart';
import 'package:gt_daily/authentication/helper_methods.dart/date_and_time.dart';
import 'package:gt_daily/authentication/helper_methods.dart/global.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

import '../../../global/homepage.dart';
import '../../components/buttons/buttons.dart';
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
  final eventTitleController = TextEditingController();
  final organizersController = TextEditingController();
  final locationController = TextEditingController();
  final descriptionController = TextEditingController();
  final contactController = TextEditingController();

  String dateText = 'Set Date';
  Color dateIconColor = Colors.grey;

  Color timeIconColor = Colors.grey;
  String timeText = 'Set Time';

  List<Image> eventImages = [];
  List<File> imageFiles = [];

  @override
  Widget build(BuildContext context) {
    log('Images: ${imageFiles.length}\n\nEvent: ${eventImages.length}\n\n');
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
                            controller: eventTitleController,
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
                            controller: organizersController,
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

                          // todo: DATE / FIELD
                          Row(
                            children: [
                              Expanded(
                                child: getDateTile(),
                              ),
                              Expanded(
                                child: getTimeTile(),
                              )
                            ],
                          ),

                          const SizedBox(height: 5),

                          // todo: EVENT DESCRIPTION TEXTFIELD
                          MultiLineTextField(
                            controller: descriptionController,
                            hintText: 'Description',
                            maxLines: 8,
                          ),

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
                                  'title': eventTitleController.text.trim(),
                                  'organizers':
                                      organizersController.text.trim(),
                                  'location': locationController.text.trim(),
                                  'contacts': contacts,
                                  'details': descriptionController.text.trim(),
                                  'event-date': dateText,
                                  'event-time': timeText,
                                  'posted-by':
                                      FirebaseAuth.instance.currentUser?.email,
                                  'timestamp': DateTime.now()
                                      .toIso8601String() // used String for easy encoding to json format (notifications)
                                };

                                // show loading indicator
                                setState(() {
                                  _isLoading = true;
                                });

                                try {
                                  /// Don't upload event post without an Image
                                  if (imageFiles.isEmpty) {
                                    throw 'Add at least one image';
                                  }
                                  // todo upload images to firebase storage
                                  await uploadImages(
                                    imageFiles: imageFiles,
                                    eventId: id,
                                  );

                                  // todo: send notification to all users
                                  await FireMessaging()
                                      .sendPushNotifiationToAllUsers(
                                    title:
                                        'New Event By ${eventDetails['organizers']}',
                                    body: '${eventDetails['title']}',
                                    type: 'event',
                                    routeName: '/event-details',
                                    routeArgs: {'event-id': id},
                                  );

                                  // todo store event in firestore
                                  // convert from DateTime to Timestamp for firestore
                                  final date = eventDetails['time-added'];
                                  eventDetails['time-added'] =
                                      Timestamp.fromDate(DateTime.parse(date));
                                  await FirestoreRepo().addEvents(eventDetails);

                                  if (context.mounted) {
                                    setState(() {
                                      _isLoading = false;
                                    });
                                    showSnackBar(
                                      context,
                                      'Event Posted Successfully',
                                    );
                                    Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              MyHomePage(pageIndex: 0),
                                        ),
                                        (route) => false);
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

  // todo: CONVENIENCE METHODS

  Future<void> chooseImages() async {
    try {
      List<XFile?> images = await ImagePicker().pickMultiImage();

      for (var image in images) {
        if (image == null) continue;
        final imageFile = File(image.path);

        final imageAsset = Image.file(
          imageFile,
          height: 60,
        );

        setState(() {
          eventImages.add(imageAsset);
          imageFiles.add(imageFile);
        });
      }
    } catch (e) {
      showSnackBar(context, 'Error Choosing Images: ${e.toString()}');
    }
  }

  Widget getDateTile() {
    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2023),
          lastDate: DateTime(2030, 12, 31),
        );
        if (date != null) {
          final dateTextRaw = date.toString().split(' ')[0];
          // get month in text format. Example: 1 == 'Jan'
          String month = ', ${formatMonth(date.month)} ';
          final splitText = dateTextRaw.split('-');
          // replace month num with month text
          splitText.replaceRange(1, 2, [month]);
          // concatenate list
          final dateFormatted = splitText.join();

          setState(() {
            dateText = dateFormatted;
            dateIconColor = Theme.of(context).primaryColor;
          });
        }
      },
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey[100]!),
        ),
        tileColor: Colors.white,
        leading: Icon(
          Icons.calendar_month_rounded,
          color: dateIconColor,
        ),
        title: Text(dateText),
      ),
    );
  }

  Widget getTimeTile() {
    return GestureDetector(
      onTap: () async {
        final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );

        if (time != null) {
          setState(() {
            timeText =
                '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
            timeIconColor = Theme.of(context).primaryColor;
          });
        }
      },
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey[100]!),
        ),
        tileColor: Colors.white,
        leading: Icon(
          Icons.timer_rounded,
          color: timeIconColor,
        ),
        title: Text(timeText),
      ),
    );
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
              imageFiles.removeAt(index);
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
    List<String> downloadUrls = [];
    try {
      /// Upload images to firebase storage
      for (var file in imageFiles) {
        String fileName = path.basename(file.path);
        Reference storageReference = FirebaseStorage.instance
            .ref()
            .child('Event Files/$eventId/$fileName');
        await storageReference.putFile(file);

        /// Get download url of uploaded image
        String downloadUrl = await storageReference.getDownloadURL();
        downloadUrls.add(downloadUrl);
      }

      /// Update job details with download urls
      await FirebaseFirestore.instance
          .collection('All Events')
          .doc(eventId)
          .update({'images': downloadUrls});
    } catch (e) {
      rethrow;
    }
  }
}
