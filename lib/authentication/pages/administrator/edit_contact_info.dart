import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gt_daily/authentication/components/buttons/buttons.dart';
import 'package:gt_daily/authentication/components/buttons/custom_back_button.dart';
import 'package:gt_daily/authentication/components/page_title.dart';
import 'package:gt_daily/authentication/components/textfields/simple_textfield.dart';
import 'package:gt_daily/authentication/helper_methods.dart/global.dart';

import '../../components/loading_circle.dart';
import '../contact_us.dart';

class EditContactInfo extends StatefulWidget {
  const EditContactInfo({super.key});

  @override
  State<EditContactInfo> createState() => _EditContactInfoState();
}

class _EditContactInfoState extends State<EditContactInfo> {
  final contactController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  bool _dataLoaded = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    loadContactInfo().then((value) {
      setState(() {
        contactController.text = value!['contact'];
        emailController.text = value['email'];
        addressController.text = value['address'];
        _dataLoaded = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    void updateContactInfo() async {
      setState(() {
        _isLoading = true;
      });
      try {
        await FirebaseFirestore.instance
            .collection('Our Info')
            .doc('Contact Info')
            .set(
          {
            'contact': contactController.text.trim(),
            'email': emailController.text.trim(),
            'address': addressController.text.trim(),
          },
          SetOptions(merge: true),
        );

        if (mounted) {
          // reset text fields and move to previous page with success message
          contactController.clear();
          emailController.clear();
          addressController.clear();
          Navigator.pop(context);
          showSnackBar(context, 'Success!');
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
                          SimpleTextField(
                            controller: contactController,
                            hintText: 'Phone Number',
                            iconData: Icons.phone_rounded,
                            isWithIcon: true,
                            autofillHints: null,
                          ),
                          const SizedBox(height: 5),
                          SimpleTextField(
                            controller: emailController,
                            hintText: 'Email',
                            iconData: Icons.email_rounded,
                            isWithIcon: true,
                            autofillHints: null,
                          ),
                          const SizedBox(height: 5),
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
      floatingActionButton: _isLoading ? const LinearProgressIndicator() : null,
    );
  }
}
