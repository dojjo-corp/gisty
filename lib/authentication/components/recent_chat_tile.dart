import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../pages/messaging/chat_page.dart';
import '../repository/firestore_repo.dart';

class RecentChatTile extends StatelessWidget {
  final String sender, receiver;
  final Map<String, dynamic> lastTextData;
  const RecentChatTile({
    super.key,
    required this.sender,
    required this.receiver,
    required this.lastTextData,
  });

  String getRoomId(String receiverEmail) {
    String roomId = '';
    final ids = [currentUser!.email, receiverEmail];
    ids.sort();
    roomId = ids.join();
    return roomId;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(
              roomId: getRoomId(receiver),
            ),
          ),
        );
      },
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        tileColor: Colors.white70,
        title: Text(
          receiver,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        subtitle: Row(
          children: [
            Flexible(
              child: Text(
                sender.contains(currentUser!.displayName!)
                    ? 'You:'
                    : sender.split(' ')[0],
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ),
            Flexible(
              child: Text(lastTextData['text']),
            ),
          ],
        ),
      ),
    );
  }
}
