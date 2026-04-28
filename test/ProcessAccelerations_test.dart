import 'package:inertial_nav/ProcessAccelerations.dart';
import 'package:inertial_nav/axis_values.dart'; 
import 'package:test/test.dart';
import 'dart:math';

extension Precision on double {
  double toPrecision(int fractionDigits) {
    double mod = pow(10, fractionDigits).toDouble();
    return ((this * mod).round().toDouble() / mod);
  }
}

void main() {
  group('Test start, increment, decrement', () {
      test('All zero accelerations', () {
        var xAxis = AxisValues();
        final pa = ProcessAccelerations();
        pa.integrateAccelerations(160, 0.0, xAxis);
        expect(xAxis.previousAcceleration, 0.0);
        expect(xAxis.velocity, 0.0);
        expect(xAxis.position, 0.0);
      });
      test('Case 1', () {
        var xAxis = AxisValues();
        final pa = ProcessAccelerations();
        pa.integrateAccelerations(160, 1.0, xAxis);
        expect(xAxis.previousAcceleration, 1.0);
        expect(xAxis.velocity, 0.08);
        expect(xAxis.position, 0.0128);

        pa.integrateAccelerations(150, 0.0, xAxis);
        expect(xAxis.previousAcceleration, 0.0);
        expect(xAxis.velocity, 0.155);
        expect(xAxis.position, 0.03605);
        
        pa.integrateAccelerations(160, 0.0, xAxis);
        expect(xAxis.previousAcceleration, 0.0);
        expect(xAxis.velocity, 0.155);
        expect(xAxis.position, 0.06085);
        
        pa.integrateAccelerations(170, 0.0, xAxis);
        expect(xAxis.previousAcceleration, 0.0);
        expect(xAxis.velocity, 0.155);
        expect(xAxis.position, 0.0872);
        
        pa.integrateAccelerations(160, 0.0, xAxis);
        expect(xAxis.previousAcceleration, 0.0);
        expect(xAxis.velocity, 0.155);
        expect(xAxis.position, 0.112);
      });
      test('Case 2', () {
        var xAxis = AxisValues();
        final pa = ProcessAccelerations();
        pa.integrateAccelerations(160, -1.0, xAxis);
        expect(xAxis.previousAcceleration, -1.0);
        expect(xAxis.velocity.toPrecision(10), -0.08);
        expect(xAxis.position.toPrecision(10), -0.0128);

        pa.integrateAccelerations(150, 0.0, xAxis);
        expect(xAxis.previousAcceleration, 0.0);
        expect(xAxis.velocity.toPrecision(10), -0.155);
        expect(xAxis.position.toPrecision(10), -0.03605);
        
        pa.integrateAccelerations(160, 0.0, xAxis);
        expect(xAxis.previousAcceleration, 0.0);
        expect(xAxis.velocity.toPrecision(10), -0.155);
        expect(xAxis.position.toPrecision(10), -0.06085);
        
        pa.integrateAccelerations(170, 0.0, xAxis);
        expect(xAxis.previousAcceleration, 0.0);
        expect(xAxis.velocity.toPrecision(10), -0.155);
        expect(xAxis.position.toPrecision(10), -0.0872);
        
        pa.integrateAccelerations(160, 0.0, xAxis);
        expect(xAxis.previousAcceleration, 0.0);
        expect(xAxis.velocity.toPrecision(10), -0.155);
        expect(xAxis.position.toPrecision(10), -0.112);
      });
      test('Case 3', () {
        var xAxis = AxisValues();
        final pa = ProcessAccelerations();
        pa.integrateAccelerations(160, 1.0, xAxis);
        expect(xAxis.previousAcceleration, 1.0);
        expect(xAxis.velocity.toPrecision(10), 0.08);
        expect(xAxis.position.toPrecision(10), 0.0128);

        pa.integrateAccelerations(150, 0.5, xAxis);
        expect(xAxis.previousAcceleration, 0.5);
        expect(xAxis.velocity.toPrecision(10), 0.1925);
        expect(xAxis.position.toPrecision(10), 0.041675);
        
        pa.integrateAccelerations(160, -0.1, xAxis);
        expect(xAxis.previousAcceleration, -0.1);
        expect(xAxis.velocity.toPrecision(10), 0.2245);
        expect(xAxis.position.toPrecision(10), 0.077595);
        
        pa.integrateAccelerations(170, -0.75, xAxis);
        expect(xAxis.previousAcceleration, -0.75);
        expect(xAxis.velocity.toPrecision(10), 0.15225);
        expect(xAxis.position.toPrecision(10), 0.1034775);
        
        pa.integrateAccelerations(160, -1.2, xAxis);
        expect(xAxis.previousAcceleration, -1.2);
        expect(xAxis.velocity.toPrecision(10), -0.00375);
        expect(xAxis.position.toPrecision(10), 0.1028775);
      });
      test('Meters to inches 0 meters', () {
        final pa = ProcessAccelerations();
        var inches = pa.convertPosition(0.0);
        expect(inches, 0.0, reason: " meter = 0 inches");
        inches = pa.convertPosition(1.0);
        expect(inches, 39.3701, reason: "1 meter = 39.3701 inches");
      });
  });
}