import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gt_daily/authentication/pages/administrator/user_list_page.dart';

import '../../components/buttons/custom_back_button.dart';
import '../../components/page_title.dart';

class ManageUserAccountsPage extends StatefulWidget {
  const ManageUserAccountsPage({super.key});

  @override
  State<ManageUserAccountsPage> createState() => _ManageUserAccountsPageState();
}

class _ManageUserAccountsPageState extends State<ManageUserAccountsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(
                top: 100, left: 15, right: 15, bottom: 10),
            child: SingleChildScrollView(
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: Column(
                  children: [
                    const PageTitle(title: 'Manage User Accounts'),
                    manageCard('Student'),
                    const SizedBox(height: 20),
                    manageCard('Industry Professional'),
                    const SizedBox(height: 20),
                    manageCard('University Professional'),
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

  void goToUserListPage(String role) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => UserListPage(role: role)));
  }

  //
  Widget manageCard(String role) {
    final Map<String, String> roleImages = {
      'student': 'student.png',
      'industry professional': 'engineer.png',
      'university professional': 'teacher.png',
    };

    return GestureDetector(
      onTap: () {
        goToUserListPage(role.toLowerCase());
      },
      child: Container(
        height: 100,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          image: DecorationImage(
            opacity: 0.25,
            image:
                Image.asset('assets/${roleImages[role.toLowerCase()]}').image,
          ),
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(role, style: GoogleFonts.poppins(fontSize: 18)),
        ),
      ),
    );
  }
}
