import 'package:flutter/material.dart';

class CustomAppBarButton extends StatelessWidget {
  final void Function()? onTap;
  final IconData iconData;
  final String tooltipMessage;
  final Color? color;
  final double? right;
  final double? left;
  const CustomAppBarButton({
    super.key,
    required this.onTap,
    required this.iconData,
    required this.tooltipMessage,
    this.color,
    this.right,
    this.left,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 40,
      right: 5,
      child: Tooltip(
        message: tooltipMessage,
        child: GestureDetector(
          onTap: onTap,
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
                child: Icon(
                  iconData,
                  size: 20,
                  weight: 10,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
