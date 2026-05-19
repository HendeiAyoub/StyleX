import Foundation

class Shoppingservice {
  class func getProducts(completionHandler: @escaping (_ products: [NSObject]) -> Void) async {
    guard let url = URL(string: Config.PRODUCTS_STORE_URL) else { return }
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.setValue(Config.SUPABASE_ANON_KEY, forHTTPHeaderField: "apikey")
    request.setValue("Bearer \(Config.SUPABASE_ANON_KEY)", forHTTPHeaderField: "Authorization")

    do {
      let (data, response) = try await URLSession.shared.data(for: request)
      if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [NSObject] {
          print("📡 STYLE-X DATABASE INFO: Successfully fetched \(json.count) products live from your Supabase database!")
          completionHandler(json)
          return
        }
      } else {
        print("Supabase fetch failed: \(String(data: data, encoding: .utf8) ?? "Unknown")")
      }
    } catch {
      print("Network error fetching products from Supabase: \(error)")
    }
    // Fallback to local mock data if Supabase request fails or is not configured
    completionHandler(DemoStore.productsAsObjects())
  }

  class func getCategories(completionHandler: @escaping (_ categories: [String]) -> Void) async {
    completionHandler(DemoStore.categories)
  }

  class func saveUserProfile(name: String, email: String, phone: String, address: String) async -> Bool {
    // Save locally to UserDefaults first (bulletproof offline fallback)
    UserDefaults.standard.set(name, forKey: "stylex_user_name")
    UserDefaults.standard.set(email, forKey: "stylex_user_email")
    UserDefaults.standard.set(phone, forKey: "stylex_user_phone")
    UserDefaults.standard.set(address, forKey: "stylex_user_address")
    UserDefaults.standard.set(true, forKey: "stylex_user_is_logged_in")

    // Sync to Supabase profiles table
    guard let url = URL(string: "https://kirepwxjgaikqarymwij.supabase.co/rest/v1/profiles") else { return true }
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue(Config.SUPABASE_ANON_KEY, forHTTPHeaderField: "apikey")
    request.setValue("Bearer \(Config.SUPABASE_ANON_KEY)", forHTTPHeaderField: "Authorization")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("resolution=merge-duplicates", forHTTPHeaderField: "Prefer") // Upsert if supported

    let body: [String: Any] = [
      "email": email,
      "name": name,
      "phone": phone,
      "address": address
    ]

    do {
      let data = try JSONSerialization.data(withJSONObject: body)
      request.httpBody = data
      let (_, response) = try await URLSession.shared.data(for: request)
      if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {
        print("📡 STYLE-X DATABASE INFO: Successfully synced profile for \(name) to Supabase profiles table!")
        return true
      }
    } catch {
      print("Supabase profile sync error: \(error)")
    }
    return true
  }

  class func sellProduct(id: Int, title: String, category: String, price: Double, description: String, imageUrl: String) async -> Bool {
    // Sync to Supabase products table
    guard let url = URL(string: Config.PRODUCTS_STORE_URL) else { return false }
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue(Config.SUPABASE_ANON_KEY, forHTTPHeaderField: "apikey")
    request.setValue("Bearer \(Config.SUPABASE_ANON_KEY)", forHTTPHeaderField: "Authorization")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    let body: [String: Any] = [
      "id": id,
      "category": category,
      "image": imageUrl,
      "price": price,
      "title": title,
      "description": description
    ]

    do {
      let data = try JSONSerialization.data(withJSONObject: body)
      request.httpBody = data
      let (_, response) = try await URLSession.shared.data(for: request)
      if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {
        print("📡 STYLE-X DATABASE INFO: Successfully listed new product \(title) to Supabase!")
        return true
      }
    } catch {
      print("Supabase product listing error: \(error)")
    }
    return false
  }
}

enum DemoStore {
  static let categories = ["all", "tops", "bottoms", "shoes", "outerwear"]

