//
//  RootView.swift
//  BeHarmony
//
//  Created by Gautam Anand on 3/23/24.
//

import SwiftUI

struct RootView: View {
    
    @State private var isLoggedIn: Bool = true
    var body: some View {
        ZStack{
            NavigationStack{
                SettingsView(isLoggedIn: $isLoggedIn)
            }
        }
        .onAppear {
            let authUser = try? AuthManager.shared.getUser()
            self.isLoggedIn = authUser != nil
        }
        .fullScreenCover(isPresented: Binding<Bool>(
            get: { !isLoggedIn },
            set: { _ in }
        )) {
            NavigationStack {
                LoginPage(isLoggedIn: $isLoggedIn)
            }
        }
        
    }
}
#Preview {
    RootView()
}
