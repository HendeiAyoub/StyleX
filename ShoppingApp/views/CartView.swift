import SwiftUI

struct CartView: View {
  @Environment(\.managedObjectContext) private var viewContext
  @FetchRequest(
    sortDescriptors: [NSSortDescriptor(keyPath: \CartItem.timestamp, ascending: true)],
    animation: .default
  )
  private var cartItems: FetchedResults<CartItem>
  var isFromBottomTab: Bool = false
  let paymentHandler = PaymentHandler()

  func startPaymentProcess(total: Double) {
    paymentHandler.startPayment(total: total) { success in
      if success {
        print(success)
        // self.performSegue(withIdentifier: "Confirmation", sender: self)
      }
    }
  }

  var body: some View {
    VStack {
      VStack(alignment: .center) {
        if isFromBottomTab {
          LogoView(size: 32, isDarkTheme: false)
            .padding(.top, 16)
            .padding(.bottom, 8)
        }
        List {
          ForEach(Array(cartItems.enumerated()), id: \.element) { _, cartItem in
            CartItemView(cartItem: cartItem)
          }
          .onDelete(perform: deleteItems)
          Button {
            startPaymentProcess(total: cartItems.reduce(0) { total, item in
              total + item.price
            })
          } label: {
            CartTotal(value: cartItems.reduce(0) { total, item in
              total + item.price
            })
          }
        }
        .toolbar {
          if !isFromBottomTab {
            EditButton()
          }
        }
      }
      .navigationBarBackButtonHidden(true)
      .navigationBarItems(leading: !isFromBottomTab ? CustomBackButton() : nil)
      .navigationTitle(!isFromBottomTab ? "My Cart" : "")
      .background(Color.white)
    }
  }

  private func deleteItems(offsets: IndexSet) {
    withAnimation {
      offsets.map { cartItems[$0] }.forEach(viewContext.delete)
      do {
        try viewContext.save()
      } catch {
        let nsError = error as NSError
        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
      }
    }
  }
}