  static var products: [Product] = [
    Product(id: 101, categoty: "tops", imageUrl: "https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=500", price: 39.90, title: "Blue Linen Shirt", description: "Light breathable linen shirt for warm casual days.", isPromotion: true, valuePromotion: 10, colors: [AIColor(hexCode: "#3a5a8c", label: "blue", dominance: 54.7), AIColor(hexCode: "#ffffff", label: "white", dominance: 23.4)], embedding: localEmbedding(for: 101)),
    Product(id: 102, categoty: "tops", imageUrl: "https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=500", price: 24.50, title: "White Cotton Tee", description: "Clean white cotton tee that matches almost every outfit.", isPromotion: false, valuePromotion: 0, colors: [AIColor(hexCode: "#ffffff", label: "white", dominance: 78.0)], embedding: localEmbedding(for: 102)),
    Product(id: 103, categoty: "bottoms", imageUrl: "https://images.unsplash.com/photo-1542272604-787c3835535d?w=500", price: 54.00, title: "Blue Denim Jeans", description: "Classic straight-leg denim jeans for daily wear.", isPromotion: true, valuePromotion: 8, colors: [AIColor(hexCode: "#315f9a", label: "blue", dominance: 61.2)], embedding: localEmbedding(for: 103)),
    Product(id: 104, categoty: "bottoms", imageUrl: "https://images.unsplash.com/photo-1473966968600-fa801b869a1a?w=500", price: 46.00, title: "Beige Trousers", description: "Soft beige trousers for smart casual outfits.", isPromotion: false, valuePromotion: 0, colors: [AIColor(hexCode: "#c7ad83", label: "beige", dominance: 69.9)], embedding: localEmbedding(for: 104)),
    Product(id: 105, categoty: "shoes", imageUrl: "https://images.unsplash.com/photo-1549298916-b41d501d3772?w=500", price: 74.90, title: "Black Sneakers", description: "Minimal black sneakers with a clean everyday profile.", isPromotion: true, valuePromotion: 12, colors: [AIColor(hexCode: "#111111", label: "black", dominance: 72.0)], embedding: localEmbedding(for: 105)),
    Product(id: 106, categoty: "outerwear", imageUrl: "https://images.unsplash.com/photo-1543076447-215ad9ba6923?w=500", price: 89.90, title: "Beige Oversized Jacket", description: "Relaxed oversized jacket for layering neutral outfits.", isPromotion: false, valuePromotion: 0, colors: [AIColor(hexCode: "#d8c4a0", label: "beige", dominance: 58.3)], embedding: localEmbedding(for: 106)),
    Product(id: 107, categoty: "outerwear", imageUrl: "https://images.unsplash.com/photo-1551028719-00167b16eac5?w=500", price: 129.90, title: "Black Leather Jacket", description: "Classic moto-style black leather jacket for a bold look.", isPromotion: false, valuePromotion: 0, colors: [AIColor(hexCode: "#000000", label: "black", dominance: 85.0)], embedding: localEmbedding(for: 107)),
    Product(id: 108, categoty: "shoes", imageUrl: "https://images.unsplash.com/photo-1600185365483-26d7a4cc7519?w=500", price: 89.00, title: "White Canvas Sneakers", description: "Everyday comfortable white canvas sneakers.", isPromotion: true, valuePromotion: 15, colors: [AIColor(hexCode: "#ffffff", label: "white", dominance: 90.0)], embedding: localEmbedding(for: 108)),
    Product(id: 109, categoty: "tops", imageUrl: "https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?w=500", price: 42.50, title: "Patterned Summer Shirt", description: "Lightweight short-sleeve shirt with a vibrant summer pattern.", isPromotion: false, valuePromotion: 0, colors: [AIColor(hexCode: "#d45d5d", label: "red", dominance: 45.0), AIColor(hexCode: "#f2e4c9", label: "cream", dominance: 30.0)], embedding: localEmbedding(for: 109)),
    Product(id: 110, categoty: "tops", imageUrl: "https://images.unsplash.com/photo-1556821840-3a63f95609a7?w=500", price: 55.00, title: "Grey Minimalist Hoodie", description: "Soft, comfortable grey hoodie for a relaxed urban look.", isPromotion: false, valuePromotion: 0, colors: [AIColor(hexCode: "#808080", label: "grey", dominance: 80.0)], embedding: localEmbedding(for: 110)),
    Product(id: 111, categoty: "bottoms", imageUrl: "https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=500", price: 49.50, title: "Black Slim Jeans", description: "Sleek black slim-fit jeans, an essential wardrobe staple.", isPromotion: true, valuePromotion: 10, colors: [AIColor(hexCode: "#1a1a1a", label: "black", dominance: 85.0)], embedding: localEmbedding(for: 111)),
    Product(id: 112, categoty: "outerwear", imageUrl: "https://images.unsplash.com/photo-1576871337632-b9aef4c17ab9?w=500", price: 79.90, title: "Vintage Denim Jacket", description: "Timeless vintage wash denim jacket.", isPromotion: false, valuePromotion: 0, colors: [AIColor(hexCode: "#4b6c8f", label: "blue", dominance: 75.0)], embedding: localEmbedding(for: 112)),
    Product(id: 113, categoty: "tops", imageUrl: "https://images.unsplash.com/photo-1576566588028-4147f3842f27?w=500", price: 29.90, title: "Graphic Vintage T-Shirt", description: "Heavyweight cotton graphic tee with a retro print.", isPromotion: true, valuePromotion: 5, colors: [AIColor(hexCode: "#d9d9d9", label: "light grey", dominance: 70.0)], embedding: localEmbedding(for: 113)),
    Product(id: 114, categoty: "bottoms", imageUrl: "https://images.unsplash.com/photo-1624378439575-d8705ad7ae80?w=500", price: 59.00, title: "Classic Beige Chinos", description: "Versatile straight-leg chinos perfect for smart-casual wear.", isPromotion: false, valuePromotion: 0, colors: [AIColor(hexCode: "#d2b48c", label: "tan", dominance: 85.0)], embedding: localEmbedding(for: 114)),
    Product(id: 115, categoty: "shoes", imageUrl: "https://images.unsplash.com/photo-1608256246200-53e635b5b65f?w=500", price: 145.00, title: "Black Leather Boots", description: "Premium black leather lace-up boots for all seasons.", isPromotion: false, valuePromotion: 0, colors: [AIColor(hexCode: "#222222", label: "black", dominance: 95.0)], embedding: localEmbedding(for: 115)),
    Product(id: 116, categoty: "tops", imageUrl: "https://images.unsplash.com/photo-1434389677669-e08b4cac3105?w=500", price: 65.00, title: "Silk Button-Up Blouse", description: "Elegant off-white mulberry silk blouse with pearl buttons.", isPromotion: false, valuePromotion: 0, colors: [AIColor(hexCode: "#f5f2eb", label: "cream", dominance: 85.0)], embedding: localEmbedding(for: 116)),
    Product(id: 117, categoty: "bottoms", imageUrl: "https://images.unsplash.com/photo-1594633312681-425c7b97ccd1?w=500", price: 58.00, title: "Brown Pleated Trousers", description: "Sophisticated pleated wide-leg trousers in a rich chocolate brown.", isPromotion: true, valuePromotion: 10, colors: [AIColor(hexCode: "#4a3525", label: "brown", dominance: 75.0)], embedding: localEmbedding(for: 117)),
    Product(id: 118, categoty: "outerwear", imageUrl: "https://images.unsplash.com/photo-1611312449412-6cefac5dc3e4?w=500", price: 72.50, title: "Emerald Corduroy Shacket", description: "Emerald green corduroy shirt-jacket perfect for crisp autumn layering.", isPromotion: false, valuePromotion: 0, colors: [AIColor(hexCode: "#0f5235", label: "emerald", dominance: 68.0)], embedding: localEmbedding(for: 118)),
    Product(id: 119, categoty: "shoes", imageUrl: "https://images.unsplash.com/photo-1533867617858-e7b97e060509?w=500", price: 110.00, title: "Minimalist Leather Loafers", description: "Ultra-comfortable black leather loafers with a clean silhouette.", isPromotion: true, valuePromotion: 15, colors: [AIColor(hexCode: "#111111", label: "black", dominance: 90.0)], embedding: localEmbedding(for: 119)),
    Product(id: 120, categoty: "tops", imageUrl: "https://images.unsplash.com/photo-1583743814966-8936f5b7be1a?w=500", price: 79.90, title: "Cable Knit Sweater", description: "Chunky cream cable-knit sweater to keep you warm and cozy.", isPromotion: false, valuePromotion: 0, colors: [AIColor(hexCode: "#f8f4ec", label: "cream", dominance: 95.0)], embedding: localEmbedding(for: 120)),
    Product(id: 121, categoty: "bottoms", imageUrl: "https://images.unsplash.com/photo-1517462964-21fdcec3f25b?w=500", price: 62.00, title: "Cargo Utility Pants", description: "Rugged grey cargo pants with multi-pocket detailing.", isPromotion: false, valuePromotion: 0, colors: [AIColor(hexCode: "#5a5c64", label: "grey", dominance: 70.0)], embedding: localEmbedding(for: 121)),
    Product(id: 122, categoty: "outerwear", imageUrl: "https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=500", price: 189.00, title: "Camel Double-Breasted Coat", description: "Tailored double-breasted camel wool coat for formal winter wear.", isPromotion: true, valuePromotion: 5, colors: [AIColor(hexCode: "#c69b6d", label: "camel", dominance: 80.0)], embedding: localEmbedding(for: 122)),
    Product(id: 123, categoty: "shoes", imageUrl: "https://images.unsplash.com/photo-1603191659812-ee978eeeef76?w=500", price: 135.00, title: "Suede Chelsea Boots", description: "Classic tan suede Chelsea boots with elasticated side panels.", isPromotion: false, valuePromotion: 0, colors: [AIColor(hexCode: "#cca57d", label: "tan", dominance: 78.0)], embedding: localEmbedding(for: 123)),
    Product(id: 124, categoty: "tops", imageUrl: "https://images.unsplash.com/photo-1503342217505-b0a15ec3261c?w=500", price: 28.00, title: "Striped Breton Tee", description: "Timeless navy and white striped long-sleeve cotton Breton tee.", isPromotion: false, valuePromotion: 0, colors: [AIColor(hexCode: "#1d2e4f", label: "navy", dominance: 60.0), AIColor(hexCode: "#ffffff", label: "white", dominance: 40.0)], embedding: localEmbedding(for: 124)),
    Product(id: 125, categoty: "bottoms", imageUrl: "https://images.unsplash.com/photo-1591195853828-11db59a44f6b?w=500", price: 34.90, title: "Linen Summer Shorts", description: "Lightweight olive green linen-cotton blend summer shorts.", isPromotion: true, valuePromotion: 8, colors: [AIColor(hexCode: "#556b2f", label: "olive", dominance: 72.0)], embedding: localEmbedding(for: 125)),
    Product(id: 126, categoty: "outerwear", imageUrl: "https://images.unsplash.com/photo-1591047139829-d91aecb6caea?w=500", price: 145.00, title: "Waterproof Trench Coat", description: "Double-breasted beige trench coat with adjustable waist belt.", isPromotion: false, valuePromotion: 0, colors: [AIColor(hexCode: "#e5d3b3", label: "beige", dominance: 85.0)], embedding: localEmbedding(for: 126)),
    Product(id: 127, categoty: "shoes", imageUrl: "https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=500", price: 85.00, title: "Retro Running Sneakers", description: "Vibrant pastel retro running sneakers with gum rubber soles.", isPromotion: true, valuePromotion: 12, colors: [AIColor(hexCode: "#ffc0cb", label: "pink", dominance: 50.0), AIColor(hexCode: "#ffeb3b", label: "yellow", dominance: 30.0)], embedding: localEmbedding(for: 127)),
    Product(id: 128, categoty: "tops", imageUrl: "https://images.unsplash.com/photo-1581655353564-df123a1eb820?w=500", price: 45.00, title: "Polo Knit Shirt", description: "Slim-fit sage green short-sleeve polo knit shirt.", isPromotion: false, valuePromotion: 0, colors: [AIColor(hexCode: "#9ca995", label: "sage", dominance: 82.0)], embedding: localEmbedding(for: 128)),
    Product(id: 129, categoty: "bottoms", imageUrl: "https://images.unsplash.com/photo-1578587018452-892bacefd3f2?w=500", price: 49.00, title: "Raw Edge Denim Skirt", description: "Mid-rise washed blue denim skirt with a raw edge finish.", isPromotion: false, valuePromotion: 0, colors: [AIColor(hexCode: "#4a74a5", label: "blue", dominance: 88.0)], embedding: localEmbedding(for: 129)),
    Product(id: 130, categoty: "outerwear", imageUrl: "https://images.unsplash.com/photo-1551488831-00ddcb6c6bd3?w=500", price: 95.00, title: "Quilted Bomber Jacket", description: "Sleek olive green quilted bomber jacket with ribbed collar and cuffs.", isPromotion: true, valuePromotion: 10, colors: [AIColor(hexCode: "#4b5320", label: "olive", dominance: 75.0)], embedding: localEmbedding(for: 130)),
    Product(id: 131, categoty: "tops", imageUrl: "https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=500", price: 48.00, title: "Velvet High-Neck Top", description: "Luxurious black velvet high-neck top with a slight stretch.", isPromotion: false, valuePromotion: 0, colors: [AIColor(hexCode: "#151517", label: "black", dominance: 92.0)], embedding: localEmbedding(for: 131)),
    Product(id: 132, categoty: "bottoms", imageUrl: "https://images.unsplash.com/photo-1509551388413-e18d0ac5d495?w=500", price: 55.00, title: "Wide-Leg Linen Pants", description: "Breezy off-white wide-leg linen pants with an elastic waist.", isPromotion: true, valuePromotion: 10, colors: [AIColor(hexCode: "#faf7f2", label: "cream", dominance: 88.0)], embedding: localEmbedding(for: 132)),
    Product(id: 133, categoty: "outerwear", imageUrl: "https://images.unsplash.com/photo-1516257984-b1b4d707412e?w=500", price: 69.00, title: "Classic Denim Jacket", description: "Everyday vintage washed blue denim jacket with metal button closures.", isPromotion: false, valuePromotion: 0, colors: [AIColor(hexCode: "#53729e", label: "blue", dominance: 75.0)], embedding: localEmbedding(for: 133)),
    Product(id: 134, categoty: "shoes", imageUrl: "https://images.unsplash.com/photo-1520639888713-7851133b1ed0?w=500", price: 149.00, title: "Leather Combat Boots", description: "Rugged black leather combat boots with heavy-duty lugged soles.", isPromotion: true, valuePromotion: 15, colors: [AIColor(hexCode: "#111111", label: "black", dominance: 95.0)], embedding: localEmbedding(for: 134)),
    Product(id: 135, categoty: "tops", imageUrl: "https://images.unsplash.com/photo-1618354691373-d851c5c3a990?w=500", price: 32.00, title: "Pima Cotton Long Sleeve", description: "Ultra-soft long sleeve tee made from premium Peruvian Pima cotton.", isPromotion: false, valuePromotion: 0, colors: [AIColor(hexCode: "#7e8085", label: "grey", dominance: 85.0)], embedding: localEmbedding(for: 135)),
    Product(id: 136, categoty: "bottoms", imageUrl: "https://images.unsplash.com/photo-1583496661160-fb5886a0aaaa?w=500", price: 45.00, title: "Split-Hem Knit Skirt", description: "Slim-fit ribbed knit midi skirt in charcoal grey with a chic side split.", isPromotion: false, valuePromotion: 0, colors: [AIColor(hexCode: "#44464a", label: "grey", dominance: 80.0)], embedding: localEmbedding(for: 136)),
    Product(id: 137, categoty: "outerwear", imageUrl: "https://images.unsplash.com/photo-1544022613-e87ca75a784a?w=500", price: 125.00, title: "Faux-Fur Aviator Jacket", description: "Statement aviator jacket in black faux leather with matching plush lining.", isPromotion: true, valuePromotion: 20, colors: [AIColor(hexCode: "#18181c", label: "black", dominance: 90.0)], embedding: localEmbedding(for: 137)),
    Product(id: 138, categoty: "shoes", imageUrl: "https://images.unsplash.com/photo-1543163521-1bf539c55dd2?w=500", price: 95.00, title: "Slingback Kitten Heels", description: "Sleek burgundy patent leather slingback heels with a comfortable kitten heel.", isPromotion: false, valuePromotion: 0, colors: [AIColor(hexCode: "#6b1d2f", label: "burgundy", dominance: 88.0)], embedding: localEmbedding(for: 138)),
    Product(id: 139, categoty: "tops", imageUrl: "https://images.unsplash.com/photo-1509319117193-57bab727e09d?w=500", price: 42.00, title: "Floral Chiffon Blouse", description: "Semi-sheer high-neck chiffon blouse featuring a delicate vintage floral print.", isPromotion: false, valuePromotion: 0, colors: [AIColor(hexCode: "#e5a7b8", label: "pink", dominance: 55.0), AIColor(hexCode: "#5d7c5a", label: "green", dominance: 25.0)], embedding: localEmbedding(for: 139)),
    Product(id: 140, categoty: "bottoms", imageUrl: "https://images.unsplash.com/photo-1485230895905-ec40ba36b9bc?w=500", price: 38.00, title: "Relaxed Sweatpants", description: "Super-soft heather grey sweatpants with elasticated ankle cuffs.", isPromotion: true, valuePromotion: 5, colors: [AIColor(hexCode: "#b8bac0", label: "grey", dominance: 90.0)], embedding: localEmbedding(for: 140)),
    Product(id: 141, categoty: "outerwear", imageUrl: "https://images.unsplash.com/photo-1490481651871-ab68de25d43d?w=500", price: 65.00, title: "Sherpa Fleece Pullover", description: "Cozy half-zip cream sherpa fleece pullover with a contrast zip pocket.", isPromotion: false, valuePromotion: 0, colors: [AIColor(hexCode: "#f6f3eb", label: "cream", dominance: 82.0)], embedding: localEmbedding(for: 141)),
    Product(id: 142, categoty: "shoes", imageUrl: "https://images.unsplash.com/photo-1514989940723-e8e51635b782?w=500", price: 115.00, title: "Suede Penny Loafers", description: "Handcrafted tobacco brown suede penny loafers with a leather lining.", isPromotion: false, valuePromotion: 0, colors: [AIColor(hexCode: "#8a5a3c", label: "brown", dominance: 78.0)], embedding: localEmbedding(for: 142)),
    Product(id: 143, categoty: "tops", imageUrl: "https://images.unsplash.com/photo-1603252109303-2751441dd157?w=500", price: 49.00, title: "Oversized Oxford Shirt", description: "Classic light blue cotton Oxford shirt in a modern oversized fit.", isPromotion: true, valuePromotion: 10, colors: [AIColor(hexCode: "#add8e6", label: "blue", dominance: 85.0)], embedding: localEmbedding(for: 143)),
    Product(id: 144, categoty: "bottoms", imageUrl: "https://images.unsplash.com/photo-1555689502-c4b22d76c56f?w=500", price: 68.00, title: "High-Rise Mom Jeans", description: "Flattering high-rise non-stretch cotton mom jeans in a classic light blue wash.", isPromotion: false, valuePromotion: 0, colors: [AIColor(hexCode: "#8ab3cf", label: "blue", dominance: 80.0)], embedding: localEmbedding(for: 144)),
    Product(id: 145, categoty: "outerwear", imageUrl: "https://images.unsplash.com/photo-1534126511673-b6899657816a?w=500", price: 55.00, title: "Lightweight Windbreaker", description: "Water-resistant sage green windbreaker with packable hood.", isPromotion: false, valuePromotion: 0, colors: [AIColor(hexCode: "#8fbc8f", label: "sage", dominance: 76.0)], embedding: localEmbedding(for: 145)),
    Product(id: 146, categoty: "shoes", imageUrl: "https://images.unsplash.com/photo-1535043934128-cf0b28d52f95?w=500", price: 48.00, title: "Leather Slide Sandals", description: "Minimal tan leather double-strap slide sandals for warm-weather lounging.", isPromotion: true, valuePromotion: 12, colors: [AIColor(hexCode: "#d2b48c", label: "tan", dominance: 85.0)], embedding: localEmbedding(for: 146)),
    Product(id: 147, categoty: "tops", imageUrl: "https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=500", price: 75.00, title: "Merino Knit Polo", description: "Fine merino wool knit polo shirt in charcoal grey.", isPromotion: false, valuePromotion: 0, colors: [AIColor(hexCode: "#484a50", label: "grey", dominance: 85.0)], embedding: localEmbedding(for: 147)),
    Product(id: 148, categoty: "bottoms", imageUrl: "https://images.unsplash.com/photo-1601924994987-69e26d50dc26?w=500", price: 79.00, title: "Tailored Wide Trousers", description: "High-waisted wide-leg wool-blend trousers in a sophisticated taupe.", isPromotion: false, valuePromotion: 0, colors: [AIColor(hexCode: "#b3a99c", label: "taupe", dominance: 80.0)], embedding: localEmbedding(for: 148)),
    Product(id: 149, categoty: "outerwear", imageUrl: "https://images.unsplash.com/photo-1539109136881-3be0616acf4b?w=500", price: 199.00, title: "Suede Biker Jacket", description: "Luxurious tan suede motorcycle jacket with asymmetrical silver zips.", isPromotion: true, valuePromotion: 8, colors: [AIColor(hexCode: "#cca980", label: "tan", dominance: 84.0)], embedding: localEmbedding(for: 149)),
    Product(id: 150, categoty: "shoes", imageUrl: "https://images.unsplash.com/photo-1602293589930-45aad59ba3ab?w=500", price: 89.00, title: "Woven Leather Mules", description: "Handcrafted cognac brown woven leather mule flats.", isPromotion: false, valuePromotion: 0, colors: [AIColor(hexCode: "#9c522b", label: "cognac", dominance: 75.0)], embedding: localEmbedding(for: 150)),
    Product(id: 151, categoty: "tops", imageUrl: "https://images.unsplash.com/photo-1496747611176-843222e1e57c?w=500", price: 29.00, title: "Mock-Neck Ribbed Top", description: "Sleek slim-fit mock-neck ribbed top in rich forest green.", isPromotion: false, valuePromotion: 0, colors: [AIColor(hexCode: "#224e3a", label: "green", dominance: 88.0)], embedding: localEmbedding(for: 151)),
    Product(id: 152, categoty: "bottoms", imageUrl: "https://images.unsplash.com/photo-1718252540511-e958742e4165?w=500", price: 46.00, title: "Satin Slip Skirt", description: "High-waisted bias-cut midi satin slip skirt in champagne gold.", isPromotion: true, valuePromotion: 10, colors: [AIColor(hexCode: "#decbae", label: "gold", dominance: 92.0)], embedding: localEmbedding(for: 152)),
    Product(id: 153, categoty: "outerwear", imageUrl: "https://images.unsplash.com/photo-1512436991641-6745cdb1723f?w=500", price: 139.00, title: "Lined Parka Jacket", description: "Heavyweight navy blue waterproof parka jacket with faux-fur lined hood.", isPromotion: false, valuePromotion: 0, colors: [AIColor(hexCode: "#1e2d42", label: "navy", dominance: 82.0)], embedding: localEmbedding(for: 153)),
    Product(id: 154, categoty: "shoes", imageUrl: "https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=500", price: 45.00, title: "Classic Canvas Low-Tops", description: "Simple everyday white canvas low-top sneakers.", isPromotion: false, valuePromotion: 0, colors: [AIColor(hexCode: "#ffffff", label: "white", dominance: 90.0)], embedding: localEmbedding(for: 154)),
    Product(id: 155, categoty: "tops", imageUrl: "https://images.unsplash.com/photo-1556905055-8f358a7a47b2?w=500", price: 36.00, title: "Waffle Knit Henley", description: "Textured waffle knit oatmeal cotton Henley shirt.", isPromotion: true, valuePromotion: 5, colors: [AIColor(hexCode: "#eae3d2", label: "oatmeal", dominance: 80.0)], embedding: localEmbedding(for: 155)),
    Product(id: 156, categoty: "bottoms", imageUrl: "https://images.unsplash.com/photo-1582562124811-c09040d0a901?w=500", price: 42.00, title: "Denim Cut-Off Shorts", description: "Classic high-rise raw-edge washed blue denim cut-offs.", isPromotion: false, valuePromotion: 0, colors: [AIColor(hexCode: "#6a8fb5", label: "blue", dominance: 85.0)], embedding: localEmbedding(for: 156)),
    Product(id: 157, categoty: "outerwear", imageUrl: "https://images.unsplash.com/photo-1579547621113-e4bb2a19bdd6?w=500", price: 69.00, title: "Cropped Utility Jacket", description: "Structured cropped utility shirt-jacket in rich khaki olive.", isPromotion: false, valuePromotion: 0, colors: [AIColor(hexCode: "#5f684c", label: "olive", dominance: 78.0)], embedding: localEmbedding(for: 157)),
    Product(id: 158, categoty: "shoes", imageUrl: "https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=500", price: 120.00, title: "Suede Chukka Boots", description: "Lightweight sandy brown suede Chukka boots.", isPromotion: true, valuePromotion: 10, colors: [AIColor(hexCode: "#dfcfbe", label: "sand", dominance: 82.0)], embedding: localEmbedding(for: 158)),
    Product(id: 159, categoty: "tops", imageUrl: "https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=500", price: 38.00, title: "Pima Cotton Henley", description: "Premium short-sleeve Pima cotton Henley in clean slate grey.", isPromotion: false, valuePromotion: 0, colors: [AIColor(hexCode: "#708090", label: "grey", dominance: 80.0)], embedding: localEmbedding(for: 159)),
    Product(id: 160, categoty: "bottoms", imageUrl: "https://images.unsplash.com/photo-1508214751196-bcfd4ca60f91?w=500", price: 48.00, title: "Ribbed Lounge Pants", description: "Ultra-comfortable high-waisted ribbed lounge knit pants in mocha brown.", isPromotion: false, valuePromotion: 0, colors: [AIColor(hexCode: "#5c4033", label: "brown", dominance: 90.0)], embedding: localEmbedding(for: 160)),
    Product(id: 161, categoty: "tops", imageUrl: "https://files.catbox.moe/un3waw.png", price: 34.00, title: "Pleated Chiffon Camisole", description: "Delicate pleated chiffon camisole with adjustable spaghetti straps.", isPromotion: false, valuePromotion: 0, colors: [AIColor(hexCode: "#f9f6f0", label: "cream", dominance: 88.0)], embedding: localEmbedding(for: 161)),
    Product(id: 162, categoty: "bottoms", imageUrl: "https://images.unsplash.com/photo-1604176354204-9268737828e4?w=500", price: 45.00, title: "Tailored Pleated Shorts", description: "Sophisticated tailored pleated shorts in clean light beige.", isPromotion: true, valuePromotion: 10, colors: [AIColor(hexCode: "#ebdcb9", label: "beige", dominance: 85.0)], embedding: localEmbedding(for: 162)),
    Product(id: 163, categoty: "outerwear", imageUrl: "https://images.unsplash.com/photo-1544441893-675973e31985?w=500", price: 129.00, title: "Packable Down Jacket", description: "Ultra-lightweight packable down jacket in matte black.", isPromotion: false, valuePromotion: 0, colors: [AIColor(hexCode: "#151515", label: "black", dominance: 95.0)], embedding: localEmbedding(for: 163)),
    Product(id: 164, categoty: "shoes", imageUrl: "https://images.unsplash.com/photo-1560343090-f0409e92791a?w=500", price: 98.00, title: "Leather Penny Loafers", description: "Classic full-grain brown leather loafers with hand-stitched detailing.", isPromotion: true, valuePromotion: 15, colors: [AIColor(hexCode: "#5c4033", label: "brown", dominance: 88.0)], embedding: localEmbedding(for: 164)),
    Product(id: 165, categoty: "tops", imageUrl: "https://images.unsplash.com/photo-1489987707025-afc232f7ea0f?w=500", price: 36.00, title: "Pima Cotton Mock Neck", description: "Sleek, close-fitting mock neck tee made from luxury Pima cotton.", isPromotion: false, valuePromotion: 0, colors: [AIColor(hexCode: "#ffffff", label: "white", dominance: 92.0)], embedding: localEmbedding(for: 165)),
    Product(id: 166, categoty: "bottoms", imageUrl: "https://images.unsplash.com/photo-1648879441041-830c67c3c517?w=500", price: 49.00, title: "High-Waist Utility Skirt", description: "A-line utility skirt in olive drab with large cargo pockets.", isPromotion: false, valuePromotion: 0, colors: [AIColor(hexCode: "#556b2f", label: "olive", dominance: 80.0)], embedding: localEmbedding(for: 166)),
    Product(id: 167, categoty: "outerwear", imageUrl: "https://images.unsplash.com/photo-1521223890158-f9f7c3d5d504?w=500", price: 89.00, title: "Cropped Faux-Leather Jacket", description: "Chic cropped moto jacket in buttery soft black faux leather.", isPromotion: true, valuePromotion: 20, colors: [AIColor(hexCode: "#1a1a1a", label: "black", dominance: 90.0)], embedding: localEmbedding(for: 167)),
    Product(id: 168, categoty: "shoes", imageUrl: "https://images.unsplash.com/photo-1512374382149-233c42b6a83b?w=500", price: 79.00, title: "Suede Pointed Flats", description: "Elegant pointed-toe flat slip-ons in rich forest green suede.", isPromotion: false, valuePromotion: 0, colors: [AIColor(hexCode: "#1e3f20", label: "green", dominance: 88.0)], embedding: localEmbedding(for: 168)),
    Product(id: 169, categoty: "tops", imageUrl: "https://images.unsplash.com/photo-1620799140408-edc6dcb6d633?w=500", price: 48.00, title: "Linen Band-Collar Shirt", description: "Relaxed band-collar shirt in a lightweight off-white linen-cotton blend.", isPromotion: false, valuePromotion: 0, colors: [AIColor(hexCode: "#faf5ec", label: "cream", dominance: 82.0)], embedding: localEmbedding(for: 169)),
    Product(id: 170, categoty: "bottoms", imageUrl: "https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=500", price: 55.00, title: "Ribbed Knit Flares", description: "Cozy high-rise flared trousers in a heavy ribbed knit fabric.", isPromotion: true, valuePromotion: 5, colors: [AIColor(hexCode: "#7c5947", label: "brown", dominance: 90.0)], embedding: localEmbedding(for: 170)),
    Product(id: 171, categoty: "outerwear", imageUrl: "https://images.unsplash.com/photo-1576995853123-5a10305d93c0?w=500", price: 58.00, title: "Over-Shirt Denim Jacket", description: "Oversized utility shacket in heavy black washed denim.", isPromotion: false, valuePromotion: 0, colors: [AIColor(hexCode: "#252526", label: "black", dominance: 82.0)], embedding: localEmbedding(for: 171)),
    Product(id: 172, categoty: "shoes", imageUrl: "https://images.unsplash.com/photo-1449505278894-297fdb3edbc1?w=500", price: 145.00, title: "Leather Monk Strap Shoes", description: "Sophisticated double monk strap shoes in burnished dark brown leather.", isPromotion: false, valuePromotion: 0, colors: [AIColor(hexCode: "#4a2d1d", label: "brown", dominance: 85.0)], embedding: localEmbedding(for: 172)),
    Product(id: 173, categoty: "tops", imageUrl: "https://images.unsplash.com/photo-1614975058789-41316d0e2e9c?w=500", price: 85.00, title: "V-Neck Merino Sweater", description: "Fine gauge V-neck sweater knitted from 100% fine Merino wool.", isPromotion: true, valuePromotion: 10, colors: [AIColor(hexCode: "#a0a4ab", label: "grey", dominance: 80.0)], embedding: localEmbedding(for: 173)),
    Product(id: 174, categoty: "bottoms", imageUrl: "https://images.unsplash.com/photo-1560243563-062bfc001d68?w=500", price: 59.00, title: "Straight Fit Khakis", description: "Classic flat-front khaki trousers in durable cotton twill.", isPromotion: false, valuePromotion: 0, colors: [AIColor(hexCode: "#cbbb9b", label: "khaki", dominance: 88.0)], embedding: localEmbedding(for: 174)),
    Product(id: 175, categoty: "outerwear", imageUrl: "https://images.unsplash.com/photo-1578932750294-f5075e85f44a?w=500", price: 79.00, title: "Waterproof Anorak", description: "Sporty color-block anorak jacket with adjustable toggle hood.", isPromotion: false, valuePromotion: 0, colors: [AIColor(hexCode: "#325c83", label: "blue", dominance: 60.0), AIColor(hexCode: "#b22222", label: "red", dominance: 30.0)], embedding: localEmbedding(for: 175)),
    Product(id: 176, categoty: "shoes", imageUrl: "https://images.unsplash.com/photo-1463100099107-aa0980c362e6?w=500", price: 45.00, title: "Suede Espadrilles", description: "Casual jute-soled slip-ons in sandy brown suede.", isPromotion: true, valuePromotion: 12, colors: [AIColor(hexCode: "#d2b48c", label: "sand", dominance: 82.0)], embedding: localEmbedding(for: 176)),
    Product(id: 177, categoty: "tops", imageUrl: "https://images.unsplash.com/photo-1574169208507-84376144848b?w=500", price: 26.00, title: "Organic Cotton Rib Tee", description: "Slim-fit ribbed crewneck tee in a soft organic cotton.", isPromotion: false, valuePromotion: 0, colors: [AIColor(hexCode: "#ffffff", label: "white", dominance: 95.0)], embedding: localEmbedding(for: 177)),
    Product(id: 178, categoty: "bottoms", imageUrl: "https://images.unsplash.com/photo-1551854838-212c50b4c184?w=500", price: 62.00, title: "Structured Culottes", description: "High-waisted cropped wide culottes in a structured navy twill.", isPromotion: false, valuePromotion: 0, colors: [AIColor(hexCode: "#1f2a44", label: "navy", dominance: 84.0)], embedding: localEmbedding(for: 178)),
    Product(id: 179, categoty: "outerwear", imageUrl: "https://images.unsplash.com/photo-1483985988355-763728e1935b?w=500", price: 75.00, title: "Fleece-Lined Coach Jacket", description: "Sporty nylon coach jacket with warm fleece lining in dark navy.", isPromotion: true, valuePromotion: 8, colors: [AIColor(hexCode: "#1d2e4f", label: "navy", dominance: 88.0)], embedding: localEmbedding(for: 179)),
    Product(id: 180, categoty: "shoes", imageUrl: "https://images.unsplash.com/photo-1544816155-12df9643f363?w=500", price: 65.00, title: "Leather Dress Sandals", description: "Elegant block-heel dress sandals in soft tan leather.", isPromotion: false, valuePromotion: 0, colors: [AIColor(hexCode: "#c68e65", label: "tan", dominance: 80.0)], embedding: localEmbedding(for: 180)),
    Product(id: 181, categoty: "tops", imageUrl: "https://images.unsplash.com/photo-1503341455253-b2e723bb3dbb?w=500", price: 38.00, title: "Waffle Knit Henley", description: "Classic long-sleeve waffle knit shirt in charcoal heather.", isPromotion: false, valuePromotion: 0, colors: [AIColor(hexCode: "#505052", label: "grey", dominance: 86.0)], embedding: localEmbedding(for: 181)),
    Product(id: 182, categoty: "bottoms", imageUrl: "https://images.unsplash.com/photo-1505022610485-0249ba5b3675?w=500", price: 110.00, title: "Raw Denim Selvedge Jeans", description: "Premium raw indigo selvedge denim jeans in a slim straight cut.", isPromotion: true, valuePromotion: 10, colors: [AIColor(hexCode: "#1e2c54", label: "indigo", dominance: 92.0)], embedding: localEmbedding(for: 182)),
    Product(id: 183, categoty: "outerwear", imageUrl: "https://images.unsplash.com/photo-1506152983158-b4a74a01c721?w=500", price: 68.00, title: "Puffer Vest", description: "Quilted puffer vest with a high stand collar in warm mustard yellow.", isPromotion: false, valuePromotion: 0, colors: [AIColor(hexCode: "#e5a93b", label: "mustard", dominance: 78.0)], embedding: localEmbedding(for: 183)),
    Product(id: 184, categoty: "shoes", imageUrl: "https://images.unsplash.com/photo-1531384441138-2736e62e0919?w=500", price: 55.00, title: "Canvas High-Tops", description: "Timeless high-top canvas sneakers in optical white.", isPromotion: false, valuePromotion: 0, colors: [AIColor(hexCode: "#ffffff", label: "white", dominance: 90.0)], embedding: localEmbedding(for: 184)),
    Product(id: 185, categoty: "tops", imageUrl: "https://images.unsplash.com/photo-1509631179647-0177331693ae?w=500", price: 45.00, title: "Chambray Work Shirt", description: "Rugged double-pocket work shirt in classic light blue chambray.", isPromotion: true, valuePromotion: 5, colors: [AIColor(hexCode: "#b0c4de", label: "blue", dominance: 80.0)], embedding: localEmbedding(for: 185)),
    Product(id: 186, categoty: "bottoms", imageUrl: "https://images.unsplash.com/photo-1676540114417-faa149ba49cc?w=500", price: 42.00, title: "Fleece Jogger Pants", description: "Ultra-comfortable brushed fleece joggers in black.", isPromotion: false, valuePromotion: 0, colors: [AIColor(hexCode: "#121212", label: "black", dominance: 92.0)], embedding: localEmbedding(for: 186)),
    Product(id: 187, categoty: "outerwear", imageUrl: "https://images.unsplash.com/photo-1495105787522-5334e3ffa0ef?w=500", price: 98.00, title: "Satin Bomber Jacket", description: "Luxe heavy satin bomber jacket in sleek emerald green.", isPromotion: false, valuePromotion: 0, colors: [AIColor(hexCode: "#097969", label: "green", dominance: 84.0)], embedding: localEmbedding(for: 187)),
    Product(id: 188, categoty: "shoes", imageUrl: "https://images.unsplash.com/photo-1511283402428-355853756676?w=500", price: 130.00, title: "Suede Chelsea Boots", description: "Classic Chelsea boots in rich chocolate brown suede.", isPromotion: true, valuePromotion: 10, colors: [AIColor(hexCode: "#4e3629", label: "brown", dominance: 82.0)], embedding: localEmbedding(for: 188)),
    Product(id: 189, categoty: "tops", imageUrl: "https://images.unsplash.com/photo-1503342394128-c104d54dba01?w=500", price: 24.00, title: "Slub Cotton Tee", description: "Textured slub cotton crewneck tee in heather grey.", isPromotion: false, valuePromotion: 0, colors: [AIColor(hexCode: "#8a9597", label: "grey", dominance: 80.0)], embedding: localEmbedding(for: 189)),
    Product(id: 190, categoty: "bottoms", imageUrl: "https://images.unsplash.com/photo-1696967648017-8a8d41bef9e8?w=500", price: 36.00, title: "Linen Lounge Shorts", description: "Breezy summer lounge shorts in natural oat linen.", isPromotion: false, valuePromotion: 0, colors: [AIColor(hexCode: "#dfd7c2", label: "oat", dominance: 90.0)], embedding: localEmbedding(for: 190)),
    Product(id: 191, categoty: "tops", imageUrl: "https://images.unsplash.com/photo-1618220179428-22790b461013?w=500", price: 44.00, title: "Printed Camp Collar Shirt", description: "Retro short-sleeve camp collar shirt in a geometric monochrome print.", isPromotion: false, valuePromotion: 0, colors: [AIColor(hexCode: "#1a1a1a", label: "black", dominance: 50.0), AIColor(hexCode: "#ffffff", label: "white", dominance: 40.0)], embedding: localEmbedding(for: 191)),
    Product(id: 192, categoty: "bottoms", imageUrl: "https://images.unsplash.com/photo-1517423568366-8b83523034fd?w=500", price: 65.00, title: "Carpenter Utility Pants", description: "Sturdy canvas carpenter pants with hammer loop in rich tobacco.", isPromotion: true, valuePromotion: 10, colors: [AIColor(hexCode: "#755a3f", label: "brown", dominance: 78.0)], embedding: localEmbedding(for: 192)),
    Product(id: 193, categoty: "outerwear", imageUrl: "https://images.unsplash.com/photo-1511556532299-8f662fc26c06?w=500", price: 155.00, title: "Technical Shell Jacket", description: "Three-layer waterproof technical shell jacket in mountain grey.", isPromotion: false, valuePromotion: 0, colors: [AIColor(hexCode: "#536872", label: "grey", dominance: 82.0)], embedding: localEmbedding(for: 193)),
    Product(id: 194, categoty: "shoes", imageUrl: "https://images.unsplash.com/photo-1491553895911-0055eca6402d?w=500", price: 125.00, title: "Leather Penny Loafers", description: "Classic oxblood leather penny loafers with a storm welt.", isPromotion: false, valuePromotion: 0, colors: [AIColor(hexCode: "#4a0404", label: "oxblood", dominance: 90.0)], embedding: localEmbedding(for: 194)),
    Product(id: 195, categoty: "tops", imageUrl: "https://images.unsplash.com/photo-1549037173-e3b717902c57?w=500", price: 32.00, title: "Ribbed Long Sleeve Tee", description: "Form-fitting ribbed long-sleeve knit top in clean ivory.", isPromotion: true, valuePromotion: 5, colors: [AIColor(hexCode: "#fffff0", label: "ivory", dominance: 80.0)], embedding: localEmbedding(for: 195)),
    Product(id: 196, categoty: "bottoms", imageUrl: "https://images.unsplash.com/photo-1715233749622-3216fe49e682?w=500", price: 58.00, title: "Heavy Canvas Chinos", description: "Durable straight-leg chinos in a heavy washed olive canvas.", isPromotion: false, valuePromotion: 0, colors: [AIColor(hexCode: "#3b3c36", label: "olive", dominance: 85.0)], embedding: localEmbedding(for: 196)),
    Product(id: 197, categoty: "outerwear", imageUrl: "https://images.unsplash.com/photo-1608748010899-18f300247112?w=500", price: 210.00, title: "Duffle Wool Coat", description: "Classic winter duffle coat with toggle closures in dark charcoal wool.", isPromotion: false, valuePromotion: 0, colors: [AIColor(hexCode: "#36454f", label: "charcoal", dominance: 78.0)], embedding: localEmbedding(for: 197)),
    Product(id: 198, categoty: "shoes", imageUrl: "https://images.unsplash.com/photo-1552346154-21d32810aba3?w=500", price: 89.00, title: "Leather Court Sneakers", description: "Minimalist low-top court sneakers in white leather with navy heel tab.", isPromotion: true, valuePromotion: 10, colors: [AIColor(hexCode: "#ffffff", label: "white", dominance: 82.0)], embedding: localEmbedding(for: 198)),
    Product(id: 199, categoty: "tops", imageUrl: "https://images.unsplash.com/photo-1523381210434-271e8be1f52b?w=500", price: 28.00, title: "Pima Cotton V-Neck", description: "Premium Pima cotton V-neck tee in a perfect tailored fit.", isPromotion: false, valuePromotion: 0, colors: [AIColor(hexCode: "#a2a2a0", label: "grey", dominance: 80.0)], embedding: localEmbedding(for: 199)),
    Product(id: 200, categoty: "bottoms", imageUrl: "https://images.unsplash.com/photo-1634564235572-cd6f37694266?w=500", price: 69.00, title: "Satin Cargo Pants", description: "Modern high-waisted cargo trousers made from glossy black heavy satin.", isPromotion: false, valuePromotion: 0, colors: [AIColor(hexCode: "#0a0a0c", label: "black", dominance: 90.0)], embedding: localEmbedding(for: 200)),
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
    let likedStrList = likedIds.map { String($0) }
    let body: [String: Any] = [
      "user_history": likedStrList,
      "top_n": topN
    ]
    
    guard let url = URL(string: Config.STYLE_DZ_AI_BASE_URL + "/ai/recommend"),
          let data = try? JSONSerialization.data(withJSONObject: body) else {
      return fallbackPersonalizedFeed(likedIds: likedIds, topN: topN)
    }
    
    var request = URLRequest(url: url, timeoutInterval: Config.AI_TIMEOUT_SECONDS)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = data
    
    do {
      let (responseData, response) = try await URLSession.shared.data(for: request)
      if let http = response as? HTTPURLResponse, (200 ..< 300).contains(http.statusCode) {
        if let json = try JSONSerialization.jsonObject(with: responseData) as? [String: Any],
           let recommendationRows = json["recommendations"] as? [[String: Any]] {
          let ids: [Int] = recommendationRows.compactMap { row in
            if let intId = row["product_id"] as? Int { return intId }
            if let stringId = row["product_id"] as? String { return Int(stringId) }
            return nil
          }
          let mapped = ids.compactMap { DemoStore.product(id: $0) }
          if !mapped.isEmpty { return mapped }
        }
      }
    } catch {
      print("Error calling /ai/recommend: \(error)")
    }
    
    return fallbackPersonalizedFeed(likedIds: likedIds, topN: topN)
  }
  
