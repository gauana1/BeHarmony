//
//  LoginWithEmail.swift
//  BeHarmony
//
//  Created by Gautam Anand on 3/23/24.
//

import SwiftUI
@MainActor //code runs on main thread
final class SignUpEmailViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    
    func signUp() {
        guard !email.isEmpty, !password.isEmpty else{
            print("No email or password found")
            return
        }
        Task {
            do{
                let userData = try await AuthManager.shared.createUser(email:email, password:password)
                print("good")
                print(userData)
            }
            catch{
                print(error)
            }
        }
        
    }
    
}

struct SignUpEmail: View {
    @Binding var isLoggedIn: Bool
    @StateObject private var viewModel = SignUpEmailViewModel()
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
                viewModel.signUp()
                isLoggedIn = true
            }label: {
                Text("Register")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height:55)
                    .frame(maxWidth:.infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            Spacer()
        }
        .padding()
        .navigationTitle("Sign up With Email")
    }
}


struct SignUpEmail_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SignUpEmail(isLoggedIn: .constant(false))
        }
    }
}
