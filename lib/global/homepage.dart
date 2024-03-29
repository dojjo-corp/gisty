// ignore: unused_import
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:gt_daily/authentication/pages/projects/supervised_projects.dart';
import 'package:gt_daily/authentication/providers/projects_provider.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

import '../authentication/components/drawer.dart';
import '../authentication/components/loading_circle.dart';
import '../authentication/helper_methods.dart/global.dart';
import '../authentication/pages/user account/account_page.dart';
import '../authentication/pages/events/events_page.dart';
import '../authentication/pages/projects/dashboard.dart';
import '../authentication/pages/search_page.dart';
import '../authentication/providers/user_provider.dart';

// ignore: must_be_immutable
class MyHomePage extends StatefulWidget {
  MyHomePage({super.key, required this.pageIndex});

  int pageIndex;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _dataLoaded = false;

  @override
  void initState() {
    super.initState();
    // Fetch user data when the app is launched
    _initializeAppData().then((_) {
      setState(() {
        _dataLoaded = true;
      });
    });

    // todo: Set User As Online On App Start/Launch
    updateUserOnlineStatus(true);

    // Update Online Status Based On App State (foreground/background)
    SystemChannels.lifecycle.setMessageHandler((message) {
      if (message.toString().contains('resumed')) {
        updateUserOnlineStatus(true);
      } else {
        updateUserOnlineStatus(false);
      }
      return Future.value(message);
    });
  }

  Future<void> _initializeAppData() async {
    Provider.of<UserProvider>(context, listen: false).setAllUsers();
    Provider.of<ProjectProvider>(context, listen: false).setCategories();
  }

  final List<Widget> _pages = [
    const Dashboard(),
    const SearchPage(),
    const EventsPage(),
    const UserAccountPage(),
  ];
  final List<String> _pageTitle = [
    'Dashboard',
    'Search',
    'Events',
    'Account',
  ];

  @override
  Widget build(BuildContext context) {
    if (!_dataLoaded) {
      return const LoadingCircle();
    }
    void changePageIndex(int index) => setState(
          () {
            widget.pageIndex = index;
          },
        );
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _pageTitle[widget.pageIndex],
            style: GoogleFonts.montserrat(letterSpacing: 5),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          actions: [
            Provider.of<UserProvider>(context).userType.toLowerCase() ==
                    'university professional'
                ? IconButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SupervisedProjects(),
                          ));
                    },
                    icon: Icon(
                      Icons.school_rounded,
                      color: Theme.of(context).primaryColor,
                    ),
                    tooltip: 'Projects You\'ve Supervised',
                  )
                : Container(),
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('Notifications')
                  .doc(FirebaseAuth.instance.currentUser?.email)
                  .snapshots()
                  .throttleTime(const Duration(milliseconds: 100)),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.hasError) {
                  return IconButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/notifications');
                    },
                    icon: const Icon(Icons.notifications_rounded),
                  );
                }

                final docSnapshot = snapshot.data!;
                final docData = docSnapshot.data();
                if (docData == null) {
                  return IconButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/notifications');
                    },
                    icon: const Icon(Icons.notifications_rounded),
                  );
                }

                final myNotifications = docData['my-notifications'] as List;
                final unreadNum = myNotifications
                    .where((element) => !element['read'])
                    .toList()
                    .length;

                return unreadNum < 1
                    ? IconButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/notifications');
                        },
                        icon: Icon(
                          Icons.notifications_rounded,
                          color: Theme.of(context).primaryColor,
                        ),
                      )
                    : Badge.count(
                        count: unreadNum,
                        offset: const Offset(-6, 6),
                        child: IconButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/notifications');
                          },
                          icon: Icon(
                            Icons.notifications_active_rounded,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      );
              },
            )
          ],
        ),
        drawer: const MyDrawer(),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            color: Colors.grey[700],
          ),
          child: GNav(
            gap: 8,
            padding: const EdgeInsets.all(18),
            tabBorderRadius: 15,
            tabMargin: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
            mainAxisAlignment: MainAxisAlignment.center,
            selectedIndex: widget.pageIndex,
            onTabChange: changePageIndex,
            activeColor: Colors.white,
            // backgroundColor: Colors.grey[800]!,
            tabs: const [
              GButton(
                icon: Icons.space_dashboard_rounded,
                iconColor: Colors.grey,
                text: 'Home',
                textColor: Colors.white,
              ),
              GButton(
                icon: Icons.search_rounded,
                iconColor: Colors.grey,
                text: 'Search',
                textColor: Colors.white,
              ),
              GButton(
                icon: Icons.event_rounded,
                iconColor: Colors.grey,
                text: 'Events',
                textColor: Colors.white,
              ),
              GButton(
                icon: Icons.person,
                iconColor: Colors.grey,
                text: 'Account',
                textColor: Colors.white,
              ),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.only(left: 15.0, right: 15),
          child: _pages[widget.pageIndex],
        ),
      ),
    );
  }
}