  private static func fallbackPersonalizedFeed(likedIds: Set<Int>, topN: Int) -> [Product] {
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
    let wardrobeProducts = DemoStore.products.filter { likedIds.contains($0.id) }
    let wardrobeDicts = wardrobeProducts.map { productToWardrobeDict($0) }
    
    let body: [String: Any] = [
      "wardrobe": wardrobeDicts,
      "candidate_product_id": String(product.id)
    ]
    
    guard let url = URL(string: Config.STYLE_DZ_AI_BASE_URL + "/get-style-suggestion"),
          let data = try? JSONSerialization.data(withJSONObject: body) else {
      return fallbackStyleSuggestion(for: product, likedIds: likedIds)
    }
    
    var request = URLRequest(url: url, timeoutInterval: Config.AI_TIMEOUT_SECONDS)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = data
    
    do {
      let (responseData, response) = try await URLSession.shared.data(for: request)
      if let http = response as? HTTPURLResponse, (200 ..< 300).contains(http.statusCode) {
        if let json = try JSONSerialization.jsonObject(with: responseData) as? [String: Any],
           let suggestionDict = json["suggestion"] as? [String: Any] {
          let suggestionData = try JSONSerialization.data(withJSONObject: suggestionDict)
          let decoder = JSONDecoder()
          let suggestion = try decoder.decode(StyleSuggestion.self, from: suggestionData)
          return suggestion
        }
      }
    } catch {
      print("Error calling /get-style-suggestion: \(error)")
    }
    
    return fallbackStyleSuggestion(for: product, likedIds: likedIds)
  }
  
