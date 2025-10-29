//
//  CalendarViewController.swift
//  Group6-HookIM
//
//  Created by Arnav Chopra on 10/29/25.
//

import UIKit

//calendar stuff is only available in ios 16+
@available(iOS 16.0, *)
class CalendarViewController: UIViewController, UICalendarViewDelegate, UICalendarSelectionSingleDateDelegate {

    // i hate date checking
    private var gameDates: Set<String> = []
    
    var scheduleData: [String: [Game]] = [
        "Women's Basketball": [
            Game(team: "Hoopers", opponent: "Swish", location: "Gregory Gym", time: "Oct 29, 7PM"),
            Game(team: "Slam Dunks", opponent: "Hoopers", location: "Belmont Hall", time: "Nov 2, 8PM")
        ],
        "Men's Basketball": [
            Game(team: "myTeam", opponent: "Team1", location: "Gregory Gym", time: "Oct 30, 6PM")
        ],
        "Co-ed Basketball": [
            Game(team: "Hoops", opponent: "Swishers", location: "Gregory Gym", time: "Nov 1, 9PM"),
            Game(team: "Hoops", opponent: "TeamX", location: "Gregory Gym", time: "Nov 1, 10PM")
        ]
    ]

    private lazy var calendarView: UICalendarView = {
        let calendar = UICalendarView()
        calendar.translatesAutoresizingMaskIntoConstraints = false
        calendar.delegate = self
        
        let selection = UICalendarSelectionSingleDate(delegate: self)
        let today = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        selection.selectedDate = today
        calendar.selectionBehavior = selection
        
        calendar.calendar = .current
        calendar.locale = .current
        calendar.fontDesign = .rounded
        calendar.backgroundColor = .systemGray6
        calendar.layer.cornerRadius = 12
        
        return calendar
    }()
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Games Calendar"
        view.backgroundColor = .systemBackground
        
        processGameData()
        
        view.addSubview(calendarView)
        
        NSLayoutConstraint.activate([
            calendarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            calendarView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            calendarView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
        ])
    }
    
    private func processGameData() {
        let cal = Calendar.current
        let currentYear = cal.component(.year, from: Date())
        
        let formatter = DateFormatter()
        
        // matches "Oct 29, 7PM, 2025".
        // prolly bad design lol, will need to update this if we ever update Game struct
        // like this will break if we change 7PM to 7 PM
        formatter.dateFormat = "MMM d, ha, yyyy"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        let allGames = scheduleData.values.flatMap { $0 }
        
        for game in allGames {
            let fullDateString = "\(game.time), \(currentYear)"
            
            if let date = formatter.date(from: fullDateString) {
                let dc = cal.dateComponents([.year, .month, .day], from: date)
                
                if let year = dc.year, let month = dc.month, let day = dc.day {
                    let dateKey = "\(year)-\(month)-\(day)"
                    gameDates.insert(dateKey)
                    print("Added game key: \(dateKey)")
                }
                
            } else {
                print("Failed to parse date string: \(fullDateString)")
            }
        }
        
        print("processGameData finished. Found \(gameDates.count) game dates.")
    }


    func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
        
        guard let year = dateComponents.year, let month = dateComponents.month, let day = dateComponents.day else {
            return nil
        }
        let dateKey = "\(year)-\(month)-\(day)"
        
        if gameDates.contains(dateKey) {
            return .default(color: .warmOrange, size: .large)
        } else {
            return nil
        }
    }
    
    
    func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
        guard let date = dateComponents else { return }
        
        print("User tapped on: \(date.month ?? 0)/\(date.day ?? 0)/\(date.year ?? 0)")
        
        // not impl yet
        
        // need date parsing
        // let gamesForThisDay = scheduleData.allValues.flatMap { $0 }.filter { ... }

        // let dayVC = DayGamesViewController()
        // dayVC.games = gamesForThisDay
        
        // navigationController?.pushViewController(dayVC, animated: true)
    }
    
    func dateSelection(_ selection: UICalendarSelectionSingleDate, canSelectDate dateComponents: DateComponents?) -> Bool {
        return true
    }
}
