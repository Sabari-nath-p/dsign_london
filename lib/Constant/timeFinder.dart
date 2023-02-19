import 'package:intl/intl.dart';

bool timeFinder(String time) {
  bool IsActive = true;

  List<String> timeData = time.split(" ");
  double hour = double.parse(timeData[0].split(":")[0]);
  if (timeData[1] == "PM" && hour != 12) {
    hour = hour + 12;
  }
  double currenthour = double.parse(DateFormat('HH').format(DateTime.now()));

  if (currenthour > hour - 1) IsActive = false;

  return IsActive;
}
