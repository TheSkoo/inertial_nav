package com.example.inertial_nav

data class AccelData(val ts: Long, val x: Double, val y: Double, val z: Double)

// In your native code, convert the User object to a Map
fun AccelDataToMap(accelData: AccelData): HashMap<String, Any?> {
    return hashMapOf(
        "ts" to accelData.ts,
        "x" to accelData.x,
        "y" to accelData.y,
        "z" to accelData.z,
    )
}