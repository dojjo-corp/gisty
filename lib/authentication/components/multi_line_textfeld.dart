import 'package:flutter/material.dart';

class MultiLineTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final int maxLines;
  const MultiLineTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.maxLines,
  });

  @override
  State<MultiLineTextField> createState() => _MultiLineTextFieldState();
}

class _MultiLineTextFieldState extends State<MultiLineTextField> {
  Color prefixIconColor = Colors.grey;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      minLines: 1,
      maxLines: widget.maxLines,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(12),
        ),
        hintText: widget.hintText,
        labelText: widget.hintText,
      ),
      onChanged: (String value) {
        if (value.isNotEmpty) {
          setState(() {
            prefixIconColor = Theme.of(context).primaryColor;
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