  private static func fallbackStyleSuggestion(for product: Product, likedIds: Set<Int>) -> StyleSuggestion {
    let likedNames = DemoStore.products.filter { likedIds.contains($0.id) }.map(\.title).joined(separator: ", ")
    return StyleSuggestion(
      styleTip: "Pair \(product.title) with \(likedNames.isEmpty ? "a clean neutral basic" : likedNames) for a balanced demo outfit.",
      bestOccasion: "Casual school presentation, daily city wear, or a relaxed coffee outing.",
      warning: "Avoid adding too many strong colors at once; keep one item as the visual focus."
    )
  }

  static func chatReply(message: String, history: [ChatMessage]) async -> ChatMessage {
    let historyDicts = history.map { msg in
      [
        "role": msg.role,
        "content": msg.content
      ]
    }
    
    let body: [String: Any] = [
      "message": message,
      "chat_history": historyDicts
    ]
    
    guard let url = URL(string: Config.STYLE_DZ_AI_BASE_URL + "/ai/chat"),
          let data = try? JSONSerialization.data(withJSONObject: body) else {
      return await fallbackChatReply(message: message, history: history)
    }
    
    var request = URLRequest(url: url, timeoutInterval: Config.AI_TIMEOUT_SECONDS * 3)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = data
    
    do {
      let (responseData, response) = try await URLSession.shared.data(for: request)
      if let http = response as? HTTPURLResponse, (200 ..< 300).contains(http.statusCode) {
        if let json = try JSONSerialization.jsonObject(with: responseData) as? [String: Any] {
          let responseText = (json["response_text"] as? String) ?? "Sorry, no response from styling assistant."
          let stringIds = (json["recommended_product_ids"] as? [Any]) ?? []
          let ids: [Int] = stringIds.compactMap { idVal in
            if let intVal = idVal as? Int { return intVal }
            if let strVal = idVal as? String { return Int(strVal) }
            return nil
          }
          return ChatMessage(role: "assistant", content: responseText, recommendedProductIds: ids)
        }
      }
    } catch {
      print("Error calling /ai/chat: \(error)")
    }
    
    return await fallbackChatReply(message: message, history: history)
  }
  
  private static func fallbackChatReply(message: String, history: [ChatMessage]) async -> ChatMessage {
    let results = await semanticSearch(query: message, category: nil, topN: 2)
    let ids = results.prefix(2).map(\.id)
    let names = results.prefix(2).map(\.title).joined(separator: " and ")
    let response = names.isEmpty
      ? "I would keep the outfit simple and build around neutral basics from the local demo catalog."
      : "For that request, I would start with \(names). The combination keeps the outfit easy to explain and visually clear for the demo."
    return ChatMessage(role: "assistant", content: response, recommendedProductIds: ids)
  }
  
  private static func productToWardrobeDict(_ product: Product) -> [String: Any] {
    let colorsList = product.colors.map { color in
      [
        "color_label": color.label,
        "hex_code": color.hexCode,
        "dominance_percentage": color.dominance
      ] as [String: Any]
    }
    return [
      "product_name": product.title,
      "category": product.category,
      "colors": colorsList
    ]
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
