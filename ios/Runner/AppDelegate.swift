import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    private let CHANNEL = "native_channel"
    private let EVENT_CHANNEL = "native_event"
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      if let flutterViewController = window?.rootViewController as? FlutterViewController{
          let methodChannel = FlutterMethodChannel(name: CHANNEL, binaryMessenger: flutterViewController.binaryMessenger)
          methodChannel.setMethodCallHandler { [weak self] (call : FlutterMethodCall, result: FlutterResult) in
              if call.method == "getDataFromNative"{
                  let data : String?  = self?.getDataFromNative()
                  result(data)
              } else if call.method == "getBatteryLevel" {
                   self?.getBatteryLevel(result: result)
                  
              } else {
                  result(FlutterError(code: "Invoked Wrong method", message: "Please check if the method is correctly added", details: nil))
              }
          }
      }
      if let flutterViewStreamController = window?.rootViewController as? FlutterViewController{
          let eventChannel = FlutterEventChannel(name: EVENT_CHANNEL, binaryMessenger: flutterViewStreamController.binaryMessenger);
          eventChannel.setStreamHandler(TimeHandler())
      }
      
      
      
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    private func getDataFromNative() -> String{
        return "From Native ios"
    }
    
    private func getBatteryLevel(result: FlutterResult) {
        let device = UIDevice.current
        device.isBatteryMonitoringEnabled = true
        if device.batteryState == UIDevice.BatteryState.unknown {
            result(FlutterError(code: "NOT AVAILABLE", message: "Please check if you are using the simulator or a physical device", details: nil))
        }
        result(device.batteryLevel * 100)
    }
}
class TimeHandler : NSObject, FlutterStreamHandler {
    var timer = Timer()
    private var eventSink : FlutterEventSink?
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: {time in
            let dateFormat = DateFormatter()
            dateFormat.dateFormat = "HH:mm:ss"
            let time = dateFormat.string(from: Date())
            events(time)
        })
        return nil
    }
}

