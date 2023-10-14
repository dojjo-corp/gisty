import 'package:flutter/material.dart';

class MyTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData? iconData;
  final bool isWithIcon;
  final Iterable<String>? autofillHints;
  const MyTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.iconData,
    required this.isWithIcon,
    required this.autofillHints,
  });

  @override
  State<MyTextField> createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  Color prefixIconColor = Colors.grey;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autofillHints: widget.autofillHints,
      controller: widget.controller,
      obscureText: widget.hintText.toLowerCase() == 'password',
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(12),
        ),
        prefixIcon: widget.isWithIcon ? Icon(widget.iconData) : null,
        prefixIconColor: widget.isWithIcon ? prefixIconColor : null,
        hintText: widget.hintText,
        labelText: widget.hintText,
      ),
      onChanged: (String value) {
        if (value.isNotEmpty) {
          setState(() {
            prefixIconColor = Theme.of(context).primaryColor;
          });
        } else {
          setState(() {
            prefixIconColor = Colors.grey;
          });
        }
      },
      validator: (value) {
        if (value!.isEmpty) {
          return 'Field can\'t be empty!';
        }
        return null;
      },
    );
  }
}
