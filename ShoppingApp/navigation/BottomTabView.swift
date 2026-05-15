import SwiftUI

struct BottomTabView: View {
  @State private var selectedIndex: Int = 0

  var body: some View {
    TabView(selection: $selectedIndex) {
      NavigationStack {
        ProductsView()
      }
      .tabItem {
        Text("Home")
        Image(systemName: "house")
          .renderingMode(.template)
      }
      .tag(0)

      NavigationStack {
        AIChatView()
      }
      .tabItem {
        Text("AI Chat")
        Image(systemName: "message")
          .renderingMode(.template)
      }
      .tag(1)

      NavigationStack {
        CartView(isFromBottomTab: true)
      }
      .tabItem {
        Text("Cart")
        Image(systemName: "cart")
          .renderingMode(.template)
      }
      .tag(2)
    }
  }
}

struct AIChatView: View {
  @StateObject private var demoDatabase = LocalDemoDatabase.shared
  @State private var message = ""
  @State private var isLoading = false

  var body: some View {
    VStack(spacing: 0) {
      ScrollView {
        LazyVStack(alignment: .leading, spacing: 12) {
          ForEach(demoDatabase.chatMessages) { chat in
            VStack(alignment: chat.role == "user" ? .trailing : .leading, spacing: 8) {
              Text(chat.content)
                .font(.body)
                .foregroundStyle(chat.role == "user" ? Color.white : Color.black)
                .padding(10)
                .background(RoundedRectangle(cornerRadius: 8).fill(chat.role == "user" ? Color("primary") : Color("gray_100")))

              if !chat.recommendedProductIds.isEmpty {
                ScrollView(.horizontal) {
                  HStack(spacing: 10) {
                    ForEach(chat.recommendedProductIds, id: \.self) { productId in
                      if let product = DemoStore.product(id: productId) {
                        NavigationLink(destination: ProductDetailView(product: product)) {
                          ProductItemContent(product: product)
                            .frame(width: 140, height: 190)
                            .background(RoundedRectangle(cornerRadius: 8).fill(Color.white).border(Color("gray_300"), width: 1))
                        }
                        .buttonStyle(.plain)
                      }
                    }
                  }
                }
                .scrollIndicators(.hidden)
              }
            }
            .frame(maxWidth: .infinity, alignment: chat.role == "user" ? .trailing : .leading)
          }

          if isLoading {
            ProgressView("Stylist is typing...")
              .padding(.vertical, 8)
          }
        }
        .padding(16)
      }

      HStack {
        TextField("Ask for an outfit", text: $message)
          .padding(10)
          .background(RoundedRectangle(cornerRadius: 8).fill(Color("gray_100")))

        Button {
          sendMessage()
        } label: {
          Image(systemName: "paperplane.fill")
            .foregroundStyle(Color.white)
            .frame(width: 40, height: 40)
            .background(RoundedRectangle(cornerRadius: 8).fill(Color("primary")))
        }
        .disabled(message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading)
      }
      .padding(12)
    }
    .navigationTitle("AI Stylist")
  }

  private func sendMessage() {
    let trimmed = message.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else { return }
    message = ""
    demoDatabase.appendMessage(ChatMessage(role: "user", content: trimmed))
    isLoading = true
    Task {
      let reply = await StyleDZAIService.chatReply(message: trimmed, history: demoDatabase.chatMessages)
      demoDatabase.appendMessage(reply)
      isLoading = false
    }
  }
}
