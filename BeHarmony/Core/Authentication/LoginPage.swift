//
//  LoginPage.swift
//  BeHarmony
//
//  Created by Gautam Anand on 3/22/24.
//

import SwiftUI

struct LoginPage: View {
    @Binding var isLoggedIn: Bool
    var body: some View {
        VStack {
            NavigationLink(destination: SignUpEmail(isLoggedIn: $isLoggedIn), label: {
                Text("Sign Up with email")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height:55)
                    .frame(maxWidth:.infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            )
           NavigationLink(destination: SignInEmail(isLoggedIn: $isLoggedIn), label:{
                Text("Already have an account? Sign in")
                    .font(.headline)
                    .foregroundColor(.blue)
                    .frame(height:55)
                    .frame(maxWidth:.infinity)
            }
            )
            Spacer()
        }
        .padding()
        .navigationTitle("Login Page")
    }
}

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            LoginPage(isLoggedIn: .constant(false))
        }
    }
}

