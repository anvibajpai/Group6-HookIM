//
//  CalendarViewController.swift
//  Group6-HookIM
//
//  Created by Arnav Chopra on 10/29/25.
//

import UIKit

// TODO: remove debug prints

//calendar stuff is only available in ios 16+
@available(iOS 16.0, *)
class CalendarViewController: UIViewController, UICalendarViewDelegate, UICalendarSelectionSingleDateDelegate {
    
    @IBOutlet weak var calendarContainerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    private var calendarView: UICalendarView!
    
    private var gamesForSelectedDay: [Game] = []
    
    private lazy var timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        return formatter
    }()
    
    // i hate date checking
    private var gameDates: Set<String> = []
    
    lazy var scheduleData: [String: [Game]] = [
        "Women's Basketball": [
            Game(team: "Hoopers", opponent: "Swish", location: "Gregory Gym", date: makeDate("Oct 29, 7PM")),
            Game(team: "Slam Dunks", opponent: "Hoopers", location: "Belmont Hall", date: makeDate("Nov 2, 8PM"))
        ],
        "Men's Basketball": [
            Game(team: "myTeam", opponent: "Team1", location: "Gregory Gym", date: makeDate("Oct 30, 6PM"))
        ],
        "Co-ed Basketball": [
            Game(team: "Hoops", opponent: "Swishers", location: "Gregory Gym", date: makeDate("Nov 1, 9PM")),
            Game(team: "Hoops", opponent: "TeamX", location: "Gregory Gym", date: makeDate("Nov 1, 10PM"))
        ]
    ]

    // MARK: - View Lifecycle
        
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Games Calendar"
        view.backgroundColor = .systemGray6
        tableView.backgroundColor = .clear
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
        tableView.tableFooterView = UIView()
        
        processGameData()
        configureCalendar()
        
        let today = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        filterGames(for: today)
    }
    
    // MARK: - Setup
        
    // programmatically add calendar to storyboard UIView
    private func configureCalendar() {
        calendarView = UICalendarView()
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        calendarView.delegate = self
        
        let selection = UICalendarSelectionSingleDate(delegate: self)
        let today = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        selection.selectedDate = today
        calendarView.selectionBehavior = selection
        
        calendarView.calendar = .current
        calendarView.locale = .current
        calendarView.fontDesign = .rounded
        calendarView.tintColor = .warmOrange
        
        calendarContainerView.addSubview(calendarView)
        
        NSLayoutConstraint.activate([
            calendarView.topAnchor.constraint(equalTo: calendarContainerView.topAnchor),
            calendarView.bottomAnchor.constraint(equalTo: calendarContainerView.bottomAnchor),
            calendarView.leadingAnchor.constraint(equalTo: calendarContainerView.leadingAnchor),
            calendarView.trailingAnchor.constraint(equalTo: calendarContainerView.trailingAnchor)
        ])
    }


    // MARK: - Data Helpers

    private func makeDate(_ dateString: String) -> Date {
        let cal = Calendar.current
        let currentYear = cal.component(.year, from: Date())
        let formatter = DateFormatter()
        
        formatter.dateFormat = "MMM d, ha, yyyy"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        let fullDateString = "\(dateString), \(currentYear)"
        
        if let date = formatter.date(from: fullDateString) {
            return date
        } else {
            print("ERROR: Failed to parse date string: \(fullDateString).")
            return Date()
        }
    }
    
    private func processGameData() {
        let cal = Calendar.current
        
        let allGames = scheduleData.values.flatMap { $0 }
        
        for game in allGames {
            let dc = cal.dateComponents([.year, .month, .day], from: game.date)
             
            if let year = dc.year, let month = dc.month, let day = dc.day {
                let dateKey = "\(year)-\(month)-\(day)"
                gameDates.insert(dateKey)
                print("Added game key: \(dateKey)")
            }
        }
        
        print("processGameData finished. Found \(gameDates.count) game dates.")
    }
    
    private func filterGames(for dateComponents: DateComponents) {
        let cal = Calendar.current
        guard let selectedDate = cal.date(from: dateComponents) else { return }
        
        let allGames = scheduleData.values.flatMap { $0 }
        
        gamesForSelectedDay = allGames.filter { game in
            return cal.isDate(game.date, inSameDayAs: selectedDate)
        }
        
        tableView.reloadData()
    }
    
    // MARK: - Calendar Delegates

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
        
        filterGames(for: date)
    }
    
    func dateSelection(_ selection: UICalendarSelectionSingleDate, canSelectDate dateComponents: DateComponents?) -> Bool {
        return true
    }
    
}

// MARK: - Table View Data Source
@available(iOS 16.0, *)
extension CalendarViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gamesForSelectedDay.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ScheduleCell", for: indexPath) as! ScheduleCell
        
        let game = gamesForSelectedDay[indexPath.row]
        
        cell.teamLabel.text = game.team
        cell.opponentLabel.text = "vs \(game.opponent)"
        cell.locationLabel.text = game.location
        cell.timeLabel.text = timeFormatter.string(from: game.date)
        
        if indexPath.row % 2 == 1 {
            cell.backgroundColor = .systemGray6
        } else {
            cell.backgroundColor = .white
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
