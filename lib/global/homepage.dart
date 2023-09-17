// ignore: unused_import
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

import '../authentication/components/drawer.dart';
import '../authentication/pages/account_page.dart';
import '../authentication/pages/dsahboard.dart';
import '../authentication/pages/events_page.dart';
import '../authentication/pages/search_page.dart';

// ignore: must_be_immutable
class MyHomePage extends StatefulWidget {
  MyHomePage({super.key, required this.pageIndex});

  int pageIndex;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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
        ),
        drawer: const MyDrawer(),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
          ),
          child: GNav(
            gap: 8,
            mainAxisAlignment: MainAxisAlignment.center,
            selectedIndex: widget.pageIndex,
            padding: const EdgeInsets.all(20),
            onTabChange: changePageIndex,
            activeColor: Theme.of(context).primaryColor,
            tabs: [
              GButton(
                icon: Icons.space_dashboard_rounded,
                iconColor: Colors.grey,
                text: 'Home',
                textColor: Theme.of(context).primaryColor,
              ),
              GButton(
                icon: Icons.search_rounded,
                iconColor: Colors.grey,
                text: 'Search',
                textColor: Theme.of(context).primaryColor,
              ),
              GButton(
                icon: Icons.event_rounded,
                iconColor: Colors.grey,
                text: 'Events',
                textColor: Theme.of(context).primaryColor,
              ),
              GButton(
                icon: Icons.person,
                iconColor: Colors.grey,
                text: 'Account',
                textColor: Theme.of(context).primaryColor,
              ),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: _pages[widget.pageIndex],
        ),
        resizeToAvoidBottomInset: true,
      ),
    );
  }
}
