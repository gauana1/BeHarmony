//
//  UserManager.swift
//  BeHarmony
//
//  Created by Gautam Anand on 3/24/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Preferences : Codable {
    let ethnicities: [String]?
    let ageRange : [Int]?
//    let orientation : [String]?
    
    init(ethnicities: [String]?, ageRange :[Int]?){
        self.ethnicities = ethnicities
        self.ageRange = ageRange
        
    }
}



struct UserAboutMe : Codable {
    let age:Int?
    let name: String?
    let gender : String?
    let ethnicity : [String]?
    
    init(age: Int?, name: String?, gender: String?, ethnicity: [String]?) {
            self.age = age
            self.name = name
            self.gender = gender
            self.ethnicity = ethnicity
        }
    
    
}


struct DBUser: Codable{
    let userId: String
    let email : String?
    let photoUrl : String?
    let dateCreated : Date?
    let preferences : Preferences?
    let aboutMe : UserAboutMe?
    
    init(user:UserModel) {
        self.userId = user.uid
        self.email = user.email
        self.photoUrl = user.photoUrl
        self.dateCreated = Date()
        self.preferences = nil
        self.aboutMe = nil
    }
}
final class UserManager{
    static let shared = UserManager()
    private init() {}
    private let userCollection = Firestore.firestore().collection("users")
    
    private func userDoc(userId:String) -> DocumentReference{
        userCollection.document(userId)
    }
    
    private let encoder: Firestore.Encoder =  {
        let encoder = Firestore.Encoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }()
    
    private let decoder: Firestore.Decoder =  {
        let decoder = Firestore.Decoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    func createUser(user:DBUser) async throws {
        try userDoc(userId:user.userId).setData(from: user, merge: false, encoder: encoder)
    }
    func getUser(userId:String) async throws -> DBUser {
        try await userDoc(userId:userId).getDocument(as:DBUser.self, decoder:decoder)
    }
    
    func updateAboutMe(userId:String, aboutMe: UserAboutMe) async throws {
        let data: [String: Any] = [
            "aboutMe": [
                "age": aboutMe.age as Any,
                "name": aboutMe.name as Any,
                "gender": aboutMe.gender as Any,
                "ethnicity": aboutMe.ethnicity as Any
            ]
        ]
        try await userDoc(userId: userId).setData(data, merge: true)
    }
    
    func updatePreferences(userId:String, preferences: Preferences) async throws {
        let data: [String: Any] = [
            "Preferences": [
                "ageRange" : preferences.ageRange as Any,
                "ethnicities": preferences.ethnicities as Any
            ]
        ]
        try await userDoc(userId: userId).setData(data, merge: true)
    }
    
    func updatePhotoUrl(userId: String, photoUrl: String) async throws {
        let data: [String: Any] = [
            "photoUrl": photoUrl
        ]
        try await userDoc(userId: userId).setData(data, merge: true)
    }   
}
