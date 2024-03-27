//
//  SettingsView.swift
//  BeHarmony
//
//  Created by Gautam Anand on 3/23/24.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel  = SettingsViewModel()
    @Binding var isLoggedIn:Bool
    var body: some View {
        List {
            Button("Logout"){
                Task{
                    do{
                        try viewModel.logout()
                        isLoggedIn = false
                    } catch{
                        print(error)
                    }
                }
            }
        }
        .navigationBarTitle("Settings")
    }
}

#Preview {
    SettingsView(isLoggedIn: .constant(false))
}
