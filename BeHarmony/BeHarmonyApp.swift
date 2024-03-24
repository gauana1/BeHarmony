//
//  BeHarmonyApp.swift
//  BeHarmony
//
//  Created by Gautam Anand on 3/21/24.
//

import SwiftUI
import Firebase

@main
struct BeHarmonyApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            NavigationStack{
                RootView()
            }
        }
    }
}


class AppDelegate: NSObject, UIApplicationDelegate {
      func application(_ application: UIApplication,
                       didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
      }
}
