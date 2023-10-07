import 'package:flutter/material.dart';

import 'custom_back_button.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MyAppBar({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: const MyBackButton(),
      title: Text(title),
      backgroundColor: Colors.transparent,
    );
  }
  
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}