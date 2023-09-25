import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchTile extends StatelessWidget {
  final String type;
  final Map<String, dynamic> searchMap;
  const SearchTile({
    super.key,
    required this.searchMap,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final title = type == 'user'
        ? searchMap['fullname'] ?? searchMap['full-name']
        : searchMap['title'];
    final subtitle =
        type == 'user' ? searchMap['user-type'] : searchMap['student-name'];

    return ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        tileColor: Colors.white60,
        leading: type == 'user'
            ? const Icon(Icons.person)
            : const Icon(Icons.menu_book_rounded),
        title: Text(
          title,
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle),
        trailing: Text(
          type,
          style: const TextStyle(color: Colors.blue),
        ));
  }
}
