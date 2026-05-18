import SwiftUI

struct ShoppingHeader: View {
  @Environment(\.managedObjectContext) private var viewContext
  @FetchRequest(
    sortDescriptors: [NSSortDescriptor(keyPath: \CartItem.timestamp, ascending: true)],
    animation: .default
  )
  private var cart: FetchedResults<CartItem>

  var body: some View {
    VStack(alignment: .leading, spacing: 6) {
      HStack {
        // Pure SwiftUI Premium Logo: "Style X"
        LogoView(size: 34, isDarkTheme: true)
        
        Spacer()
        
        NavigationLink {
          CartView()
        } label: {
          CartIcon(count: String(cart.endIndex))
        }
      }
      
      Text("Your one-stop online shop for all your needs!")
        .font(.caption)
        .foregroundStyle(Color.white.opacity(0.7))
    }
    .padding(.horizontal, 24)
    .padding(.top, 40) // Beautiful spacing that accommodates the notch / safe area
    .padding(.bottom, 16)
    .background(
      ZStack {
        // Premium near-black background matching the logo (#0B0B14)
        Color(red: 11/255, green: 11/255, blue: 20/255)
        
        // Soft purple/pink glow behind the logo
        RadialGradient(
          colors: [Color(red: 230/255, green: 27/255, blue: 120/255).opacity(0.15), Color.clear],
          center: .center,
          startRadius: 0,
          endRadius: 180
        )
      }
      .ignoresSafeArea(edges: .top)
    )
  }
}
