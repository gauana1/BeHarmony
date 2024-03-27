//
//  SettingsViewModel.swift
//  BeHarmony
//
//  Created by Gautam Anand on 3/24/24.
//

import Foundation
@MainActor
final class SettingsViewModel:ObservableObject{
    func logout() throws {
        try AuthManager.shared.logout()
    }
}
