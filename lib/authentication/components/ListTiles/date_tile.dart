import 'package:flutter/material.dart';

class DateTile extends StatefulWidget {
  const DateTile({super.key});

  @override
  State<DateTile> createState() => _DateTileState();
}

class _DateTileState extends State<DateTile> {
  String dateText = 'Set Date';
  Color dateIconColor = Colors.grey;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime(2023),
          firstDate: DateTime(2023),
          lastDate: DateTime(2030, 12, 31),
        );
        if (date != null) {
          setState(() {
            dateText = date.toString().split(' ')[0];
            dateIconColor = Theme.of(context).primaryColor;
          });
        }
      },
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey[100]!),
        ),
        tileColor: Colors.white,
        leading: Icon(
          Icons.calendar_month_rounded,
          color: dateIconColor,
        ),
        title: Text(dateText),
      ),
    );
  }
}
