import 'package:flutter/material.dart';

class MyBackButton extends StatelessWidget {
  const MyBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 40,
      left: 5,
      child: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[200]!.withOpacity(0.7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 40, maxWidth: 40),
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              child: const Icon(Icons.arrow_back_ios_rounded,
                  size: 20, weight: 10),
            ),
          ),
        ),
      ),
    );
  }
}
