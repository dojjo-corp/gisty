import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gt_daily/authentication/components/loading_circle.dart';
import 'package:gt_daily/authentication/pages/administrator/edit_contact_info.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

import '../components/buttons/buttons.dart';
import '../components/buttons/custom_back_button.dart';
import '../components/page_title.dart';
import '../providers/user_provider.dart';

class ContactUsPage extends StatefulWidget {
  const ContactUsPage({super.key});

  @override
  State<ContactUsPage> createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  bool _dataLoaded = false;
  late Map<String, dynamic> contactData;

  @override
  void initState() {
    super.initState();
    loadContactInfo().then((value) {
      setState(() {
        contactData = value!;
        _dataLoaded = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isUserAdmin = Provider.of<UserProvider>(context).isUserAdmin;
    return Scaffold(
      body: !_dataLoaded
          ? const LoadingCircle()
          : Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      top: 100, bottom: 10, right: 20, left: 20),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const PageTitle(title: 'Contact Information'),
                          StreamBuilder(
                              stream: FirebaseFirestore.instance
                                  .collection('Our Info')
                                  .doc('Contact Info')
                                  .snapshots()
                                  .throttleTime(const Duration(seconds: 1)),
                              builder: (context, snapshot) {
                                return Column(
                                  children: [
                                    ListTile(
                                      leading: Icon(
                                        Icons.phone,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                      title: const Text('Phone Number'),
                                      subtitle: Text(contactData['contact']),
                                    ),
                                    ListTile(
                                      leading: Icon(
                                        Icons.email,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                      title: const Text('Email'),
                                      subtitle: Text(contactData['email']),
                                    ),
                                    ListTile(
                                      leading: Icon(
                                        Icons.location_on,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                      title: const Text('Address'),
                                      subtitle: Text(contactData['address']),
                                    ),
                                  ],
                                );
                              }),
                          const SizedBox(height: 20),
                          !isUserAdmin
                              ? MyButton(
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/feedback');
                                  },
                                  btnText: 'Feedback / Report',
                                  isPrimary: true,
                                )
                              : Container(),
                        ],
                      ),
                    ),
                  ),
                ),
                const MyBackButton(),
                isUserAdmin
                    ? Positioned(
                        top: 45,
                        right: 5,
                        child: Tooltip(
                          message: 'Edit Contact Info',
                          child: IconButton(
                            icon: const Icon(Icons.settings_outlined),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const EditContactInfo(),
                                ),
                              );
                            },
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      )
                    : Container()
              ],
            ),
    );
  }
}

Future<Map<String, dynamic>?> loadContactInfo() async {
  try {
    final snapshot = await FirebaseFirestore.instance
        .collection('Our Info')
        .doc('Contact Info')
        .get();

    if (snapshot.exists) return snapshot.data()!;

    throw 'Error loading contact info';
  } catch (e) {
    rethrow;
  }
}
