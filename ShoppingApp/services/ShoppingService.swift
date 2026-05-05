import Foundation

private enum StoreCategoryFilter {
  static let excludedCategories: Set<String> = ["electronics"]

  static func allows(_ category: String) -> Bool {
    let normalizedCategory = category.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    return !excludedCategories.contains(normalizedCategory)
  }

  static func allows(product: NSObject) -> Bool {
    guard let category = product.value(forKey: "category") as? String else {
      return true
    }

    return allows(category)
  }
}

class Shoppingservice {
  class func getProducts(completionHandler: (_ products: [NSObject]) -> Void) async {
    guard let url = URL(string: Config.PRODUCTS_STORE_URL) else {
      return
    }
    _ = URLRequest(url: url)
    do {
      let (data, _) = try await URLSession.shared.data(from: url)
      do {
        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [NSObject] {
          completionHandler(json.filter(StoreCategoryFilter.allows(product:)))
        }
      } catch {
        print(error)
      }
    } catch {
      print(error)
    }
  }

  class func getCategories(completionHandler: (_ categories: [String]) -> Void) async {
    guard let url = URL(string: Config.PRODUCTS_STORE_URL + "/categories") else {
      return
    }
    _ = URLRequest(url: url)
    do {
      let (data, _) = try await URLSession.shared.data(from: url)
      do {
        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String] {
          completionHandler(json.filter(StoreCategoryFilter.allows))
        }
      } catch {
        print(error)
      }
    } catch {
      print(error)
    }
  }
}
