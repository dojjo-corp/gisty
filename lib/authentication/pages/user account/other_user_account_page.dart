import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../components/buttons.dart';
import '../../components/custom_back_button.dart';
import '../../providers/user_provider.dart';
import '../messaging/chat_page.dart';

class OtherUserAccountPage extends StatefulWidget {
  final String otherUserEmail;
  const OtherUserAccountPage({super.key, required this.otherUserEmail});

  @override
  State<OtherUserAccountPage> createState() => _OtherUserAccountPageState();
}

class _OtherUserAccountPageState extends State<OtherUserAccountPage> {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final currentUser = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> otherUserMap =
        Provider.of<UserProvider>(context, listen: false)
                .getUserDataFromEmail(widget.otherUserEmail) ??
            {};
    final userFirstName = otherUserMap['fullname']?.split(' ')[0] ?? '';

    String getRoomId(String receiverEmail) {
      String roomId = '';
      final ids = [FirebaseAuth.instance.currentUser!.email, receiverEmail];
      ids.sort();
      roomId = ids.join();
      return roomId;
    }

    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(
                top: 100, right: 15, left: 15, bottom: 10),
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: SingleChildScrollView(
                child: otherUserMap.isNotEmpty
                    ? Column(
                        children: [
                          Icon(
                            Icons.person,
                            size: 100,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(height: 20),
                          ListTile(
                            leading: Icon(Icons.person_rounded,
                                color: Theme.of(context).primaryColor),
                            title: Text(
                              'Name',
                              style: GoogleFonts.poppins(color: Colors.grey),
                            ),
                            subtitle: Text(otherUserMap['fullname']),
                          ),
                          ListTile(
                            leading: Icon(Icons.email_rounded,
                                color: Theme.of(context).primaryColor),
                            title: Text(
                              'Email',
                              style: GoogleFonts.poppins(color: Colors.grey),
                            ),
                            subtitle: Text(otherUserMap['email']),
                          ),
                          ListTile(
                            leading: Icon(Icons.phone_rounded,
                                color: Theme.of(context).primaryColor),
                            title: Text(
                              'Contact',
                              style: GoogleFonts.poppins(color: Colors.grey),
                            ),
                            subtitle: Text(otherUserMap['contact']),
                          ),
                          ListTile(
                            leading: Icon(Icons.work_rounded,
                                color: Theme.of(context).primaryColor),
                            title: Text(
                              'Role',
                              style: GoogleFonts.poppins(color: Colors.grey),
                            ),
                            subtitle: Text(otherUserMap['user-type']),
                          ),
                          const SizedBox(height: 10),
                          otherUserMap['user-type'] != 'student'
                              ? MyButton(
                                  onPressed: () {
                                    // Navigate to [other-user]'s Chat Page
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ChatPage(
                                          roomId:
                                              getRoomId(otherUserMap['email']),
                                          receiverEmail: otherUserMap['email'],
                                        ),
                                      ),
                                    );
                                  },
                                  btnText: 'Chat With $userFirstName!',
                                  isPrimary: false,
                                )
                              : Container(),
                          const SizedBox(height: 10),
                        ],
                      )
                    : Column(
                        children: [
                          const SizedBox(height: 100),
                          const Icon(Icons.person_off_rounded,
                              size: 100, color: Colors.red),
                          const SizedBox(height: 50),
                          Row(
                            children: [
                              Text(widget.otherUserEmail,
                                  style:
                                      const TextStyle(fontWeight: FontWeight.bold)),
                              const Text(' Does Not Exist In Our Database.'),
                            ],
                          ),
                          const SizedBox(height: 15),
                          MyButton(
                              btnText: 'Contact  Support Team',
                              isPrimary: true,
                              onPressed: () {
                                Navigator.pushNamed(context, '/contact-us');
                              })
                        ],
                      ),
              ),
            ),
          ),
          const Positioned(
            top: 40,
            left: 5,
            child: MyBackButton(),
          )
        ],
      ),
    );
  }
}
