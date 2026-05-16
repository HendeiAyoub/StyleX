

import AppIntents

struct ShoppingWatch: AppIntent {
  static var title: LocalizedStringResource = "ShoppingWatch"

  func perform() async throws -> some IntentResult {
    return .result()
  }
}
