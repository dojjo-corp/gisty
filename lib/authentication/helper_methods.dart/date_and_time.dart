String formatDateToString(DateTime date) {
  // "MMM dd, yyyy"
  return "${date.month} ${date.day}, ${date.year}";
}

String formatTime (DateTime date){
  int hour = date.hour;
  int minute = date.minute;
  String hourText = hour.toString().padLeft(2, '0');
  String minuteText = minute.toString().padLeft(2, '0');
  return '$hourText:$minuteText'; 
}

String formatMonth(int monthNum) {
  switch (monthNum) {
    case 1:
      return 'Jan';
    case 2:
      return 'Feb';
    case 3:
      return 'Mar';
    case 4:
      return 'Apr';
    case 5:
      return 'May';
    case 6:
      return 'Jun';
    case 7:
      return 'Jul';
    case 8:
      return 'Aug';
    case 9:
      return 'Sep';
    case 10:
      return 'Oct';
    case 11:
      return 'Nov';
    case 12:
      return 'Dec';
    default:
      return 'unknown';
  }
}
