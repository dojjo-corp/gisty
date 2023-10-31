import 'package:flutter/material.dart';

import '../../components/buttons/custom_back_button.dart';
import '../../components/page_title.dart';

class EditEventDetailsPage extends StatefulWidget {
  final String eventId;
  const EditEventDetailsPage({super.key, required this.eventId});

  @override
  State<EditEventDetailsPage> createState() => _EditEventDetailsPageState();
}

class _EditEventDetailsPageState extends State<EditEventDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 100, left: 15, right: 15, bottom: 10),
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    PageTitle(
                      title: 'Edit Event',
                    ),
                  ],
                ),
              ),
            ),
          ),
          const MyBackButton()
        ],
      ),
    );
  }
}
