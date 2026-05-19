import SwiftUI

struct LogoView: View {
  var size: CGFloat = 34
  var isDarkTheme: Bool = true

  var body: some View {
    HStack(spacing: size * 0.24) {
      Text("Style")
        .font(.system(size: size, weight: .semibold, design: .rounded))
        .foregroundColor(isDarkTheme ? .white : .primary)
      
      // Modern glowing gradient "X" icon
      ZStack {
        // Diagonal branch 1
        RoundedRectangle(cornerRadius: size * 0.12)
          .fill(LinearGradient(
            colors: [Color(red: 255/255, green: 107/255, blue: 59/255), Color(red: 230/255, green: 27/255, blue: 120/255)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
          ))
          .frame(width: size * 0.24, height: size * 0.94)
          .rotationEffect(.degrees(45))
        
        // Diagonal branch 2
        RoundedRectangle(cornerRadius: size * 0.12)
          .fill(LinearGradient(
            colors: [Color(red: 255/255, green: 107/255, blue: 59/255), Color(red: 230/255, green: 27/255, blue: 120/255)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
          ))
          .frame(width: size * 0.24, height: size * 0.94)
          .rotationEffect(.degrees(-45))
      }
      .frame(width: size * 0.94, height: size * 0.94)
    }
  }
}
