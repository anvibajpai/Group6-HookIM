//
//  UserDetails.swift
//  Group6-HookIM
//
//  Created by Anvi Bajpai on 10/15/25.
//

import UIKit
import Foundation
import FirebaseFirestore

struct User {
    let uid: String
    var firstName: String
    var lastName: String
    var gender: String
    var email: String
    var password: String
    var profileImageURL: String?
    var interestedSports: [String]
    var division: String?
    var isFreeAgent: Bool
    
    // Convert the User object into firestore dictionary
    var dictionary: [String: Any] {
        var dict: [String: Any] = [
            "uid": uid,
            "firstName": firstName,
            "lastName": lastName,
            "gender": gender,
            "email": email,
            "password": password,
            "interestedSports": interestedSports,
            "isFreeAgent": isFreeAgent
        ]
        
        if let profileImageURL = profileImageURL {
            dict["profileImageURL"] = profileImageURL
        }
        
        if let division = division {
            dict["division"] = division
        }
        return dict
    }
    
    // Main initializer
    init(uid: String, firstName: String, lastName: String, email: String, password: String, gender: String, profileImageURL: String? = nil, interestedSports: [String], division: String? = nil, isFreeAgent: Bool) {
        self.uid = uid
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.password = password
        self.gender = gender
        self.profileImageURL = profileImageURL
        self.interestedSports = interestedSports
        self.division = division
        self.isFreeAgent = isFreeAgent
    }

    // Initialize from firestore data
    init?(from dict: [String: Any]) {
        guard let uid = dict["uid"] as? String,
              let firstName = dict["firstName"] as? String,
              let lastName = dict["lastName"] as? String,
              let email = dict["email"] as? String,
              let gender = dict["gender"] as? String,
              let isFreeAgent = dict["isFreeAgent"] as? Bool else {
            return nil
        }
        
        self.uid = uid
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.gender = gender
        self.password = dict["password"] as? String ?? ""
        self.profileImageURL = dict["profileImageURL"] as? String
        self.interestedSports = dict["interestedSports"] as? [String] ?? []
        self.division = dict["division"] as? String
        self.isFreeAgent = isFreeAgent
    }
}
