import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    TalkingDataAppAnalyticsPlugin.pluginSessionStart("31BB4D12E12848B6B55889BA9D4CB6F6", withChannelId: "1482599438")
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
