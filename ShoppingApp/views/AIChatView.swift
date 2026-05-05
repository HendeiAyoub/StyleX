import SwiftUI

struct AIChatView: View {
  @State private var messages: [AIChatMessage] = [
    AIChatMessage(role: "assistant", content: "Ask me for an outfit idea from the local StyleX catalog."),
  ]
  @State private var draft = ""
  @State private var recommendedIDs: [String] = []
  @State private var isSending = false
  @State private var errorMessage: String?

  var body: some View {
    VStack(spacing: 0) {
      ScrollView {
        VStack(alignment: .leading, spacing: 12) {
          ForEach(messages) { message in
            HStack {
              if message.role == "assistant" {
                messageBubble(message.content, color: Color("gray_100"), alignment: .leading)
                Spacer(minLength: 32)
              } else {
                Spacer(minLength: 32)
                messageBubble(message.content, color: Color("primary").opacity(0.16), alignment: .trailing)
              }
            }
          }

          if !recommendedIDs.isEmpty {
            VStack(alignment: .leading, spacing: 6) {
              Text("Recommended product IDs")
                .font(.caption.bold())
                .foregroundStyle(Color("secondary"))
              Text(recommendedIDs.joined(separator: ", "))
                .font(.caption)
                .foregroundStyle(Color.black)
            }
            .padding(12)
            .background(RoundedRectangle(cornerRadius: 8).fill(Color("gray_100")))
          }

          if let errorMessage {
            Text(errorMessage)
              .font(.caption)
              .foregroundStyle(Color.red)
              .padding(.top, 4)
          }
        }
        .padding(16)
      }

      HStack(spacing: 8) {
        TextField("Ask for a beach outfit...", text: $draft)
          .textFieldStyle(.roundedBorder)
          .disabled(isSending)

        Button {
          Task {
            await send()
          }
        } label: {
          if isSending {
            ProgressView()
          } else {
            Image(systemName: "paperplane.fill")
          }
        }
        .frame(width: 44, height: 36)
        .background(RoundedRectangle(cornerRadius: 8).fill(Color("primary")))
        .foregroundStyle(Color.white)
        .disabled(draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSending)
      }
      .padding(12)
      .background(Color.white)
    }
    .navigationTitle("AI Stylist")
  }

  private func messageBubble(_ text: String, color: Color, alignment: Alignment) -> some View {
    Text(text)
      .font(.callout)
      .foregroundStyle(Color.black)
      .padding(12)
      .background(RoundedRectangle(cornerRadius: 8).fill(color))
      .frame(maxWidth: 280, alignment: alignment)
  }

  private func send() async {
    let text = draft.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !text.isEmpty else {
      return
    }

    draft = ""
    errorMessage = nil
    isSending = true
    messages.append(AIChatMessage(role: "user", content: text))

    do {
      let response = try await AIClient.shared.chat(message: text, history: messages)
      messages.append(AIChatMessage(role: "assistant", content: response.responseText))
      recommendedIDs = response.recommendedProductIDs
    } catch {
      errorMessage = "Start the local AI server, then try again."
    }

    isSending = false
  }
}
