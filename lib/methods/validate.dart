bool isValidDate(String date) {
  RegExp regExp = RegExp(r'^\d{4}-(0[1-9]|1[012])-(0[1-9]|[12][0-9]|3[01])$');
  return regExp.hasMatch(date);
}

bool isValidTime(String time) {
  RegExp regExp = RegExp(r'^(0[0-9]|1[0-9]|2[0-3])[0-5][0-9]$');
  return regExp.hasMatch(time);
}

bool isYyyyMMdd(String date) {
  RegExp regExp = RegExp(r'^\d{4}(0[1-9]|1[012])(0[1-9]|[12][0-9]|3[01])$');
  return regExp.hasMatch(date);
}
