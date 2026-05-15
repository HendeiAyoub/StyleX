import Foundation

class BridgeManager: NSObject {
  static let shared = BridgeManager()

  public func loadReactNative(launchOptions: [AnyHashable: Any]?) {
    // React Native is disabled for the local AI demo path.
  }
}
