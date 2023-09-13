import 'package:flutter/material.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return const Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
              accountName: Text('user name'), accountEmail: Text('user email')),
          ListTile(
            leading: Icon(Icons.person_rounded),
          )
        ],
      ),
    );
  }
}
