import Foundation
import React

class BridgeManager: NSObject {
  static let shared = BridgeManager()

  var bridge: RCTBridge?

  public func loadReactNative(launchOptions: [AnyHashable: Any]?) {
    bridge = RCTBridge(delegate: self, launchOptions: launchOptions)
  }
}

extension BridgeManager: RCTBridgeDelegate {
  func sourceURL(for _: RCTBridge) -> URL? {
    if let bundledURL = Bundle.main.url(forResource: "main", withExtension: "jsbundle") {
      return bundledURL
    }

    #if DEBUG
      return RCTBundleURLProvider.sharedSettings().jsBundleURL(forBundleRoot: "index")
    #else
      return NSBundle.main.url(forResource: "main", withExtension: "jsbundle")
    #endif
  }
}
