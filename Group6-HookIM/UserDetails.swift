//
//  UserDetails.swift
//  Group6-HookIM
//
//  Created by Anvi Bajpai on 10/15/25.
//


import UIKit

struct User: Codable {
    var firstName: String
    var lastName: String
    var gender: String
    var email: String
    var password: String
    var profileImageData: Data?
    var interestedSports: [String]
    var division: String?
    var isFreeAgent: Bool
}

class UserManager {
    static let shared = UserManager()
    private let key = "currentUser_v1"

    private init(){}

    func save(_ user: User) {
        if let data = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    func load() -> User? {
        guard let data = UserDefaults.standard.data(forKey: key),
              let user = try? JSONDecoder().decode(User.self, from: data) else { return nil }
        return user
    }

    func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
