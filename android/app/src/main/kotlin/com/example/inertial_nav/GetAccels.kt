package com.example.inertial_nav

import android.content.Context
//import androidx.appcompat.app.AppCompatActivity
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall

class GetAccels(
    private val context: Context,
    binaryMessenger: BinaryMessenger,
    channelName: String) : MethodChannel.MethodCallHandler {
    private val channel: MethodChannel = MethodChannel(binaryMessenger, channelName)
    //private val mSensorManager = sensorManager
    //private var mAccelerometer : Sensor ?= null

    init {
        // Set the method call handler for this channel
        channel.setMethodCallHandler(this)
        //mAccelerometer = mSensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER)
    }

    fun LogAccels(ts: Long, x: Double, y: Double, z: Double) {
        val accelData = AccelData(ts, x, y, z)
        val pm = AccelDataToMap(accelData)
        channel.invokeMethod("processData", pm, object : MethodChannel.Result {
            override fun success(result: Any?) {
                // This is called when Dart returns a result
                println("Result from Dart: $result")
            }

            override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
                // Handle errors from the Dart side
                println("Error from Dart: $errorMessage")
            }

            override fun notImplemented() {
                // Handle cases where the method isn't implemented in Dart
                println("Dart method not implemented")
            }
        })
    }

    fun TestChannel() {
        val accelData = AccelData(123, 1.1, 2.2, 3.3)
        val pm = AccelDataToMap(accelData)

/*        channel.invokeMethod("processData", pm, object : MethodChannel.Result {
            override fun success(result: Any?) {
                // This is called when Dart returns a result
                println("Result from Dart: $result")
            }

            override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
                // Handle errors from the Dart side
                println("Error from Dart: $errorMessage")
            }

            override fun notImplemented() {
                // Handle cases where the method isn't implemented in Dart
                println("Dart method not implemented")
            }
        })*/
    }

    override fun onMethodCall(
        call: MethodCall,
        result: MethodChannel.Result
    ) {
        when (call.method) {
            "processData" -> {
                // Use the context for native operations (e.g., accessing SharedPreferences, starting an Activity)
                val data = "fun onMethodCall is being used"
                result.success(data)
            }

            else -> {
                result.notImplemented()
            }
        }
    }


    fun destroy() {
        channel.setMethodCallHandler(null)
    }
}