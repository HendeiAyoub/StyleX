import Foundation

class Shoppingservice {
  class func getProducts(completionHandler: (_ products: [NSObject]) -> Void) async {
    completionHandler(DemoStore.productsAsObjects())
  }

  class func getCategories(completionHandler: (_ categories: [String]) -> Void) async {
    completionHandler(DemoStore.categories)
  }
}

enum DemoStore {
  static let categories = ["all", "tops", "bottoms", "shoes", "outerwear"]

  static let products: [Product] = [
    Product(id: 101, categoty: "tops", imageUrl: "https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=500", price: 39.90, title: "Blue Linen Shirt", description: "Light breathable linen shirt for warm casual days.", isPromotion: true, valuePromotion: 10, colors: [AIColor(hexCode: "#3a5a8c", label: "blue", dominance: 54.7), AIColor(hexCode: "#ffffff", label: "white", dominance: 23.4)], embedding: localEmbedding(for: 101)),
    Product(id: 102, categoty: "tops", imageUrl: "https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=500", price: 24.50, title: "White Cotton Tee", description: "Clean white cotton tee that matches almost every outfit.", isPromotion: false, valuePromotion: 0, colors: [AIColor(hexCode: "#ffffff", label: "white", dominance: 78.0)], embedding: localEmbedding(for: 102)),
    Product(id: 103, categoty: "bottoms", imageUrl: "https://images.unsplash.com/photo-1542272604-787c3835535d?w=500", price: 54.00, title: "Blue Denim Jeans", description: "Classic straight-leg denim jeans for daily wear.", isPromotion: true, valuePromotion: 8, colors: [AIColor(hexCode: "#315f9a", label: "blue", dominance: 61.2)], embedding: localEmbedding(for: 103)),
    Product(id: 104, categoty: "bottoms", imageUrl: "https://images.unsplash.com/photo-1473966968600-fa801b869a1a?w=500", price: 46.00, title: "Beige Trousers", description: "Soft beige trousers for smart casual outfits.", isPromotion: false, valuePromotion: 0, colors: [AIColor(hexCode: "#c7ad83", label: "beige", dominance: 69.9)], embedding: localEmbedding(for: 104)),
    Product(id: 105, categoty: "shoes", imageUrl: "https://images.unsplash.com/photo-1549298916-b41d501d3772?w=500", price: 74.90, title: "Black Sneakers", description: "Minimal black sneakers with a clean everyday profile.", isPromotion: true, valuePromotion: 12, colors: [AIColor(hexCode: "#111111", label: "black", dominance: 72.0)], embedding: localEmbedding(for: 105)),
    Product(id: 106, categoty: "outerwear", imageUrl: "https://images.unsplash.com/photo-1543076447-215ad9ba6923?w=500", price: 89.90, title: "Beige Oversized Jacket", description: "Relaxed oversized jacket for layering neutral outfits.", isPromotion: false, valuePromotion: 0, colors: [AIColor(hexCode: "#d8c4a0", label: "beige", dominance: 58.3)], embedding: localEmbedding(for: 106)),
  ]

  static func productsAsObjects() -> [NSObject] {
    return products.map { product in
      [
        "id": product.id,
        "category": product.category,
        "image": product.imageUrl,
        "price": product.price,
        "title": product.title,
        "description": product.description,
      ] as NSDictionary
    }
  }

  static func product(id: Int) -> Product? {
    products.first { $0.id == id }
  }

  static func localColors(for productId: Int) -> [AIColor] {
    products.first { $0.id == productId }?.colors ?? [AIColor(hexCode: "#a85a93", label: "purple", dominance: 45.0)]
  }

  static func localEmbedding(for productId: Int) -> [Double] {
    (0 ..< 16).map { index in
      let raw = ((productId * 31) + (index * 17)) % 100
      return Double(raw) / 100.0
    }
  }
}

@MainActor
final class LocalDemoDatabase: ObservableObject {
  static let shared = LocalDemoDatabase()

  @Published var likedProductIds: Set<Int> = []
  @Published var chatMessages: [ChatMessage] = []

  private let likedKey = "style_dz_demo_liked_products"
  private let chatKey = "style_dz_demo_chat_messages"

  private init() {
    likedProductIds = Set(UserDefaults.standard.array(forKey: likedKey) as? [Int] ?? [101, 103, 105])
    if let data = UserDefaults.standard.data(forKey: chatKey),
       let messages = try? JSONDecoder().decode([ChatMessage].self, from: data) {
      chatMessages = messages
    } else {
      chatMessages = [ChatMessage(role: "assistant", content: "Hi, I can help you search, style, and build outfits from the local demo catalog.")]
    }
  }

  func toggleLike(productId: Int) {
    if likedProductIds.contains(productId) {
      likedProductIds.remove(productId)
    } else {
      likedProductIds.insert(productId)
    }
    UserDefaults.standard.set(Array(likedProductIds), forKey: likedKey)
  }

