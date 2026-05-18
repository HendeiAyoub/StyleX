import Foundation
import SwiftUI

struct ProductDetailView: View {
  @Environment(\.managedObjectContext) private var viewContext
  @StateObject private var demoDatabase = LocalDemoDatabase.shared
  var product: Product
  var bgColor: Color = Utils.colorRGB(r: 168, g: 43, b: 129, opacity: 0.1)
  @State private var recommendations: [Product] = []
  @State private var styleSuggestion: StyleSuggestion?
  @State private var isLoadingStyle = false

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
        VStack(alignment: .leading, spacing: 12) {
          HStack {
            Text("$ " + String(format: "%.2f", product.price)).font(.title)
            Spacer()
            Button {
              demoDatabase.toggleLike(productId: product.id)
            } label: {
              Image(systemName: demoDatabase.likedProductIds.contains(product.id) ? "heart.fill" : "heart")
                .foregroundStyle(Color("secondary"))
                .font(.title3)
            }
          }
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

          HStack {
            ForEach(product.colors, id: \.self) { color in
              Text(color.label)
                .font(.caption2.bold())
                .foregroundStyle(Color.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(RoundedRectangle(cornerRadius: 8).fill(Color("primary")))
            }
          }

          Button {
            Task {
              isLoadingStyle = true
              styleSuggestion = await StyleDZAIService.styleSuggestion(for: product, likedIds: demoDatabase.likedProductIds)
              isLoadingStyle = false
            }
          } label: {
            HStack {
              Image(systemName: "sparkles")
              Text(isLoadingStyle ? "Styling..." : "Style This Item")
            }
            .font(Font.body.weight(.bold))
            .foregroundStyle(Color.white)
            .frame(maxWidth: .infinity)
          }
          .frame(height: 36)
          .background(RoundedRectangle(cornerRadius: 8).fill(Color("secondary")))

          if let suggestion = styleSuggestion {
            VStack(alignment: .leading, spacing: 8) {
              Text("Style Tip").font(.headline)
              Text(suggestion.styleTip).font(.caption)
              Text("Best Occasion").font(.headline)
              Text(suggestion.bestOccasion).font(.caption)
              Text("Warning").font(.headline)
              Text(suggestion.warning).font(.caption)
            }
            .padding(12)
            .background(RoundedRectangle(cornerRadius: 8).fill(Color("gray_100")))
          }

          if !recommendations.isEmpty {
            Text("You Might Also Like")
              .font(.headline)
              .foregroundStyle(Color("primary"))
            ScrollView(.horizontal) {
              HStack(spacing: 12) {
                ForEach(recommendations, id: \.self) { recommendation in
                  NavigationLink(destination: ProductDetailView(product: recommendation)) {
                    ProductItemContent(product: recommendation)
                      .frame(width: 140, height: 190)
                      .background(RoundedRectangle(cornerRadius: 8).fill(Color.white).border(Color("gray_300"), width: 1))
                  }
                  .buttonStyle(.plain)
                }
              }
            }
            .scrollIndicators(.hidden)
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
      .task {
        recommendations = await StyleDZAIService.recommendations(for: product)
      }
    }
    .navigationBarBackButtonHidden(true)
    .navigationBarItems(leading: CustomBackButton())
  }
}
