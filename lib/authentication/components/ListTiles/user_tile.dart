import 'package:flutter/material.dart';
import 'package:gt_daily/authentication/pages/user%20account/other_user_account_page.dart';

class UserTile extends StatelessWidget {
  final Map<String, dynamic> userData;
  final void Function()? onDeleteButtonPressed;
  const UserTile({
    super.key,
    required this.userData,
    required this.onDeleteButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                OtherUserAccountPage(otherUserEmail: userData['email']),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 5),
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey[100]!),
          ),
          tileColor: Colors.white,
          leading: Icon(
            Icons.person,
            color: Theme.of(context).primaryColor,
          ),
          title: Text(userData['fullname']),
          subtitle: Text(userData['email']),
          trailing: Tooltip(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.blueGrey[100],
            ),
            message: 'Delete ${userData['fullname'].split(' ')[0]}\'s Account',
            textStyle: TextStyle(color: Colors.grey[700]),
            triggerMode: TooltipTriggerMode.longPress,
            child: IconButton(
              onPressed: onDeleteButtonPressed,
              icon: Icon(
                Icons.delete_rounded,
                color: Colors.red[300],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
