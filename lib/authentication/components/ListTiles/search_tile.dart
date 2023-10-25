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
    final subtitle = type == 'user'
        ? searchMap['user-type']
        : ' ${searchMap['year']} • ${searchMap['student-name']}';

    return ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[100]!),
      ),
      tileColor: Colors.grey[300],
      leading: type == 'user'
          ? Icon(
              Icons.person,
              color: Theme.of(context).primaryColor,
            )
          : Icon(
              Icons.menu_book_rounded,
              color: Theme.of(context).primaryColor,
            ),
      title: Text(
        title,
        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(subtitle),
      trailing: Text(
        type,
        style: const TextStyle(color: Colors.blue),
      ),
    );
  }
}
