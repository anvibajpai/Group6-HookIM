//
//  NotificationModels.swift
//  Group6-HookIM
//
//  Created by Arnav Chopra on 10/21/25.
//

// NotificationModels.swift
import Foundation

// Contains all info for simple alert
struct InformationalAlert {
    let id = UUID()
    let message: String
    let date: Date
}

// Contains all info for incoming request
struct PendingRequest {
    let id = UUID()
    let requestingUser: String
    let teamName: String
    let type: RequestType
    
    enum RequestType {
        case teamInvite
        case playerRequest
    }
    
    var message: String {
        switch type {
        case .teamInvite:
            return "\(requestingUser) invited you to join \(teamName)."
        case .playerRequest:
            return "\(requestingUser) wants to join \(teamName)."
        }
    }
}

// all info for outgoing request
struct OutgoingRequest {
    let id = UUID()
    let recipient: String
    let teamName: String
    var status: RequestStatus
    
    enum RequestStatus: String {
        case pending = "Pending"
        case accepted = "Accepted"
        case declined = "Declined"
    }
    
    var message: String {
        "Your request to \(recipient) to join \(teamName)."
    }
}

// one entry in history
struct RequestHistoryItem {
    let id = UUID()
    let message: String
    let date: Date
    
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
