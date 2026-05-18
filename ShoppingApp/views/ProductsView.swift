import CoreData
import SwiftUI

struct ProductsView: View {
  @StateObject private var demoDatabase = LocalDemoDatabase.shared
  @State var productsArray: [Product] = .init()
  @State var filterdProductsArray: [Product] = .init()
  @State var categoriesArray: [String] = .init()
  @State var productSelected: Product? = nil
  @State private var forYouProducts: [Product] = []
  @State private var searchText = ""
  @State private var searchTask: Task<Void, Never>?

  var cardWidth = UIScreen.main.bounds.width / 2.2
  var columns: [GridItem] = [
    GridItem(.adaptive(minimum: 100, maximum: UIScreen.main.bounds.width / 2)),
    GridItem(.flexible(minimum: 100, maximum: UIScreen.main.bounds.width / 2), spacing: 0),
  ]

  func filterProducts(category: String) {
    filterdProductsArray = []
    if category == "all" {
      filterdProductsArray = productsArray
    } else {
      let filteredProducts = productsArray.filter { product in
        if product.category == category {
          return true
        } else {
          return false
        }
      }
      filterdProductsArray = filteredProducts
    }
  }

  func runSearch() {
    searchTask?.cancel()
    searchTask = Task {
      try? await Task.sleep(nanoseconds: 500_000_000)
      let results = await StyleDZAIService.semanticSearch(query: searchText, category: nil)
      if !Task.isCancelled {
        filterdProductsArray = searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? productsArray : results
      }
    }
  }

  var body: some View {
    VStack(alignment: .leading) {
      ShoppingHeader()
      ScrollView {
        VStack(alignment: .leading, spacing: 8) {
          TextField("Search outfits, colors, or categories", text: $searchText)
            .textInputAutocapitalization(.never)
            .disableAutocorrection(true)
            .padding(12)
            .background(RoundedRectangle(cornerRadius: 8).fill(Color("gray_100")))
            .onChange(of: searchText) { _ in
              runSearch()
            }

          if !forYouProducts.isEmpty {
            Text("For You")
              .font(.headline)
              .foregroundStyle(Color("primary"))
            ScrollView(.horizontal) {
              HStack(spacing: 12) {
                ForEach(forYouProducts, id: \.self) { product in
                  NavigationLink(destination: ProductDetailView(product: product)) {
                    ProductItemContent(product: product)
                      .frame(width: 140, height: 190)
                      .background(RoundedRectangle(cornerRadius: 8).fill(Color.white).border(Color("gray_300"), width: 1))
                  }
                  .buttonStyle(.plain)
                }
              }
            }
            .scrollIndicators(.hidden)
          }
        }
        .padding(.horizontal, 12)

        CategoriesList(filterProducts: filterProducts, categoriesArray: categoriesArray)
        BannerPromotion()
        LazyVGrid(columns: self.columns) {
          ForEach(self.filterdProductsArray, id: \.self) { product in
            ProductItem(product: product,
                        productSelected: $productSelected,
                        cardWidth: cardWidth)
          }
        }
        .task {
          productsArray = []
          filterdProductsArray = []
          await Shoppingservice.getProducts {
            products in
            for product in products {
              let newProduct = Utils.buildNewProductFromObject(product: product)
              productsArray.append(newProduct)
              filterdProductsArray.append(newProduct)
            }
          }
          forYouProducts = await StyleDZAIService.personalizedFeed(likedIds: demoDatabase.likedProductIds)
        }
        .padding([.all, .trailing], 8)
      }
      .background(Color.white)
      .frame(width: .infinity)
    }
  }
}
