package com.example.method_app

import android.content.Context
import android.os.BatteryManager
import android.os.Handler
import android.os.Looper
import androidx.core.app.NotificationCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import java.text.SimpleDateFormat
import java.util.Date
import android.R.drawable
import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build

class MainActivity : FlutterActivity() {
    private val channel: String = "native_channel"
    private val eventChannel: String = "native_event"


    object TimeHandler : EventChannel.StreamHandler {
        private var event: EventChannel.EventSink? = null
        private var handler = Handler(Looper.getMainLooper())
        override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
            event = events
            val run = object : Runnable {
                override fun run() {
                    handler.post {
                        val dateFormat = SimpleDateFormat("HH:mm:ss")
                        val time = dateFormat.format(Date())
                        events?.success(time)
                    }
                    handler.postDelayed(this, 1000)
                }
            }
            handler.postDelayed(run, 1000)
        }

        override fun onCancel(arguments: Any?) {
            event = null
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, eventChannel).setStreamHandler(
            TimeHandler
        )

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger, channel
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getDataFromNative" -> {
                    val data: String = getDataFromNative()
                    result.success(data)
                }

                "getBatteryLevel" -> {
                    val batteryLevel: Int = getBatteryLevel()
                    result.success(batteryLevel)
                }

                "nativeNotification" -> {
                    val content: String? = call.argument("content")
                    if (content == null) {
                        result.error(
                            "Wrong key passed",
                            "you passed the wrong argument key instead of content ",
                            "Please check the argument key you passed"
                        )
                    } else {
                        invokeNotification(content, result)
                    }
                }

                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun getDataFromNative(): String {
        return "From Native Android"
    }

    private fun getBatteryLevel(): Int {
        val batteryManager2 = getSystemService(Context.BATTERY_SERVICE) as BatteryManager
        return batteryManager2.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
    }

    private fun invokeNotification(title: String, flutterResult: MethodChannel.Result) {
        val channelId = "NATIVE_NOTIFICATION"
        flutterResult.success("Check Notifications")
        val notificationManager: NotificationManager =
            getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val notificationChannel =
                NotificationChannel(channelId, title, NotificationManager.IMPORTANCE_HIGH)
            notificationManager.createNotificationChannel(notificationChannel)
            val builder =
                NotificationCompat.Builder(applicationContext, channelId).setContentText(title)
                    .setSmallIcon(drawable.ic_dialog_info)
                    .setOnlyAlertOnce(true)
                    .setAutoCancel(false)
                    .setPriority(NotificationCompat.PRIORITY_MAX)
            notificationManager.notify(1, builder.build())
        }

        val builder =
            NotificationCompat.Builder(applicationContext, channelId).setContentText(title)
                .setSmallIcon(drawable.ic_dialog_info)
                .setOnlyAlertOnce(true)
                .setAutoCancel(false)
                .setPriority(NotificationCompat.PRIORITY_MAX)
        notificationManager.notify(1, builder.build())
    }
}
