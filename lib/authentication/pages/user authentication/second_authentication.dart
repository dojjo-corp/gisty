import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gt_daily/authentication/components/buttons/buttons.dart';
import 'package:gt_daily/authentication/components/textfields/simple_textfield.dart';
import 'package:gt_daily/authentication/helper_methods.dart/global.dart';
import 'package:gt_daily/global/homepage.dart';

import '../../components/page_title.dart';

class IDAuthentication extends StatefulWidget {
  const IDAuthentication({super.key});

  @override
  State<IDAuthentication> createState() => _IDAuthenticationState();
}

class _IDAuthenticationState extends State<IDAuthentication> {
  final indexController = TextEditingController();
  final currentUser = FirebaseAuth.instance.currentUser;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: 100,
              left: 15,
              right: 15,
            ),
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const PageTitle(title: 'ID Authentication'),
                    SimpleTextField(
                      controller: indexController,
                      hintText: 'Enter ID Number',
                      iconData: Icons.numbers_rounded,
                      isWithIcon: true,
                      autofillHints: null,
                    ),
                    const SizedBox(height: 20),
                    MyButton(
                      onPressed: checkIndexNumber,
                      btnText: 'Done',
                      isPrimary: true,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _isLoading ? const LinearProgressIndicator() : null,
    );
  }

  void checkIndexNumber() async {
    setState(() {
      _isLoading = true;
    });
    try {
      // get snapshot of user's firestore document
      final snapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser?.uid)
          .get();

      // get data stored in snapshot
      final data = snapshot.data();

      if (mounted) {
        // check if index numbers match
        if (indexController.text.trim() == data?['id-number']) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MyHomePage(pageIndex: 0),
            ),
          );
        } else {
          // thorw exception (will show alert dialog box) if match failed
          throw 'Incorect Index Number. Check and try again.';
        }
      }
    } catch (e) {
      showCautionDialog(
        context,
        e.toString(),
        title: 'Auth Failed',
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
