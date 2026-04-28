import 'package:http/http.dart' as http; // Alias the package for convenience
import 'package:flutter/services.dart';
import './axis_values.dart'; 


class ProcessAccelerations {
  static const MethodChannel _channel = MethodChannel('flutter.native/helper');
  static const String logURL = "http://192.168.50.89:778/AndroidAccelerations";
  static BigInt lastMillisecond = BigInt.zero;

  var xAxis = AxisValues();
  var yAxis = AxisValues();
  var zAxis = AxisValues();

  void integrateAccelerations(double mSec, double acceleration, AxisValues axisValues) {
    double seconds = mSec / 1000.0;

    double deltaV = ((acceleration + axisValues.previousAcceleration) / 2.0) * seconds;
    axisValues.previousAcceleration = acceleration;

    axisValues.velocity += deltaV;
    
  double deltaP = axisValues.velocity * seconds;
  axisValues.position += deltaP;
}

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
          LogSquat("squatly");
          var ax = double.parse(accelData['x'].toString());
          var ay = double.parse(accelData['y'].toString());
          var az = double.parse(accelData['z'].toString());

          lastMillisecond = BigInt.parse(accelData['ts'].toString());
          final mSec = p1.toDouble() / 1000000.0;
          integrateAccelerations(mSec, ax, xAxis);
          Log(p1, ax, ay, az, mSec);
          integrateAccelerations(mSec, ay, yAxis);
          integrateAccelerations(mSec, az, zAxis);
        }
        else {
          lastMillisecond = BigInt.parse(accelData['ts'].toString());
        }
        break;
      default:
        throw MissingPluginException('Not implemented');
    }
  }

double convertPosition(double pos) {
  var result = pos * 39.3701;
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
