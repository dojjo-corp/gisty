import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gt_daily/authentication/components/buttons/buttons.dart';
import 'package:gt_daily/authentication/components/page_title.dart';
import 'package:gt_daily/authentication/components/textfields/multi_line_textfeld.dart';
import 'package:gt_daily/authentication/helper_methods.dart/global.dart';

import '../../components/buttons/custom_back_button.dart';

class EditAboutMe extends StatefulWidget {
  const EditAboutMe({super.key});

  @override
  State<EditAboutMe> createState() => _EditAboutMeState();
}

class _EditAboutMeState extends State<EditAboutMe> {
  final aboutMeController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    

    void updateAboutMe() async {
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
      }
    }

    return Scaffold(
      body: Stack(
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
                    MultiLineTextField(
                      controller: aboutMeController,
                      hintText: 'About Us...',
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
    );
  }
}
