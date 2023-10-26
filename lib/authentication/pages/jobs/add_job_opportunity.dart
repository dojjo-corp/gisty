import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:gt_daily/authentication/components/textfields/multi_line_textfeld.dart';
import 'package:gt_daily/authentication/helper_methods.dart/global.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

import '../../components/buttons/buttons.dart';
import '../../components/buttons/custom_back_button.dart';
import '../../components/ListTiles/date_tile.dart';
import '../../components/textfields/simple_textfield.dart';
import '../../components/page_title.dart';
import '../../repository/firebase_messaging.dart';
import '../../repository/firestore_repo.dart';

class AddJobOrInternship extends StatefulWidget {
  const AddJobOrInternship({super.key});

  @override
  State<AddJobOrInternship> createState() => _AddJobOrInternshipState();
}

class _AddJobOrInternshipState extends State<AddJobOrInternship> {
  final _key = GlobalKey<FormState>();
  final jobTitleController = TextEditingController();
  final companyNameController = TextEditingController();
  final locationController = TextEditingController();
  final descriptionController = TextEditingController();
  final contactController = TextEditingController();
  final dateController = TextEditingController();
  String selectedJobType = 'Internship';
  final List<String> jobTypes = [
    'Internship',
    'Full Time',
    'Part Time',
    'Contract',
  ];

  List<Image> jobImages = [];
  List<File> imageFiles = [];

  Color prefixIconColorTitle = Colors.grey;
  Color prefixIconColorName = Colors.grey;
  Color prefixIconColorLocation = Colors.grey;

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(
                top: 100.0, left: 15, right: 15, bottom: 15),
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: SingleChildScrollView(
                  child: Form(
                key: _key,
                child: Column(
                  children: [
                    const PageTitle(title: 'Add Job Opportunity'),

                    // todo JOB TITLE TEXT FIELD
                    SimpleTextField(
                      autofillHints: null,
                      controller: jobTitleController,
                      hintText: 'Job Title',
                      iconData: Icons.school_rounded,
                      isWithIcon: true,
                    ),

                    const SizedBox(height: 5),

                    // todo COMPANY NAME TEXT FIELD
                    SimpleTextField(
                      autofillHints: null,
                      controller: companyNameController,
                      hintText: 'Company Name',
                      iconData: Icons.assured_workload_outlined,
                      isWithIcon: true,
                    ),

                    const SizedBox(height: 5),

                    // todo DEADLINE TEXT FIELD
                    const DateTile(),

                    const SizedBox(height: 5),

                    // todo LOCATION TEXT FIELD
                    SimpleTextField(
                      autofillHints: null,
                      controller: locationController,
                      hintText: 'Location',
                      iconData: Icons.location_on_rounded,
                      isWithIcon: true,
                    ),

                    const SizedBox(height: 5),

                    // todo CONTACTS TEXT FIELD
                    SimpleTextField(
                      autofillHints: null,
                      controller: contactController,
                      hintText: 'Contact(s)',
                      iconData: Icons.phone_rounded,
                      isWithIcon: true,
                    ),

                    const SizedBox(height: 5),

                    // todo JOB TYPE
                    DropdownButtonFormField(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(12)),
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

                    // todo DESCRIPTION TEXT FIELD
                    MultiLineTextField(
                      controller: descriptionController,
                      hintText: 'Description',
                      maxLines: 5,
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
                    jobImages.isNotEmpty
                        ? SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: 109,
                            child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) {
                                  return showJobImage(index);
                                },
                                separatorBuilder: (context, index) =>
                                    const SizedBox(width: 5),
                                itemCount: jobImages.length),
                          )
                        : Container(),

                    const SizedBox(height: 20),

                    // todo SUBMIT BUTTON
                    MyButton(
                      onPressed: () async {
                        if (_key.currentState!.validate()) {
                          _key.currentState!.save();

                          setState(() {
                            _isLoading = true;
                          });
                          List<String> contacts;
                          if (contactController.text.characters.contains(',')) {
                            contacts = contactController.text.trim().split(',');
                          } else if (contactController.text.characters
                              .contains('/')) {
                            contacts = contactController.text.trim().split('/');
                          } else {
                            contacts = [contactController.text.trim()];
                          }
                          final id =
                              '$selectedJobType${companyNameController.text}${jobTitleController.text}${descriptionController.text.characters.takeLast(10)}';
                          final Map<String, dynamic> jobDetails = {
                            'id': id,
                            'title': jobTitleController.text.trim(),
                            'company-name': companyNameController.text.trim(),
                            'location': locationController.text.trim(),
                            'company-contacts': contacts,
                            'details': descriptionController.text.trim(),
                            'time-added': DateTime.now()
                                .toIso8601String() // converted to string for notification
                          };

                          try {
                            // todo: send notification to all users
                            FireMessaging().sendPushNotifiationToAllUsers(
                              title: 'New Job In ${jobDetails['company-name']}',
                              body: jobDetails['title'],
                              type: 'job',
                              routeName: '/job-details',
                              routeArgs: {'job-details': jobDetails},
                            );

                            // convert from String to Timestamp for firestore
                            final date = jobDetails['time-added'] as String;
                            jobDetails['time-added'] =
                                Timestamp.fromDate(DateTime.parse(date));

                            // store job event in firestore
                            await FirestoreRepo()
                                .addJobsOrIntershipEvents(jobDetails);

                            await uploadImages(
                              imageFiles: imageFiles,
                              jobId: id,
                            );

                            if (context.mounted) {
                              setState(() {
                                _isLoading = false;
                              });
                              showSnackBar(
                                context,
                                'Job Posted Successfully',
                              );
                              Navigator.pop(context);
                            }
                          } catch (e) {
                            showSnackBar(
                              context,
                              'Error Adding Event: ${e.toString()}',
                            );
                            setState(() {
                              _isLoading = false;
                            });
                          }
                        }
                      },
                      btnText: 'Add Job',
                      isPrimary: true,
                    )
                  ],
                ),
              )),
            ),
          ),
          const MyBackButton()
        ],
      ),
      floatingActionButton:
          _isLoading ? const CircularProgressIndicator() : Container(),
    );
  }

  // /////////////////////////////////////////////////////////////////
  // todo: Convenience Methods

  Future<List<Image>> chooseImages() async {
    try {
      List<XFile?> images = await ImagePicker().pickMultiImage();
      List<Image> imagesChosen = [];

      for (var image in images) {
        if (image == null) continue;
        final imageFile = File(image.path);
        imageFiles.add(imageFile);

        final imageAsset = Image.file(imageFile);
        imagesChosen.add(imageAsset);
      }
      setState(() {
        jobImages.addAll(imagesChosen);
      });
      return imagesChosen;
    } catch (e) {
      showSnackBar(context, 'Error Choosing Images: ${e.toString()}');
      return Future.value([]);
    }
  }

  Widget showJobImage(int index) {
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
                    backgroundColor: Colors.white,
                    content: Image(image: jobImages[index].image),
                    contentPadding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              },
            );
          },
          child: CircleAvatar(
            radius: 30,
            foregroundImage: jobImages[index].image,

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
              jobImages.removeAt(index);
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
    required String jobId,
  }) async {
    try {
      for (var file in imageFiles) {
        String fileName = path.basename(file.path);
        Reference storageReference =
            FirebaseStorage.instance.ref().child('Job Files/$jobId/$fileName');
        await storageReference.putFile(file);
      }
    } catch (e) {
      rethrow;
    }
  }
}
