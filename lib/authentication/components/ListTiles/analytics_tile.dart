import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AnalyticsTile extends StatelessWidget {
  final String? title, subtitile;
  final double? trailing;
  const AnalyticsTile({
    super.key,
    required this.title,
    required this.subtitile,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[100]!),
      ),
      tileColor: Colors.grey[300],
      title: Text(
        title ?? '',
        style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        subtitile ?? '',
        softWrap: true,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text('${trailing ?? ''}'),
    );
  }
}
