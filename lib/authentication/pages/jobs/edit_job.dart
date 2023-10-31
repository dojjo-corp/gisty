import 'package:flutter/material.dart';

import '../../components/buttons/custom_back_button.dart';
import '../../components/page_title.dart';

class EditJobDetailsPage extends StatefulWidget {
  final String jobId;
  const EditJobDetailsPage({super.key, required this.jobId});

  @override
  State<EditJobDetailsPage> createState() => _EditJobDetailsPageState();
}

class _EditJobDetailsPageState extends State<EditJobDetailsPage> {
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
                  children: [PageTitle(title: 'Edit Job',)],
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