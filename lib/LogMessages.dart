import 'package:http/http.dart' as http; // Alias the package for convenience

class LogMessage {
  static const String logURL = "http://192.168.50.89:778/AndroidLog?logMessage=";

void Log(String message) {
  http.post(
    Uri.parse(logURL + message),
    headers: {'Content-Type': 'application/json; charset=UTF-8'},
  ).then((resp) {
    print(resp.body);
  });
}
}