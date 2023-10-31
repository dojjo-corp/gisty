import 'package:flutter/material.dart';
import 'package:gt_daily/authentication/components/buttons/custom_back_button.dart';

import '../../components/page_title.dart';

class EditProjectDetailsPage extends StatefulWidget {
  final String pid;
  const EditProjectDetailsPage({super.key, required this.pid});

  @override
  State<EditProjectDetailsPage> createState() => _EditProjectDetailsPageState();
}

class _EditProjectDetailsPageState extends State<EditProjectDetailsPage> {
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
                  children: [PageTitle(title: 'Edit Project',)],
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