import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatBubble extends StatefulWidget {
  final DateTime timeSent;
  final String text;
  final bool isIncomingText;
  final bool isDeleted;
  const ChatBubble({
    super.key,
    required this.text,
    required this.isIncomingText,
    required this.timeSent,
    required this.isDeleted,
  });

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  bool showTime = false;
  @override
  Widget build(BuildContext context) {
    final DateTime now = widget.timeSent;
    final alignment =
        widget.isIncomingText ? Alignment.bottomLeft : Alignment.bottomRight;

    return Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              showTime = !showTime;
            });
          },
          child: Container(
            alignment: alignment,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              margin: const EdgeInsets.only(bottom: 3),
              decoration: BoxDecoration(
                color: widget.isIncomingText
                    ? Colors.grey[400]
                    : Theme.of(context).primaryColor.withOpacity(0.4),
                borderRadius: widget.isIncomingText
                    ? const BorderRadius.horizontal(
                        right: Radius.circular(8), left: Radius.circular(3))
                    : const BorderRadius.horizontal(
                        right: Radius.circular(3), left: Radius.circular(8)),
              ),
              child: !widget.isDeleted
                  ? Text(
                      widget.text.trimRight(),
                      style: GoogleFonts.poppins(
                        color: Colors.black87,
                      ),
                    )
                  : Text(
                      'this message is deleted',
                      style: TextStyle(
                          fontStyle: FontStyle.italic, color: Colors.grey[600]),
                    ),
            ),
          ),
        ),
        showTime
            ? Container(
                alignment: alignment,
                child: Text(
                  '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              )
            : Container()
      ],
    );
  }
}
