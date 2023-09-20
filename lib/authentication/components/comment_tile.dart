import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CommentTile extends StatefulWidget {
  final String commenter, commentText;
  final Timestamp timestamp;
  const CommentTile({
    super.key,
    required this.commenter,
    required this.commentText,
    required this.timestamp,
  });

  @override
  State<CommentTile> createState() => _CommentTileState();
}

class _CommentTileState extends State<CommentTile> {
  @override
  Widget build(BuildContext context) {
    final DateTime fullDate = widget.timestamp.toDate();
    final date = '${fullDate.year}-${fullDate.month}-${fullDate.day}';
    final time = '${fullDate.hour}:${fullDate.minute}';
    return ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      title: Text(
        widget.commenter,
        style: GoogleFonts.montserrat(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(widget.commentText),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(date,),
          Text(time)
        ],
      ),
    );
  }
}
