package com.example.tsp

import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothManager
import android.bluetooth.BluetoothProfile
import android.content.Context
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "bluetooth_channel"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getConnectedBluetoothDevices") {
                getConnectedBluetoothDevices(result)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun getConnectedBluetoothDevices(result: MethodChannel.Result) {
        val bluetoothManager = getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager
        val bluetoothAdapter: BluetoothAdapter? = bluetoothManager.adapter
        val connectedDevicesList = mutableListOf<Map<String, Any>>()

        if (bluetoothAdapter == null || !bluetoothAdapter.isEnabled) {
            Log.e("Bluetooth", "❌ Bluetooth is disabled or not available")
            result.success(emptyList<Map<String, Any>>()) // Return empty list
            return
        }

        val profiles = listOf(
            BluetoothProfile.A2DP,  // 🔹 Audio devices (earbuds, speakers)
            BluetoothProfile.HEADSET // 🔹 Headset profile
        )

        var completedProfiles = 0

        for (profile in profiles) {
            bluetoothAdapter.getProfileProxy(this, object : BluetoothProfile.ServiceListener {
                override fun onServiceConnected(profile: Int, proxy: BluetoothProfile) {
                    val devices = proxy.connectedDevices
                    for (device in devices) {
                        val deviceInfo = mapOf(
                            "name" to (device.name ?: "Unknown Device"),
                            "address" to device.address,
                            "profile" to getProfileName(profile),
                            "deviceType" to getDeviceType(device)
                        )
                        connectedDevicesList.add(deviceInfo)
                    }
                    bluetoothAdapter.closeProfileProxy(profile, proxy)

                    // Wait until all profiles are fetched
                    completedProfiles++
                    if (completedProfiles == profiles.size) {
                        Handler(Looper.getMainLooper()).post {
                            result.success(connectedDevicesList)
                        }
                    }
                }

                override fun onServiceDisconnected(profile: Int) {}
            }, profile)
        }
    }

    private fun getProfileName(profile: Int): String {
        return when (profile) {
            BluetoothProfile.A2DP -> "A2DP (Audio)"
            BluetoothProfile.HEADSET -> "Headset"
            else -> "Unknown Profile"
        }
    }

    private fun getDeviceType(device: BluetoothDevice): String {
        return when (device.type) {
            BluetoothDevice.DEVICE_TYPE_CLASSIC -> "Classic"
            BluetoothDevice.DEVICE_TYPE_LE -> "Low Energy (LE)"
            BluetoothDevice.DEVICE_TYPE_DUAL -> "Dual Mode"
            else -> "Unknown"
        }
    }
}
