//
//  CalendarViewController.swift
//  Group6-HookIM
//
//  Created by Arnav Chopra on 10/29/25.
//

import UIKit
import FirebaseFirestore

// TODO: remove debug prints

//calendar stuff is only available in ios 16+
@available(iOS 16.0, *)
class CalendarViewController: UIViewController, UICalendarViewDelegate, UICalendarSelectionSingleDateDelegate {
    
    @IBOutlet weak var calendarContainerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    private var calendarView: UICalendarView!
    
    private var allGames: [Game] = []
    private var gamesForSelectedDay: [Game] = []
    
    private let db = Firestore.firestore()
    
    private lazy var timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        return formatter
    }()
    
    // i hate date checking
    private var gameDates: Set<String> = []

    // MARK: - View Lifecycle
        
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Games Calendar"
        view.backgroundColor = .systemGroupedBackground
        tableView.backgroundColor = .systemGroupedBackground
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
        tableView.tableFooterView = UIView()
        
        configureCalendar()
        fetchGames()
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
    private func fetchGames() {
        db.collection("games")
            .whereField("status", isEqualTo: "upcoming")
            .order(by: "date", descending: false)
            .getDocuments { [weak self] (querySnapshot, error) in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error fetching games: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    print("No documents found")
                    return
                }
                
                self.allGames = documents.compactMap { doc in
                    return Game(dictionary: doc.data())
                }
                
                DispatchQueue.main.async {
                    self.processGameData()
                    let today = Calendar.current.dateComponents([.year, .month, .day], from: Date())
                    self.filterGames(for: today)
                    
                    self.calendarView.reloadDecorations(forDateComponents: documents.compactMap {
                        let game = Game(dictionary: $0.data())
                        return game != nil ? Calendar.current.dateComponents([.year, .month, .day], from: game!.date) : nil
                    }, animated: true)
                }
            }
    }
    
    
    private func processGameData() {
        let cal = Calendar.current
        
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
            cell.backgroundColor = .systemGroupedBackground
        } else {
            cell.backgroundColor = .secondarySystemGroupedBackground
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
