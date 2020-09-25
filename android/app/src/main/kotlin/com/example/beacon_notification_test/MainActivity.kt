package com.example.beacon_notification_test

import io.flutter.embedding.android.FlutterActivity
import com.umair.beacons_plugin.BeaconsPlugin

class MainActivity: FlutterActivity() {

    override fun onPause() {

        super.onPause()

        //Start Background service to scan BLE devices
        BeaconsPlugin.startBackgroundService(this)
    }

    override fun onResume() {

        super.onResume()

        //Stop Background service, app is in foreground
        BeaconsPlugin.stopBackgroundService(this)
    }
}
