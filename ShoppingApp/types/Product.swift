import Foundation

public class Product: Hashable {
  public static func == (lhs: Product, rhs: Product) -> Bool {
    return lhs.id == rhs.id
      && lhs.title == rhs.title
      && lhs.price == rhs.price
      && lhs.category == rhs.category
      && lhs.imageUrl == rhs.imageUrl
      && lhs.description == rhs.description
      && lhs.isPromotion == rhs.isPromotion
      && lhs.valuePromotion == rhs.valuePromotion
      && lhs.colors == rhs.colors
  }

  var category: String
  var id: Int
  var imageUrl: String
  var price: Double
  var title: String
  var description: String
  var isPromotion: Bool
  var valuePromotion: Int
  var colors: [AIColor]
  var embedding: [Double]

  public init(
    id: Int,
    categoty: String,
    imageUrl: String,
    price: Double,
    title: String,
    description: String,
    isPromotion: Bool,
    valuePromotion: Int,
    colors: [AIColor] = [],
    embedding: [Double] = []
  ) {
    self.id = id
    self.title = title
    self.price = price
    category = categoty
    self.imageUrl = imageUrl
    self.description = description
    self.isPromotion = isPromotion
    self.valuePromotion = valuePromotion
    self.colors = colors
    self.embedding = embedding
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
    hasher.combine(title)
    hasher.combine(price)
    hasher.combine(category)
    hasher.combine(imageUrl)
    hasher.combine(description)
    hasher.combine(isPromotion)
    hasher.combine(valuePromotion)
    hasher.combine(colors)
  }
}

public struct AIColor: Hashable, Codable {
  let hexCode: String
  let label: String
  let dominance: Double

  public init(hexCode: String, label: String, dominance: Double) {
    self.hexCode = hexCode
    self.label = label
    self.dominance = dominance
  }
}

struct StyleSuggestion: Codable {
  let styleTip: String
  let bestOccasion: String
  let warning: String

  enum CodingKeys: String, CodingKey {
    case styleTip = "style_tip"
    case bestOccasion = "best_occasion"
    case warning
  }
}

struct ChatMessage: Identifiable, Codable, Hashable {
  let id: UUID
  let role: String
  let content: String
  let recommendedProductIds: [Int]

  init(id: UUID = UUID(), role: String, content: String, recommendedProductIds: [Int] = []) {
    self.id = id
    self.role = role
    self.content = content
    self.recommendedProductIds = recommendedProductIds
  }
}
