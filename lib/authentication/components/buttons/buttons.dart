import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  const MyButton({
    super.key,
    required this.onPressed,
    required this.btnText,
    required this.isPrimary,
  });
  final void Function()? onPressed;
  final String btnText;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    Color backgroundColor =
        isPrimary ? Theme.of(context).primaryColor : Colors.grey[300]!;
    Color textColor =
        !isPrimary ? Theme.of(context).primaryColor : Colors.white70;
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        minimumSize: const Size(double.infinity, 60),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      child: Text(
        btnText,
        style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 16),
        textAlign: TextAlign.center,
      ),
    );
  }
}
