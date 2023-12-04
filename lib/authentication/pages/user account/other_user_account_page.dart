// import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gt_daily/authentication/components/loading_circle.dart';
import 'package:gt_daily/authentication/helper_methods.dart/global.dart';
import 'package:gt_daily/global/homepage.dart';
import 'package:provider/provider.dart';

import '../../components/buttons/buttons.dart';
import '../../components/buttons/custom_back_button.dart';
import '../../helper_methods.dart/messaging.dart';
import '../../helper_methods.dart/profile.dart';
import '../../models/admin.dart';
import '../../providers/connectivity_provider.dart';
import '../../providers/user_provider.dart';
import '../messaging/chat_page.dart';

class OtherUserAccountPage extends StatefulWidget {
  final String otherUserEmail;
  const OtherUserAccountPage({super.key, required this.otherUserEmail});

  @override
  State<OtherUserAccountPage> createState() => _OtherUserAccountPageState();
}

class _OtherUserAccountPageState extends State<OtherUserAccountPage> {
  bool _isLoaded = false;
  final currentUid = FirebaseAuth.instance.currentUser!.uid;
  final currentUser = FirebaseAuth.instance.currentUser!;

  // update local users data
  @override
  void initState() {
    super.initState();
    // Go to User Account page rather if [otherUserEmail] == currentUSerEmail
    // Else load otherUser's data
    if (widget.otherUserEmail == FirebaseAuth.instance.currentUser?.email) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => MyHomePage(pageIndex: 3),
          ),
        );
      });
    } else {
      setAllUsers().then((value) {
        setState(() {
          _isLoaded = true;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final connectivity = Provider.of<ConnectivityProvider>(context);
    return !_isLoaded
        ? const LoadingCircle()
        : Scaffold(
            body: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      top: 100, right: 15, left: 15, bottom: 10),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: SingleChildScrollView(
                      child: Consumer<UserProvider>(
                        builder: (context, userProvider, child) {
                          // For Admin Privileges
                          final isUserAdmin = userProvider.isUserAdmin;
                          final administrator = Administrator();

                          // Get User's Stored Data
                          final Map<String, dynamic> otherUserMap =
                              userProvider.getUserDataFromEmail(
                                      widget.otherUserEmail) ??
                                  {};

                          // User's First Name
                          final userFirstName =
                              otherUserMap['fullname']?.split(' ')[0] ?? '';

                          // Is Other User An Admin
                          final isOtherUserAdmin =
                              otherUserMap['admin'] ?? false;

                          // currentUser type
                          final currentUserType = userProvider.userType;

                          return otherUserMap.isNotEmpty
                              ? Column(
                                  children: [
                                    StreamBuilder(
                                      stream: getThrottledStream(
                                        collectionPath: 'users',
                                        docPath: otherUserMap['uid'],
                                      ),
                                      builder: (context, snapshot) {
                                        if (!snapshot.hasData) {
                                          return showNoProfilePicture(context);
                                        }

                                        final data = snapshot.data!.data();
                                        final String? profilePicture =
                                            data['profile-picture'];

                                        if (connectivity.connectivityResult ==
                                                ConnectivityResult.none ||
                                            profilePicture == null) {
                                          return showNoOtherUserProfilePicture(
                                              context, 150);
                                        }

                                        return showOtherUserProfilePicture(
                                            data['uid'],
                                            profilePicture,
                                            context,
                                            75);
                                      },
                                    ),
                                    const SizedBox(height: 20),
                                    ListTile(
                                      leading: Icon(Icons.person_rounded,
                                          color:
                                              Theme.of(context).primaryColor),
                                      title: Text(
                                        'Name',
                                        style: GoogleFonts.poppins(
                                            color: Colors.grey),
                                      ),
                                      subtitle: Text(otherUserMap['fullname']),
                                    ),
                                    ListTile(
                                      leading: Icon(Icons.email_rounded,
                                          color:
                                              Theme.of(context).primaryColor),
                                      title: Text(
                                        'Email',
                                        style: GoogleFonts.poppins(
                                            color: Colors.grey),
                                      ),
                                      subtitle: Text(otherUserMap['email']),
                                    ),
                                    ListTile(
                                      leading: Icon(Icons.phone_rounded,
                                          color:
                                              Theme.of(context).primaryColor),
                                      title: Text(
                                        'Contact',
                                        style: GoogleFonts.poppins(
                                            color: Colors.grey),
                                      ),
                                      subtitle: Text(otherUserMap['contact']),
                                    ),
                                    ListTile(
                                      leading: Icon(Icons.work_rounded,
                                          color:
                                              Theme.of(context).primaryColor),
                                      title: Text(
                                        'Role',
                                        style: GoogleFonts.poppins(
                                            color: Colors.grey),
                                      ),
                                      subtitle: Text(otherUserMap['user-type']),
                                    ),
                                    const SizedBox(height: 10),

                                    // todo: User Can Only Chat With Other Users If They Are Admins Or Non-Students
                                    otherUserMap['user-type'] != 'student' &&
                                            currentUserType != 'student'
                                        ? MyButton(
                                            onPressed: () {
                                              // Navigate to [other-user]'s Chat Page
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ChatPage(
                                                    roomId: getRoomId(
                                                        otherUserMap['email']),
                                                    receiverEmail:
                                                        otherUserMap['email'],
                                                  ),
                                                ),
                                              );
                                            },
                                            btnText:
                                                'Chat With $userFirstName!',
                                            isPrimary: false,
                                          )
                                        : Container(),
                                    const SizedBox(height: 10),

                                    isUserAdmin
                                        ? Column(
                                            children: [
                                              // todo: Only Admins Can Make / Unmake Other Users As Admins
                                              // make other users ADMIN iff they are not ADMIN already or remove their admin status
                                              !isOtherUserAdmin
                                                  // todo: Button To Make Other User An Admin
                                                  ? MyButton(
                                                      onPressed: () async {
                                                        try {
                                                          await administrator
                                                              .makeUserAdmin(
                                                                  otherUserMap[
                                                                      'uid']);
                                                          // udpate provider data
                                                          await setAllUsers();
                                                          if (context.mounted) {
                                                            // rebuild screen to change button
                                                            // setState(() {});
                                                            showSnackBar(
                                                                context,
                                                                'Success!');
                                                          }
                                                        } catch (e) {
                                                          showSnackBar(context,
                                                              'Error Making User Admin: ${e.toString()}');
                                                        }
                                                      },
                                                      btnText: 'Make Admin',
                                                      isPrimary: false,
                                                    )
                                                  // todo: Button To Undo User Admin Status
                                                  : MyButton(
                                                      onPressed: () async {
                                                        try {
                                                          await administrator
                                                              .removeUserAsAdmin(
                                                                  otherUserMap[
                                                                      'uid']);
                                                          // udpate provider data
                                                          await setAllUsers();
                                                          if (context.mounted) {
                                                            // rebuild screen to change button
                                                            // setState(() {});
                                                            showSnackBar(
                                                                context,
                                                                'Success!');
                                                          }
                                                        } catch (e) {
                                                          showSnackBar(context,
                                                              'Error Removing User As Admin: ${e.toString()}');
                                                        }
                                                      },
                                                      btnText: 'Remove Admin',
                                                      isPrimary: false,
                                                    ),
                                              const SizedBox(height: 10),

                                              // todo: Delete User Account (Only Non Admins Can Be Deleted)
                                              !isOtherUserAdmin
                                                  ? MyButton(
                                                      onPressed: () async {
                                                        try {
                                                          await administrator
                                                              .deleteUserAccount(
                                                                  uid: otherUserMap[
                                                                      'uid'],
                                                                  email: otherUserMap[
                                                                      'email']);
                                                          // udpate provider data
                                                          await setAllUsers();
                                                          if (context.mounted) {
                                                            showSnackBar(
                                                                context,
                                                                'Success!');
                                                            Navigator.pop(
                                                                context);
                                                          }
                                                        } catch (e) {
                                                          showSnackBar(context,
                                                              'Error Deleting User Account: ${e.toString()}');
                                                        }
                                                      },
                                                      btnText: 'Delete Account',
                                                      isPrimary: false,
                                                    )
                                                  : Container(),
                                            ],
                                          )
                                        : Container(),
                                  ],
                                )
                              // User's Account No Longer Exists
                              : Column(
                                  children: [
                                    const SizedBox(height: 100),
                                    const Icon(Icons.person_off_rounded,
                                        size: 100, color: Colors.red),
                                    const SizedBox(height: 50),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            widget.otherUserEmail,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                            maxLines: 1,
                                            softWrap: true,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const Text(
                                            ' Does Not Exist In Our Database.'),
                                      ],
                                    ),
                                    const SizedBox(height: 15),
                                    MyButton(
                                      btnText: 'Go back',
                                      isPrimary: false,
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    )
                                  ],
                                );
                        },
                      ),
                    ),
                  ),
                ),
                const MyBackButton(),
              ],
            ),
          );
  }

  Future<void> setAllUsers() async {
    await Provider.of<UserProvider>(context, listen: false).setAllUsers();
  }
}
