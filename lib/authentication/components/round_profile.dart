import 'package:flutter/material.dart';

class RoundProfile extends StatelessWidget {
  const RoundProfile({
    super.key,
    required this.onTap,
    required this.image,
  });
  final VoidCallback onTap;
  final String image;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 30,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        child: Image.asset(image),
      ),
    );
  }
}
