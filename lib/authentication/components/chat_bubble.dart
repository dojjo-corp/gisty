import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatBubble extends StatelessWidget {
  final DateTime timeSent;
  final String text;
  final bool isIncomingText;
  const ChatBubble(
      {super.key, required this.text, required this.isIncomingText, required this.timeSent});

  @override
  Widget build(BuildContext context) {
    final DateTime now = timeSent;

    return Container(
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      margin: const EdgeInsets.only(bottom: 3),
      decoration: BoxDecoration(
        color: isIncomingText
            ? Colors.grey[400]
            : Theme.of(context).primaryColor.withOpacity(0.4),
        borderRadius: isIncomingText
            ? const BorderRadius.horizontal(
                right: Radius.circular(8), left: Radius.circular(3))
            : const BorderRadius.horizontal(
                right: Radius.circular(3), left: Radius.circular(8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            text,
            style: GoogleFonts.poppins(
              color: Colors.black87,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              )
            ],
          )
        ],
      ),
    );
  }
}
