//
// 
//  BeHarmony
//
//  Created by Gautam Anand on 3/23/24.
//

import SwiftUI
@MainActor //code runs on main thread
final class SignInEmailViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    
    func signIn() {
        guard !email.isEmpty, !password.isEmpty else{
            print("No email or password found")
            return
        }
        Task {
            do{
                let userData = try await AuthManager.shared.login(email:email, password:password)
                print("logged in")
                print(userData)
            }
            catch{
                print(error)
            }
        }
        
    }
    
}

struct SignInEmail: View {
    @StateObject private var viewModel = SignInEmailViewModel()
    @Binding var isLoggedIn:Bool
    @State private var redirectToResetPassword = false
    var body: some View {
        VStack{
            TextField("Email...", text: $viewModel.email)
                .padding()
                .background(Color.gray.opacity(0.4))
                .cornerRadius(10)
            SecureField("Password...", text: $viewModel.password)
                .padding()
                .background(Color.gray.opacity(0.4))
                .cornerRadius(10)
            Button {
                viewModel.signIn()
                isLoggedIn = true
            }label: {
                Text("Sign In")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height:55)
                    .frame(maxWidth:.infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            Button {
                redirectToResetPassword = true
           } label: {
               Text("Reset Password")
               .foregroundColor(.blue)
               .frame(maxWidth: .infinity)
               .padding()
               .background(RoundedRectangle(cornerRadius: 10).stroke(Color.blue, lineWidth: 2))
           }
           .sheet(isPresented: $redirectToResetPassword) {
                           ResetPasswordView()
           }
            Spacer()
        }
        .padding()
        .navigationTitle("Sign In With Email")
    }
}


struct SignInEmail_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
//            SignInEmail(isLoggedIn: .constant(false))
            RootView()
        }
    }
}

