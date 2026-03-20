import 'package:http/http.dart' as http; // Alias the package for convenience
import 'package:flutter/services.dart';

class ProcessAccelerations {
  static const MethodChannel _channel = MethodChannel('flutter.native/helper');
  static const String logURL = "http://192.168.50.89:778/AndroidAccelerations";
  static BigInt lastMillisecond = BigInt.parse("0");
  void Initialize() {
    _channel.setMethodCallHandler(nativeMethodCallHandler);
  }

  Future<dynamic> nativeMethodCallHandler(MethodCall methodCall) async {
    switch (methodCall.method) {
      case "processData":
        // Handle the method call from Android
        final Map<String, dynamic>? accelData = methodCall.arguments.cast<String, dynamic>();
      if (accelData != null && lastMillisecond != BigInt.parse("0")) {
        var p1 = BigInt.parse(accelData['ts'].toString()) - lastMillisecond;
        var p2 = double.parse(accelData['x'].toString());
        var p3 = double.parse(accelData['y'].toString());
        var p4 = double.parse(accelData['z'].toString());
        lastMillisecond = BigInt.parse(accelData['ts'].toString());
        Log(p1, p2, p3, p4);
      }
      else {
        if (accelData == null)
        {
          LogSquat("accelData is null");
        }
        lastMillisecond = BigInt.parse(accelData['ts'].toString());
      }

      default:
        throw MissingPluginException('Not implemented');
    }
  }

void LogSquat(String message) {
  http.post(
    Uri.parse("http://192.168.50.89:778/AndroidLog?logMessage=" + message),
    headers: {'Content-Type': 'application/json; charset=UTF-8'},
  ).then((resp) {
    print(resp.body);
  });
}

void Log(BigInt timeStamp, double x, double y, double z) {
  http.post(
    Uri.parse("$logURL?timeStamp=$timeStamp&x=$x&y=$y&z=$z"),
    headers: {'Content-Type': 'application/json; charset=UTF-8'},
  ).then((resp) {
    print(resp.body);
  });
  }
}
