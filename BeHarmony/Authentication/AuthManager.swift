//
//  AuthManager.swift
//  BeHarmony
//
//  Created by Gautam Anand on 3/23/24.
//

import Foundation
import FirebaseAuth

struct UserModel{
    let uid:String
    let email:String
    let photoUrl:String?
    enum InitializationError: Error {
           case missingEmail
       }
    init(user:User) throws {
        guard let userEmail = user.email else {
                    throw InitializationError.missingEmail
                }
        self.uid = user.uid
        self.email = userEmail
        self.photoUrl = user.photoURL?.absoluteString
    }
}

final class AuthManager { //checks user on local storage so not async
    static let shared = AuthManager()
    private init() { }
    func getUser() throws -> UserModel {
        guard let user = Auth.auth().currentUser else{
            throw URLError (.badServerResponse)
        }
        return try UserModel(user:user)
    }
    
    func createUser(email: String, password: String) async throws -> UserModel {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        return try UserModel(user: result.user)
    }
    func login(email: String, password: String) async throws -> UserModel {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        return try UserModel(user:result.user)
    }
    func logout() throws{
        try Auth.auth().signOut()
    }
    
    func resetPassword(email:String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
    
}
