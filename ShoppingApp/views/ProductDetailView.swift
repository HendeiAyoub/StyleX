import Foundation
import SwiftUI

struct ProductDetailView: View {
  @Environment(\.managedObjectContext) private var viewContext
  var product: Product
  var bgColor: Color = Utils.colorRGB(r: 168, g: 43, b: 129, opacity: 0.1)
  @State private var recommendations: [AIProductRecommendation] = []
  @State private var styleSuggestion: AIStyleSuggestion?
  @State private var isLoadingRecommendations = false
  @State private var isLoadingStyle = false
  @State private var aiErrorMessage: String?

  func addProductToCart(product: Product) {
    let newProduct = CartItem(context: viewContext)
    newProduct.id = Int64(product.id)
    newProduct.text = product.description
    newProduct.title = product.title
    newProduct.category = product.category
    newProduct.price = product.price
    newProduct.imageUrl = product.imageUrl
    newProduct.isPromotion = product.isPromotion
    newProduct.valuePromotion = Int64(product.valuePromotion)
    newProduct.timestamp = Date()

    do {
      try viewContext.save()
    } catch {
      let nsError = error as NSError
      fatalError("Unresolved error when try save product on cart:: \(nsError)")
    }
  }

  var body: some View {
    ScrollView {
      VStack {
        VStack(alignment: .center) {
          AsyncImage(url: URL(string: product.imageUrl)) { image in
            image.resizable().aspectRatio(contentMode: .fit)
          } placeholder: {
            ProgressView()
          }
          .frame(width: .infinity, height: 180)
          .background(Rectangle().fill(Color.white))
          .padding(.horizontal, 24)
          .padding(.vertical, 48)
        }
        VStack(alignment: .leading) {
          Text("$ " + String(format: "%.2f", product.price)).font(.title)
          Text(product.title).foregroundStyle(Color("primary"))
            .font(.headline)
          if product.isPromotion {
            Text("-" + String(product.valuePromotion) + "%").foregroundStyle(Color.white).font(Font.caption2.weight(.bold))
              .frame(width: 40, height: 18)
              .background(Rectangle().fill(Color("secondary")))
          }
          Divider().background(Color.black).padding(.trailing, 128)
          Text(product.category).font(.caption).foregroundStyle(Color("secondary"))
          Text(product.description).font(.caption)
          styleSection
          recommendationsSection
          if let aiErrorMessage {
            Text(aiErrorMessage)
              .font(.caption)
              .foregroundStyle(Color.red)
              .padding(.top, 8)
          }
          Button {
            addProductToCart(product: product)
          } label: {
            Text("Add to cart").font(Font.body.weight(.bold)).foregroundStyle(Color.white)
              .frame(maxWidth: .infinity)
          }
          .frame(width: .infinity, height: 32)
          .background(RoundedRectangle(cornerRadius: 8).fill(Color("primary")))
        }
        .padding(.all, 24)
        .frame(width: .infinity)
        .background(
          LinearGradient(gradient: Gradient(colors: [bgColor, Color.white]), startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.03), radius: 5, x: 0, y: -10)
      }
    }
    .navigationBarBackButtonHidden(true)
    .navigationBarItems(leading: CustomBackButton())
    .task {
      await loadRecommendations()
    }
  }

  private var styleSection: some View {
    VStack(alignment: .leading, spacing: 8) {
      Button {
        Task {
          await loadStyleSuggestion()
        }
      } label: {
        HStack {
          Image(systemName: "sparkles")
          Text(isLoadingStyle ? "Styling..." : "Style This Item")
          Spacer()
          if isLoadingStyle {
            ProgressView()
          }
        }
        .font(.callout.bold())
        .foregroundStyle(Color.white)
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 8).fill(Color("secondary")))
      }
      .disabled(isLoadingStyle)

      if let styleSuggestion {
        VStack(alignment: .leading, spacing: 6) {
          Text("Style Tip").font(.caption.bold()).foregroundStyle(Color("primary"))
          Text(styleSuggestion.styleTip).font(.caption)
          Text("Best Occasion").font(.caption.bold()).foregroundStyle(Color("primary"))
          Text(styleSuggestion.bestOccasion).font(.caption)
          Text("Warning").font(.caption.bold()).foregroundStyle(Color("primary"))
          Text(styleSuggestion.warning).font(.caption)
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 8).fill(Color.white))
      }
    }
    .padding(.top, 12)
  }

  private var recommendationsSection: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack {
        Text("You Might Also Like")
          .font(.headline)
        if isLoadingRecommendations {
          ProgressView()
        }
      }

      if !recommendations.isEmpty {
        ScrollView(.horizontal) {
          HStack(spacing: 10) {
            ForEach(recommendations) { item in
              VStack(alignment: .leading, spacing: 6) {
                AsyncImage(url: URL(string: item.imageURL ?? "")) { image in
                  image.resizable().aspectRatio(contentMode: .fit)
                } placeholder: {
                  ProgressView()
                }
                .frame(width: 96, height: 90)
                .background(Color.white)

                Text(item.productName)
                  .font(.caption.bold())
                  .lineLimit(2)
                  .frame(width: 110, alignment: .leading)

                Text("Match " + String(format: "%.0f", item.similarityScore * 100) + "%")
                  .font(.caption2)
                  .foregroundStyle(Color("secondary"))
              }
              .padding(8)
              .frame(width: 126, height: 170)
              .background(RoundedRectangle(cornerRadius: 8).fill(Color("gray_100")))
            }
          }
        }
        .scrollIndicators(.hidden)
      }
    }
    .padding(.top, 16)
  }

  private func loadRecommendations() async {
    guard recommendations.isEmpty else {
      return
    }

    isLoadingRecommendations = true
    do {
      recommendations = try await AIClient.shared.recommendations(for: String(product.id))
    } catch {
      aiErrorMessage = "Local AI is offline. Start scripts/start-local-ai.sh for recommendations."
    }
    isLoadingRecommendations = false
  }

  private func loadStyleSuggestion() async {
    isLoadingStyle = true
    aiErrorMessage = nil
    do {
      styleSuggestion = try await AIClient.shared.styleSuggestion(for: product)
    } catch {
      aiErrorMessage = "Local AI is offline. Start scripts/start-local-ai.sh for style advice."
    }
    isLoadingStyle = false
  }
}
