import 'package:http/http.dart' as http; // Alias the package for convenience
import 'package:flutter/services.dart';
import 'dart:math' as math;

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
  static double deltaVx = 0.0;
  static double previousAx = 0.0;

  double PositionX = 0.0;
  double PositionY = 0.0;
  double PositionZ = 0.0;

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
          //Log(p1, p2, p3, p4, mSec);
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

var isRunning = false;
void integrateAccelerations(double mSec, double x, double y, double z) {
  if (isRunning) {
    LogSquat("ReEntered");
  }

  isRunning = true;
  try{
  double seconds = mSec / 1000.0;

  deltaVx = (((x + previousAx) / 2.0) - 0.0012145351910708) * seconds;
  previousAx = x;

  double deltaVy = y * seconds;
  double deltaVz = z * seconds;
 
  velocityX += deltaVx;
  velocityY += deltaVy;
  velocityZ += deltaVz;
    
  double deltaPx = velocityX * seconds;
  double deltaPy = velocityY * seconds;
  double deltaPz = velocityZ * seconds;
  positionX += deltaPx;
  positionY += deltaPy;
  positionZ += deltaPz;
  
   PositionX = positionX;
   PositionY = convertPosition(positionY);
   PositionZ = convertPosition(positionZ);
   Log(BigInt.from(mSec.toInt()), x, deltaVx, velocityX, seconds);
}
finally {
isRunning = false;
}
  }

double convertPosition(double pos) {
  var result = pos * 39.3701;
  result = (result * math.pow(10, 2)).truncate() / math.pow(10, 2);
  return result;
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
