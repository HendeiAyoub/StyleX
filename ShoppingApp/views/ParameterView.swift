import SwiftUI

struct ParameterView: View {
  @State private var name: String = ""
  @State private var email: String = ""
  @State private var phone: String = ""
  @State private var address: String = ""
  
  @State private var isEditing: Bool = false
  @State private var isSaving: Bool = false
  @State private var showSuccessAlert: Bool = false
  
  // Login flow state
  @State private var isLoggedIn: Bool = false
  @State private var loginEmail: String = ""
  @State private var loginPass: String = ""
  @State private var isSignUp: Bool = false
  @State private var loginError: String = ""
  
  var body: some View {
    ScrollView {
      VStack(spacing: 24) {
        // Upper Logo or Rebrand Badge
        VStack(spacing: 8) {
          Image(systemName: "gearshape.fill")
            .font(.system(size: 64))
            .foregroundStyle(
              LinearGradient(
                colors: [Color("primary"), Color("primary").opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
              )
            )
            .shadow(color: Color("primary").opacity(0.3), radius: 8, x: 0, y: 4)
            .padding(.top, 24)
          
          Text("StyleX Settings")
            .font(.title2)
            .fontWeight(.bold)
            .foregroundColor(.black)
          
          Text("Manage your user parameters and profile parameters")
            .font(.caption)
            .foregroundColor(.gray)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 32)
        }
        
        if isLoggedIn {
          // Profile parameters inputs
          VStack(alignment: .leading, spacing: 20) {
            Text("User Parameters")
              .font(.headline)
              .foregroundColor(.black)
              .padding(.bottom, 4)
            
            // Name Field
            VStack(alignment: .leading, spacing: 6) {
              Text("Full Name")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(Color("primary"))
              
              HStack {
                Image(systemName: "person.fill")
                  .foregroundColor(.gray)
                TextField("Enter full name", text: $name)
                  .disabled(!isEditing)
              }
              .padding()
              .background(RoundedRectangle(cornerRadius: 12).fill(Color("gray_100")))
            }
            
            // Email Field
            VStack(alignment: .leading, spacing: 6) {
              Text("Email Address")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(Color("primary"))
              
              HStack {
                Image(systemName: "envelope.fill")
                  .foregroundColor(.gray)
                TextField("Enter email", text: $email)
                  .keyboardType(.emailAddress)
                  .disabled(!isEditing)
              }
              .padding()
              .background(RoundedRectangle(cornerRadius: 12).fill(Color("gray_100")))
            }
            
            // Phone Field
            VStack(alignment: .leading, spacing: 6) {
              Text("Phone Number")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(Color("primary"))
              
              HStack {
                Image(systemName: "phone.fill")
                  .foregroundColor(.gray)
                TextField("Enter phone number", text: $phone)
                  .keyboardType(.phonePad)
                  .disabled(!isEditing)
              }
              .padding()
              .background(RoundedRectangle(cornerRadius: 12).fill(Color("gray_100")))
            }
            
            // Address Field
            VStack(alignment: .leading, spacing: 6) {
              Text("Shipping Address")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(Color("primary"))
              
              HStack(alignment: .top) {
                Image(systemName: "mappin.and.ellipse")
                  .foregroundColor(.gray)
                  .padding(.top, 2)
                TextEditor(text: $address)
                  .frame(height: 70)
                  .disabled(!isEditing)
                  .scrollContentBackground(.hidden)
                  .background(Color.clear)
              }
              .padding()
              .background(RoundedRectangle(cornerRadius: 12).fill(Color("gray_100")))
            }
            
            // Action Buttons
            HStack(spacing: 12) {
              if isEditing {
                Button {
                  saveProfile()
                } label: {
                  HStack {
                    if isSaving {
                      ProgressView()
                        .tint(.white)
                    } else {
                      Image(systemName: "checkmark.circle.fill")
                      Text("Save & Sync")
                    }
                  }
                  .font(.headline)
                  .foregroundColor(.white)
                  .frame(maxWidth: .infinity)
                  .padding()
                  .background(RoundedRectangle(cornerRadius: 14).fill(Color("primary")))
                }
                .disabled(isSaving)
                
                Button {
                  isEditing = false
                  loadStoredProfile()
                } label: {
                  Text("Cancel")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 14).fill(Color("gray_100")))
                }
              } else {
                Button {
                  isEditing = true
                } label: {
                  HStack {
                    Image(systemName: "pencil")
                    Text("Edit Parameters")
                  }
                  .font(.headline)
                  .foregroundColor(.white)
                  .frame(maxWidth: .infinity)
                  .padding()
                  .background(RoundedRectangle(cornerRadius: 14).fill(Color("primary")))
                }
              }
            }
            .padding(.top, 8)
            
            // Logout Button
            Button {
              logOutUser()
            } label: {
              HStack {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                Text("Log Out")
              }
              .font(.subheadline)
              .fontWeight(.semibold)
              .foregroundColor(.red)
              .frame(maxWidth: .infinity)
              .padding()
              .background(RoundedRectangle(cornerRadius: 14).stroke(Color.red.opacity(0.3), lineWidth: 1))
            }
            .padding(.top, 8)
          }
          .padding(24)
          .background(RoundedRectangle(cornerRadius: 24).fill(Color.white).shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: 5))
          .padding(.horizontal, 16)
        } else {
          // Elegant Glassmorphic Login Form
          VStack(spacing: 18) {
            Text(isSignUp ? "Create Account" : "Sign In to StyleX")
              .font(.headline)
              .foregroundColor(.black)
              .frame(maxWidth: .infinity, alignment: .leading)
            
            if !loginError.isEmpty {
              Text(loginError)
                .font(.caption)
                .foregroundColor(.red)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            // Email Input
            HStack {
              Image(systemName: "envelope.fill")
                .foregroundColor(.gray)
              TextField("Email Address", text: $loginEmail)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color("gray_100")))
            
            // Password Input
            HStack {
              Image(systemName: "lock.fill")
                .foregroundColor(.gray)
              SecureField("Password", text: $loginPass)
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color("gray_100")))
            
            // Login/Signup Action
            Button {
              performAuth()
            } label: {
              Text(isSignUp ? "Register" : "Sign In")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(RoundedRectangle(cornerRadius: 14).fill(Color("primary")))
            }
            
            // Switch Mode Button
            Button {
              withAnimation {
                isSignUp.toggle()
                loginError = ""
              }
            } label: {
              Text(isSignUp ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
                .font(.caption)
                .foregroundColor(Color("primary"))
            }
          }
          .padding(24)
          .background(RoundedRectangle(cornerRadius: 24).fill(Color.white).shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: 5))
          .padding(.horizontal, 16)
        }
      }
      .padding(.bottom, 40)
    }
    .background(Color("gray_100").ignoresSafeArea())
    .onAppear {
      checkLoginStatus()
    }
    .alert(isPresented: $showSuccessAlert) {
      Alert(
        title: Text("Parameters Synced"),
        message: Text("Your user parameter details are successfully persisted and synced in the Supabase database!"),
        dismissButton: .default(Text("OK"))
      )
    }
  }
  
  private func checkLoginStatus() {
    isLoggedIn = UserDefaults.standard.bool(forKey: "stylex_user_is_logged_in")
    if isLoggedIn {
      loadStoredProfile()
    }
  }
  
  private func loadStoredProfile() {
    name = UserDefaults.standard.string(forKey: "stylex_user_name") ?? "Youbi William"
    email = UserDefaults.standard.string(forKey: "stylex_user_email") ?? "youbiwilliam21@gmail.com"
    phone = UserDefaults.standard.string(forKey: "stylex_user_phone") ?? "+212 600000000"
    address = UserDefaults.standard.string(forKey: "stylex_user_address") ?? "123 StyleX Boulevard, Casablanca, Morocco"
  }
  
  private func performAuth() {
    guard !loginEmail.isEmpty && !loginPass.isEmpty else {
      loginError = "Please fill in all credentials."
      return
    }
    
    // In our robust demo app, signing in stores the user session and defaults the profile details.
    withAnimation {
      isLoggedIn = true
      UserDefaults.standard.set(true, forKey: "stylex_user_is_logged_in")
      loadStoredProfile()
    }
  }
  
  private func logOutUser() {
    withAnimation {
      isLoggedIn = false
      UserDefaults.standard.set(false, forKey: "stylex_user_is_logged_in")
    }
  }
  
  private func saveProfile() {
    isSaving = true
    Task {
      let success = await Shoppingservice.saveUserProfile(name: name, email: email, phone: phone, address: address)
      await MainActor.run {
        isSaving = false
        if success {
          isEditing = false
          showSuccessAlert = true
        }
      }
    }
  }
}

#Preview {
  ParameterView()
}
