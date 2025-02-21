import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    // GOOGLE API KEY
    GMSServices.provideAPIKey("API_KEY")
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
