import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gt_daily/authentication/components/buttons/buttons.dart';
import 'package:gt_daily/authentication/components/page_title.dart';
import 'package:gt_daily/authentication/components/textfields/multi_line_textfeld.dart';
import 'package:gt_daily/authentication/helper_methods.dart/global.dart';

import '../../components/buttons/custom_back_button.dart';
import '../../components/loading_circle.dart';

class EditAboutMe extends StatefulWidget {
  const EditAboutMe({super.key});

  @override
  State<EditAboutMe> createState() => _EditAboutMeState();
}

class _EditAboutMeState extends State<EditAboutMe> {
  final aboutMeController = TextEditingController();
  bool _isLoading = false;
  bool _dataLoaded = false;

  @override
  void initState() {
    super.initState();
    loadAboutUs().then((value) {
      setState(() {
        aboutMeController.text = value!['description'];
        _dataLoaded = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    String hintText = 'About us...';
    void updateAboutMe() async {
      setState(() {
        _isLoading = true;
      });
      try {
        await FirebaseFirestore.instance
            .collection('Our Info')
            .doc('About Us')
            .set(
          {'description': aboutMeController.text.trim()},
          SetOptions(merge: true),
        );
        if (mounted) {
          aboutMeController.clear();
          Navigator.pop(context);
        }
      } on FirebaseException catch (e) {
        showCautionDialog(context, e.message!);
      } catch (e) {
        showCautionDialog(context, e.toString());
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }

    return Scaffold(
      body: !_dataLoaded
          ? const LoadingCircle()
          : Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 100, right: 15, left: 15),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const PageTitle(title: 'Edit About Me'),
                          // FutureBuilder(
                          //   initialData: const {'description': 'About us...'},
                          //   future: FirebaseFirestore.instance
                          //       .collection('Our Info')
                          //       .doc('About Us')
                          //       .get(),
                          //   builder: (context, snapshot) {
                          //     // BEFORE ANY DATA GETS LOADED FROM FIREBASE
                          //     dynamic data;
                          //     if (snapshot.hasError ||
                          //         snapshot.connectionState ==
                          //             ConnectionState.none) {
                          //       data = snapshot.data as Map<String, dynamic>;
                          //       return MultiLineTextField(
                          //         controller: aboutMeController,
                          //         hintText: hintText,
                          //         maxLines: 30,
                          //       );
                          //     }

                          //     // WHEN DATA IS LOADED FROM FIREBASE SUCCESSFULLY
                          //     data = snapshot.data;

                          //     return MultiLineTextField(
                          //       controller: aboutMeController,
                          //       hintText: hintText,
                          //       maxLines: 30,
                          //     );
                          //   },
                          // ),
                          MultiLineTextField(
                            controller: aboutMeController,
                            hintText: hintText,
                            maxLines: 30,
                          ),
                          const SizedBox(height: 25),
                          MyButton(
                              onPressed: updateAboutMe,
                              btnText: 'Done',
                              isPrimary: true),
                        ],
                      ),
                    ),
                  ),
                ),
                const MyBackButton(),
              ],
            ),
      floatingActionButton: _isLoading ? const LinearProgressIndicator() : null,
    );
  }
}

Future<Map<String, dynamic>?> loadAboutUs() async {
  try {
    final snapshot = await FirebaseFirestore.instance
        .collection('Our Info')
        .doc('About Us')
        .get();
    if (snapshot.exists) {
      return snapshot.data()!;
    }
    throw 'Error loading About Us data';
  } catch (e) {
    rethrow;
  }
}
