String validateEmail(String value) {
  Pattern pattern =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  RegExp regex = new RegExp(pattern);
  if (!regex.hasMatch(value))
    return 'Enter Valid Email';
  else
    return null;
}

String emptyString(String value) {
  return value.isEmpty ? 'Enter Text' : null;
}

String incorrectUrl(String value, String errorMessage) {
  return value.startsWith("http://") || value.startsWith("https://") ? null : errorMessage;
}

String validateCurency(String value) {
  RegExp regex = new RegExp("^\$|^(0|([1-9][0-9]{0,99}))(\\.[0-9]{0,2})?\$");
  if (!regex.hasMatch(value))
    return 'Enter Valid Value';
  else
    return null;
}
