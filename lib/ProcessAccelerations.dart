import 'package:http/http.dart' as http; // Alias the package for convenience
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import './axis_values.dart'; 
import 'package:collection/collection.dart';

class ProcessAccelerations extends ChangeNotifier {
  static const MethodChannel _channel = MethodChannel('flutter.native/helper');
  static const String logURL = "http://192.168.50.89:778/AndroidAccelerations";
  static BigInt lastTimestamp = BigInt.zero;

  static const int calibration_threshold = 50;
  bool calibrating = true;
  int _calibrationCount = 0;
  List<double> _xData = [];
  List<double> _yData = [];
  double _xOffset = 0.0;
  double _yOffset = 0.0;

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
    LogSquat("Initialized ProcessAccelerations");
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
        final BigInt currentTs = BigInt.parse(accelData['ts'].toString());
        
        if (lastTimestamp != BigInt.zero) {
          var p1 = currentTs - lastTimestamp;
          var ax = double.parse(accelData['x'].toString());
          var ay = double.parse(accelData['y'].toString());
          var az = double.parse(accelData['z'].toString());

          if (_calibrationCount >= calibration_threshold) {
            if (calibrating) {
              _xOffset = -_xData.average;
              _yOffset = -_yData.average;
              calibrating = false;
              LogSquat("cal done x offset = $_xOffset, y offset = $_yOffset");
            }

            ax += _xOffset;
            ay += _yOffset;

            final mSec = p1.toDouble() / 1000000.0;
            integrateAccelerations(mSec, ax, xAxis);
            //Log(currentTs, ax, ay, az, mSec);
            integrateAccelerations(mSec, ay, yAxis);
            integrateAccelerations(mSec, az, zAxis);
            Log(currentTs, xAxis.position, yAxis.position, ax, mSec);
            notifyListeners();
          }
          else {
            _xData.add(ax);
            _yData.add(ay);
          }
          _calibrationCount++;
        }
        lastTimestamp = currentTs;
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
