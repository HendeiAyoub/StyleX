<h1 align="center" style="font-weight: bold;">
StyleX
</h1>


<p align="center">
 <a href="#about">About</a> •
 <a href="#tech">Technologies</a> • 
  <a href="#run">Requirements</a> 
</p>


<h2 id="about"> About the App 💻 </h2>

Welcome to StyleX, a shopping/fashion-style app built to study SwiftUI and iOS development. This project utilizes the native iOS development stack and is implemented using Swift and SwiftUI.

Develop by @YoubiWilliam.

<h3 id="started"> Overview </h3>

StyleX fetches product data, providing a list of products, filtering options, and detailed information about each product. It aims to showcase the usage of SwiftUI for building modern and intuitive user interfaces in iOS apps.

<h3 id="features"> Features </h3>

- Fetches product data
- Displays a list of products with images, titles, prices, and categories
- Supports filtering products by category
- Provides detailed information about each product, including description, price, and image

<h2 id="tech"> Technologies </h2>


The main technologies used in this project are:
- Swift
- SwiftUI
- URLSession
- CoreData


In this project, SwiftUI was employed to design native components and screens for iOS, encompassing all primary interfaces. 

<h3 id="resources"> Other Native Resources </h3>

Alongside visual development, the app interacts with the store through requests to fetch products and product categories, facilitated by URLSession. 

Persistence of shopping cart data is achieved using CoreData, ensuring seamless management and retention of user selections within the application.


<h2 id="module"> Demo Module </h2>

The original React Native experiment is disabled in this local AI demo branch. The app runs as a native SwiftUI simulator demo without CocoaPods, npm, Supabase, or Firebase setup.


<h2 id="run"> Run </h2>

<h3 id="requirements"> Requirements </h3>

- Xcode 12 or later
- Swift 5.0 or later
- Internet connection to fetch data

<h3 id="install"> Installation </h3>

1. Clone or download the repository.
2. Open the project in Xcode.
3. Build and run the project on a simulator or a physical device.

<h3 id="usage"> Usage </h3>

Upon launching the app, you will be presented with a list of products. You can tap on any product to view its details. The app also allows you to filter products by category using the provided filter options.

<h2 id="ai-demo"> Local AI Demo Mode </h2>

This branch is prepared for a classroom demo on an iOS Simulator inside a macOS VM. It does not use Supabase, Firebase, or any personal cloud account.

What works locally:
- Local demo product catalog
- Local liked products and AI chat history
- "For You" feed
- Semantic-style search with fallback results
- "You Might Also Like" recommendations
- "Style This Item" advice card
- AI Chat tab with recommended product cards

The app tries the Style-DZ AI endpoint when available:

`https://albatross-emblem-yonder.ngrok-free.dev`

If that server is offline, the app automatically uses local fallback responses so the professor demo still works.

Recommended VM run path:
1. Use macOS with Xcode installed.
2. Open `ShoppingApp.xcodeproj`.
3. Select the `ShoppingApp` scheme.
4. Select an iPhone Simulator.
5. Press Run.

No `pod install`, `npm install`, Supabase setup, Firebase setup, or signing account is required for the simulator demo path.
