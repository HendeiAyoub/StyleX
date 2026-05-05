import Foundation

struct AIProductColor: Codable, Hashable {
  let hexCode: String
  let rgbR: Int?
  let rgbG: Int?
  let rgbB: Int?
  let dominancePercentage: Double?
  let colorLabel: String?

  enum CodingKeys: String, CodingKey {
    case hexCode = "hex_code"
    case rgbR = "rgb_r"
    case rgbG = "rgb_g"
    case rgbB = "rgb_b"
    case dominancePercentage = "dominance_percentage"
    case colorLabel = "color_label"
  }
}

struct AIProductRecommendation: Codable, Hashable, Identifiable {
  let productID: String
  let productName: String
  let similarityScore: Double
  let colors: [AIProductColor]
  let category: String?
  let imageURL: String?
  let price: Double?

  var id: String { productID }

  enum CodingKeys: String, CodingKey {
    case productID = "product_id"
    case productName = "product_name"
    case similarityScore = "similarity_score"
    case colors
    case category
    case imageURL = "image_url"
    case price
  }
}

struct AIRecommendationsResponse: Codable {
  let queryProduct: String?
  let recommendations: [AIProductRecommendation]
  let status: String?
  let error: String?

  enum CodingKeys: String, CodingKey {
    case queryProduct = "query_product"
    case recommendations
    case status
    case error
  }
}

struct AIStyleSuggestion: Codable {
  let styleTip: String
  let bestOccasion: String
  let warning: String

  enum CodingKeys: String, CodingKey {
    case styleTip = "style_tip"
    case bestOccasion = "best_occasion"
    case warning
  }
}

struct AIStyleSuggestionResponse: Codable {
  let candidate: String?
  let suggestion: AIStyleSuggestion?
  let status: String?
  let error: String?
}

struct AIChatMessage: Hashable, Identifiable {
  let id: UUID
  let role: String
  let content: String

  init(id: UUID = UUID(), role: String, content: String) {
    self.id = id
    self.role = role
    self.content = content
  }
}

struct AIChatResponse: Codable {
  let responseText: String
  let recommendedProductIDs: [String]
  let status: String?

  enum CodingKeys: String, CodingKey {
    case responseText = "response_text"
    case recommendedProductIDs = "recommended_product_ids"
    case status
  }
}

enum AIClientError: Error {
  case badURL
  case failed(String)
}

struct AIClient {
  static let shared = AIClient()

  private let baseURL = URL(string: Config.LOCAL_AI_BASE_URL)!
  private let decoder = JSONDecoder()
  private let encoder = JSONEncoder()

  func recommendations(for productID: String, limit: Int = 5) async throws -> [AIProductRecommendation] {
    let response: AIRecommendationsResponse = try await post(
      path: "/get-recommendations",
      body: ["product_id": productID, "top_n": limit]
    )

    if let error = response.error {
      throw AIClientError.failed(error)
    }

    return response.recommendations
  }

  func styleSuggestion(for product: Product) async throws -> AIStyleSuggestion {
    let response: AIStyleSuggestionResponse = try await post(
      path: "/get-style-suggestion",
      body: [
        "wardrobe": [
          [
            "name": "White Cotton Shirt",
            "colors": [
              ["hex_code": "#ffffff", "color_label": "white"],
            ],
            "category_name": "tops",
          ],
          [
            "name": "Black Sneakers",
            "colors": [
              ["hex_code": "#111827", "color_label": "black"],
            ],
            "category_name": "shoes",
          ],
        ],
        "candidate_product_id": String(product.id),
      ] as [String: Any]
    )

    if let error = response.error {
      throw AIClientError.failed(error)
    }

    guard let suggestion = response.suggestion else {
      throw AIClientError.failed("No style suggestion returned")
    }

    return suggestion
  }

  func chat(message: String, history: [AIChatMessage]) async throws -> AIChatResponse {
    try await post(
      path: "/ai/chat",
      body: [
        "message": message,
        "image_url": "",
        "chat_history": history.map { ["role": $0.role, "content": $0.content] },
      ] as [String: Any]
    )
  }

  private func post<T: Decodable>(path: String, body: [String: Any]) async throws -> T {
    let url = baseURL.appendingPathComponent(path.trimmingCharacters(in: CharacterSet(charactersIn: "/")))
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.timeoutInterval = 12
    request.httpBody = try JSONSerialization.data(withJSONObject: body)

    let (data, _) = try await URLSession.shared.data(for: request)
    return try decoder.decode(T.self, from: data)
  }
}
