import 'package:http/http.dart' as http; // Alias the package for convenience
import 'package:flutter/services.dart';

class ProcessAccelerations {
  static const MethodChannel _channel = MethodChannel('flutter.native/helper');
  static const String logURL = "http://192.168.50.89:778/AndroidAccelerations";
  static BigInt lastMillisecond = BigInt.zero;

  static double velocityX = 0.0;
  static double velocityY = 0.0;
  static double velocityZ = 0.0;
  static double positionX = 0.0;
  static double positionY = 0.0;
  static double positionZ = 0.0;
    
  void Initialize() {
    _channel.setMethodCallHandler(nativeMethodCallHandler);
  }

  Future<dynamic> nativeMethodCallHandler(MethodCall methodCall) async {
    switch (methodCall.method) {
      case "processData":
        // Handle the method call from Android
        final Map<dynamic, dynamic>? args = methodCall.arguments as Map<dynamic, dynamic>?;
        if (args == null) {
          LogSquat("accelData is null");
          return;
        }
        
        final Map<String, dynamic> accelData = args.cast<String, dynamic>();
        
        if (lastMillisecond != BigInt.zero) {
          var p1 = BigInt.parse(accelData['ts'].toString()) - lastMillisecond;
          var p2 = double.parse(accelData['x'].toString());
          var p3 = double.parse(accelData['y'].toString());
          var p4 = double.parse(accelData['z'].toString());

          lastMillisecond = BigInt.parse(accelData['ts'].toString());
          final mSec = p1.toDouble() / 1000000.0;
          Log(p1, p2, p3, p4, mSec);
          integrateAccelerations(mSec, p2, p3, p4);
        }
        else {
          lastMillisecond = BigInt.parse(accelData['ts'].toString());
        }
        break;
      default:
        throw MissingPluginException('Not implemented');
    }
  }

void integrateAccelerations(double mSec, double x, double y, double z) {
  double seconds = mSec / 1000.0;

  double deltaVx = x * seconds;
  double deltaVy = y * seconds;
  double deltaVz = z * seconds;
  velocityX += deltaVx;
  velocityY += deltaVy;
  velocityZ += deltaVz;
  var msg = "deltaVx = " + deltaVx.toString() + ": velocityX = " + velocityX.toString();
  LogSquat(msg);
  msg = "deltaVy = " + deltaVy.toString() + ": velocityY = " + velocityY.toString();
  LogSquat(msg);
  msg = "deltaVz = " + deltaVz.toString() + ": velocityZ = " + velocityZ.toString();
  LogSquat(msg);
  
  double deltaPx = velocityX * seconds;
  double deltaPy = velocityY * seconds;
  double deltaPz = velocityZ * seconds;
  positionX += deltaPx;
  positionY += deltaPy;
  positionZ += deltaPz;
  msg = "deltaPx = " + deltaPx.toString() + ": positionX = " + positionX.toString();
  LogSquat(msg);
  msg = "deltaPy = " + deltaPy.toString() + ": positionY = " + positionY.toString();
  LogSquat(msg);
  msg = "deltaPz = " + deltaPz.toString() + ": positionZ = " + positionZ.toString();
  LogSquat(msg);

  LogSquat("");
 }

void LogSquat(String message) {
  http.post(
    Uri.parse("http://192.168.50.89:778/AndroidLog?logMessage=${Uri.encodeComponent(message)}"),
    headers: {'Content-Type': 'application/json; charset=UTF-8'},
  ).then((resp) {
    print(resp.body);
  });
}

void Log(BigInt timeStamp, double x, double y, double z, double mSec) {
  http.post(
    Uri.parse("$logURL?timeStamp=$timeStamp&x=$x&y=$y&z=$z&milliSeconds=$mSec"),
    headers: {'Content-Type': 'application/json; charset=UTF-8'},
  ).then((resp) {
    print(resp.body);
  });
  }
}
