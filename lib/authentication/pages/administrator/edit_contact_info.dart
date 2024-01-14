import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gt_daily/authentication/components/buttons/buttons.dart';
import 'package:gt_daily/authentication/components/buttons/custom_back_button.dart';
import 'package:gt_daily/authentication/components/page_title.dart';
import 'package:gt_daily/authentication/components/textfields/simple_textfield.dart';
import 'package:gt_daily/authentication/helper_methods.dart/global.dart';

class EditContactInfo extends StatefulWidget {
  const EditContactInfo({super.key});

  @override
  State<EditContactInfo> createState() => _EditContactInfoState();
}

class _EditContactInfoState extends State<EditContactInfo> {
  final contactController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    void updateContactInfo() async {
      try {
        await FirebaseFirestore.instance
            .collection('Our Info')
            .doc('Contact Info')
            .set(
          {
            'Contact': contactController.text.trim(),
            'Email': emailController.text.trim(),
            'Address': addressController.text.trim(),
          },
          SetOptions(merge: true),
        );

        // reset text fields and move to previous page with success message
        contactController.clear();
        emailController.clear();
        addressController.clear();
        if (mounted) {
          Navigator.pop(context);
          showSnackBar(context, 'Success!');
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
                    SimpleTextField(
                      controller: contactController,
                      hintText: 'Phone Number',
                      iconData: Icons.phone_rounded,
                      isWithIcon: true,
                      autofillHints: null,
                    ),
                    const SizedBox(height: 3),
                    SimpleTextField(
                      controller: emailController,
                      hintText: 'Email',
                      iconData: Icons.email_rounded,
                      isWithIcon: true,
                      autofillHints: null,
                    ),
                    const SizedBox(height: 3),
                    SimpleTextField(
                      controller: addressController,
                      hintText: 'Address',
                      iconData: Icons.location_on_rounded,
                      isWithIcon: true,
                      autofillHints: null,
                    ),
                    const SizedBox(height: 20),
                    MyButton(
                      onPressed: updateContactInfo,
                      btnText: 'Done',
                      isPrimary: true,
                    ),
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
