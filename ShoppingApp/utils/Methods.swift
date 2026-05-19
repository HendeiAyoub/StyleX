import Foundation
import SwiftUI

enum Utils {
  public static func buildNewProductFromObject(product: NSObject) -> Product {
    let isPromotion = (product.value(forKey: "isPromotion") as? Bool) ?? Bool.random()
    let valuePromotion = (product.value(forKey: "valuePromotion") as? Int) ?? Int.random(in: 1 ..< 15)
    
    var parsedColors: [AIColor] = []
    if let colorArray = product.value(forKey: "colors") as? [NSDictionary] {
      for colorDict in colorArray {
        if let hex = colorDict["hexCode"] as? String,
           let lbl = colorDict["label"] as? String,
           let dom = colorDict["dominance"] as? Double {
          parsedColors.append(AIColor(hexCode: hex, label: lbl, dominance: dom))
        }
      }
    }
    
    if parsedColors.isEmpty {
      parsedColors = DemoStore.localColors(for: product.value(forKey: "id") as! Int)
    }
    
    var parsedEmbedding: [Double] = []
    if let embArray = product.value(forKey: "embedding") as? [Double] {
      parsedEmbedding = embArray
    } else {
      parsedEmbedding = DemoStore.localEmbedding(for: product.value(forKey: "id") as! Int)
    }

    let newProduct = Product(
      id: product.value(forKey: "id") as! Int,
      categoty: product.value(forKey: "category") as! String,
      imageUrl: product.value(forKey: "image") as! String,
      price: product.value(forKey: "price") as! Double,
      title: product.value(forKey: "title") as! String,
      description: product.value(forKey: "description") as! String,
      isPromotion: isPromotion,
      valuePromotion: valuePromotion,
      colors: parsedColors,
      embedding: parsedEmbedding
    )
    return newProduct
  }

  public static func createEmptyProduct() -> Product {
    return Product(
      id: 0,
      categoty: "",
      imageUrl: "",
      price: 0,
      title: "",
      description: "",
      isPromotion: false,
      valuePromotion: 0,
      colors: [],
      embedding: []
    )
  }

  public static func colorRGB(r: Double, g: Double, b: Double, opacity: Double) -> Color {
    return Color(.sRGBLinear, red: r / 255, green: g / 255, blue: b / 255, opacity: opacity)
  }
}