  func appendMessage(_ message: ChatMessage) {
    chatMessages.append(message)
    if let data = try? JSONEncoder().encode(chatMessages) {
      UserDefaults.standard.set(data, forKey: chatKey)
    }
  }
}

enum StyleDZAIService {
  static func recommendations(for product: Product, topN: Int = 4) async -> [Product] {
    if let ids = await requestProductIds(path: "/get-recommendations", body: ["product_id": String(product.id), "top_n": topN]) {
      let mapped = ids.compactMap { DemoStore.product(id: $0) }.filter { $0.id != product.id }
      if !mapped.isEmpty { return Array(mapped.prefix(topN)) }
    }
    return localRecommendations(for: product, topN: topN)
  }

  static func personalizedFeed(likedIds: Set<Int>, topN: Int = 4) async -> [Product] {
    let liked = DemoStore.products.filter { likedIds.contains($0.id) }
    if liked.isEmpty { return Array(DemoStore.products.prefix(topN)) }
    return Array(DemoStore.products.filter { !likedIds.contains($0.id) }.prefix(topN))
  }

  static func semanticSearch(query: String, category: String?, topN: Int = 20) async -> [Product] {
    let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else { return DemoStore.products }
    if let ids = await requestProductIds(path: "/embed-search-query", body: ["query_text": trimmed, "top_n": topN, "category_name": category ?? ""]) {
      let mapped = ids.compactMap { DemoStore.product(id: $0) }
      if !mapped.isEmpty { return mapped }
    }
    return localSearch(query: trimmed, category: category)
  }

  static func styleSuggestion(for product: Product, likedIds: Set<Int>) async -> StyleSuggestion {
    let likedNames = DemoStore.products.filter { likedIds.contains($0.id) }.map(\.title).joined(separator: ", ")
    let fallback = StyleSuggestion(
      styleTip: "Pair \(product.title) with \(likedNames.isEmpty ? "a clean neutral basic" : likedNames) for a balanced demo outfit.",
      bestOccasion: "Casual school presentation, daily city wear, or a relaxed coffee outing.",
      warning: "Avoid adding too many strong colors at once; keep one item as the visual focus."
    )
    return fallback
  }

  static func chatReply(message: String, history: [ChatMessage]) async -> ChatMessage {
    let results = await semanticSearch(query: message, category: nil, topN: 2)
    let ids = results.prefix(2).map(\.id)
    let names = results.prefix(2).map(\.title).joined(separator: " and ")
    let response = names.isEmpty
      ? "I would keep the outfit simple and build around neutral basics from the local demo catalog."
      : "For that request, I would start with \(names). The combination keeps the outfit easy to explain and visually clear for the demo."
    return ChatMessage(role: "assistant", content: response, recommendedProductIds: ids)
  }

  private static func localRecommendations(for product: Product, topN: Int) -> [Product] {
    let productLabels = Set(product.colors.map(\.label))
    let scored = DemoStore.products.filter { $0.id != product.id }.map { candidate in
      var score = 0
      if candidate.category == product.category { score += 3 }
      if !productLabels.isDisjoint(with: Set(candidate.colors.map(\.label))) { score += 2 }
      if candidate.isPromotion { score += 1 }
      return (candidate, score)
    }
    return Array(scored.sorted { $0.1 > $1.1 }.map(\.0).prefix(topN))
  }

  private static func localSearch(query: String, category: String?) -> [Product] {
    let tokens = query.lowercased().split(separator: " ").map(String.init)
    return DemoStore.products.filter { product in
      let matchesCategory = category?.isEmpty != false || product.category == category
      let haystack = "\(product.title) \(product.category) \(product.description) \(product.colors.map(\.label).joined(separator: " "))".lowercased()
      return matchesCategory && tokens.contains { haystack.contains($0) }
    }
  }

  private static func requestProductIds(path: String, body: [String: Any]) async -> [Int]? {
    guard let url = URL(string: Config.STYLE_DZ_AI_BASE_URL + path),
          let data = try? JSONSerialization.data(withJSONObject: body) else {
      return nil
    }
    var request = URLRequest(url: url, timeoutInterval: Config.AI_TIMEOUT_SECONDS)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = data
    guard let (responseData, response) = try? await URLSession.shared.data(for: request),
          let http = response as? HTTPURLResponse,
          (200 ..< 300).contains(http.statusCode),
          let json = try? JSONSerialization.jsonObject(with: responseData) as? [String: Any],
          json["status"] as? String != "failed" else {
      return nil
    }
    let recommendationRows = (json["recommendations"] as? [[String: Any]]) ?? (json["results"] as? [[String: Any]]) ?? []
    return recommendationRows.compactMap { row in
      if let intId = row["product_id"] as? Int { return intId }
      if let stringId = row["product_id"] as? String { return Int(stringId) }
      return nil
    }
  }
}
