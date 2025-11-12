//
//  NotificationScheduler.swift
//  Group6-HookIM
//
//  Created by Arnav Chopra on 11/11/25.
//

import Foundation
import UserNotifications

struct NotificationScheduler {
    
    static func scheduleNotifications(for games: [Game]) {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()

        // default to true if not set
        let userWantsNotifications = UserDefaults.standard.bool(forKey: "gameScheduleNotificationsSet") ?
                                     UserDefaults.standard.bool(forKey: "gameScheduleNotifications") : true
        
        guard userWantsNotifications else {
            return
        }
        
        for game in games {
            let content = UNMutableNotificationContent()
            content.title = "Upcoming Game Reminder"
            content.body = "\(game.team) vs \(game.opponent) is starting in 1 hour at \(game.location)!"
            content.sound = .default
            
            let gameDate = game.date
            let triggerDate = gameDate.addingTimeInterval(-3600)
            
            guard triggerDate > Date() else {
                print("Skipping notification for game \(game.id), it's already past.")
                continue
            }
            
            let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            
            let request = UNNotificationRequest(identifier: game.id, content: content, trigger: trigger)
            
            center.add(request) { error in
                if let error = error {
                    print("Error scheduling notification for game \(game.id): \(error.localizedDescription)")
                } else {
                    print("Successfully scheduled notification for game \(game.id) at \(triggerDate)")
                }
            }
        }
    }
}
