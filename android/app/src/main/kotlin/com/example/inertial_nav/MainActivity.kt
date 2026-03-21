package com.example.inertial_nav

import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.hardware.SensorManager

import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity(), SensorEventListener
{
    private val CHANNEL = "flutter.native/helper"
    private lateinit var channel: MethodChannel
    private var getAccelerations: GetAccels? = null
    private lateinit var mSensorManager : SensorManager
    private var mAccelerometer : Sensor ?= null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Your existing MethodChannel setup or other configurations
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        getAccelerations = GetAccels(applicationContext, flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        getAccelerations?.TestChannel()
        mSensorManager = getSystemService(Context.SENSOR_SERVICE) as SensorManager
        mAccelerometer = mSensorManager.getDefaultSensor(Sensor.TYPE_LINEAR_ACCELERATION)
        if (mAccelerometer != null) {
           // mSensorManager.registerListener(this, mAccelerometer, SensorManager.SENSOR_DELAY_NORMAL)
            mSensorManager.registerListener(this, mAccelerometer, 200000)
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        // Clean up when the activity is destroyed
        getAccelerations?.destroy()
    }
    override fun onSensorChanged(event: SensorEvent?) {
       if (event != null) {
           if (event.sensor.type == Sensor.TYPE_LINEAR_ACCELERATION) {
               val x = event.values[0].toDouble()
               val y = event.values[1].toDouble()
               val z = event.values[2].toDouble()
               getAccelerations?.LogAccels(event.timestamp, x, y, z)
           }
       }
    }
    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {
        var x = 1.0
        x = x * 1.3
    }
}
