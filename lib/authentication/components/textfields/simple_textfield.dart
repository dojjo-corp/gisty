import 'package:flutter/material.dart';

class SimpleTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData? iconData;
  final bool isWithIcon;
  final Iterable<String>? autofillHints;

  final bool? enabled;
  const SimpleTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.isWithIcon,
    required this.autofillHints,
    this.iconData,
    this.enabled,
  });

  @override
  State<SimpleTextField> createState() => _SimpleTextFieldState();
}

class _SimpleTextFieldState extends State<SimpleTextField> {
  late bool showSuffixIcon;
  late bool obscureText;
  @override
  void initState() {
    super.initState();
    showSuffixIcon = widget.hintText.toLowerCase() == 'password';
    obscureText = showSuffixIcon;
  }

  Color prefixIconColor = Colors.grey;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autofillHints: widget.autofillHints,
      controller: widget.controller,
      obscureText: obscureText,
      enabled: widget.enabled ?? true,
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
        hintStyle: TextStyle(color: Colors.grey[400]),
        // only show suffix icon for a password textfield (to show/hide password text)
        suffixIcon: showSuffixIcon
            ? IconButton(
                onPressed: () {
                  setState(() {
                    obscureText = !obscureText;
                  });
                },
                icon: obscureText
                    ? const Icon(Icons.visibility_rounded, color: Colors.grey)
                    : const Icon(Icons.visibility_off_rounded,
                        color: Colors.grey),
              )
            : null,
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
          return '${widget.hintText} can\'t be empty!';
        }
        return null;
      },
    );
  }
}
