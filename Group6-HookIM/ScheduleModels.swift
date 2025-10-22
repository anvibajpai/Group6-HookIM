//
//  ScheduleModels.swift
//  Group6-HookIM
//
//  Created by Arnav Chopra on 10/21/25.
//

import Foundation

// Lists all supported sports in the app
enum Sport: String, CaseIterable {
    case basketball = "Basketball"
    case flagFootball = "Flag Football"
    case volleyball = "Volleyball"
    case soccer = "Soccer"
}

// All important fields for game (named LeagueGame to not clash with DasboardViewController)
struct LeagueGame {
    let id = UUID()
    let sport: Sport
    let teamA: String
    let teamB: String
    let teamAScore: Int
    let teamBScore: Int
    let gameTime: Date
    let location: String
    
    var scoreDisplay: String {
        "\(teamAScore) - \(teamBScore)"
    }
    
    var timeDisplay: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm a"
        return formatter.string(from: gameTime)
    }
    
    var isUpcoming: Bool {
            return gameTime > Date()
        }
}
