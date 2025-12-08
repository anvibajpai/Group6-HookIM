//
//  ScheduleViewController.swift
//  Group6-HookIM
//
//  Created by Arnav Chopra on 10/28/25.
//

import UIKit
import FirebaseFirestore

class ScheduleViewController: UIViewController, UITabBarDelegate {

    @IBOutlet weak var sportButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    private var bottomTabBar: UITabBar!
    
    // MARK: - Properties
    let sports = ["Women's Basketball", "Men's Basketball", "Co-ed Basketball", "Women's Soccer", "Men's Soccer", "Co-ed Soccer", "Women's Dodgeball", "Men's Dodgeball", "Co-ed Dodgeball", "Women's Flag Football", "Men's Flag Football", "Co-ed Flag Football"]
    
    
    private var games: [Game] = []

    var selectedSport: String? {
        didSet {
            sportButton.setTitle(selectedSport ?? "Select Sport", for: .normal)
            fetchGames()
        }
    }
    
    private let db = Firestore.firestore()
    
    private lazy var timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        return formatter
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        if let items = bottomTabBar?.items, items.count > 2 {
            bottomTabBar.selectedItem = items[2]
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(named: "AppBackground")
        tableView.backgroundColor = UIColor(named: "AppBackground")
        
        let calendarButton = UIBarButtonItem(
            image: UIImage(systemName: "calendar"),
            style: .plain,
            target: self,
            action: #selector(didTapCalendarButton)
        )
        navigationItem.rightBarButtonItem = calendarButton
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 60
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView()

        setupSportDropdown()
        selectedSport = sports.first
        
        setupTabBar()
    }
    
    private func fetchGames() {
        // if we cant find the sport for some reason
        guard let selectedSport = selectedSport else {
            self.games = []
            self.tableView.reloadData()
            return
        }

        // string parsing *clown emoji*
        let sportComponents = selectedSport.split(separator: " ")
        let division: String
        let sport: String
        
        if sportComponents.count > 1 {
            division = String(sportComponents.first!)
            sport = sportComponents.dropFirst().joined(separator: " ")
        } else {
            // TODO: make sure defaulting to coed division is valid
            division = "Co-ed"
            sport = selectedSport
        }
        
        // show loading spinner etc

        db.collection("games")
            .whereField("sport", isEqualTo: sport)
            .whereField("division", isEqualTo: division)
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
                    self.games = []
                    self.tableView.reloadData()
                    return
                }
                
                self.games = documents.compactMap { doc in
                    return Game(dictionary: doc.data(), id: doc.documentID)
                }
                
                NotificationScheduler.scheduleNotifications(for: self.games)
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
    }
    
    private func setupTabBar() {
        bottomTabBar = UITabBar()
        bottomTabBar.translatesAutoresizingMaskIntoConstraints = false
        bottomTabBar.backgroundColor = UIColor(red: 0.7490196078, green: 0.3411764706, blue: 0.0, alpha: 0.7)
        bottomTabBar.delegate = self
        
        let homeItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 0)
        let teamsItem = UITabBarItem(title: "Teams", image: UIImage(systemName: "person.3"), tag: 1)
        let scheduleItem = UITabBarItem(title: "Schedule", image: UIImage(systemName: "calendar"), tag: 2)
        let standingsItem = UITabBarItem(title: "Leaderboard", image: UIImage(systemName: "trophy"), tag: 3)
        let profileItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person"), tag: 4)
        
        bottomTabBar.items = [homeItem, teamsItem, scheduleItem, standingsItem, profileItem]
        bottomTabBar.selectedItem = scheduleItem
        
        view.addSubview(bottomTabBar)
        
        NSLayoutConstraint.activate([
            bottomTabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomTabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomTabBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        let constraintsToDeactivate = view.constraints.filter { constraint in
            (constraint.firstItem === tableView && constraint.firstAttribute == .bottom) ||
            (constraint.secondItem === tableView && constraint.secondAttribute == .bottom)
        }
        NSLayoutConstraint.deactivate(constraintsToDeactivate)
        tableView.bottomAnchor.constraint(equalTo: bottomTabBar.topAnchor).isActive = true
    }
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let items = tabBar.items, let selectedIndex = items.firstIndex(of: item) else { return }
        
        switch selectedIndex {
        case 0:
            navigateToDashboard()
        case 1:
            navigateToTeams()
        case 2:
            return
        case 3:
            navigateToStandings()
        case 4:
            navigateToProfile()
        default:
            break
        }
    }
    
    private func navigateToTeams() {
        guard let navController = navigationController else { return }
        
        if let teamsVC = navController.viewControllers.first(where: { $0 is CaptainTeamViewController }) {
            navController.popToViewController(teamsVC, animated: true)
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let teamsVC = storyboard.instantiateViewController(withIdentifier: "CaptainTeamViewController") as? CaptainTeamViewController {
                navController.pushViewController(teamsVC, animated: true)
            }
        }
    }
    
    private func navigateToStandings() {
        guard let navController = navigationController else { return }
        
        if let standingsVC = navController.viewControllers.first(where: { $0 is StandingsViewController }) {
            navController.popToViewController(standingsVC, animated: true)
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let standingsVC = storyboard.instantiateViewController(withIdentifier: "StandingsViewController") as? StandingsViewController {
                navController.pushViewController(standingsVC, animated: true)
            }
        }
    }
    
    private func navigateToProfile() {
        guard let navController = navigationController else { return }
        
        if let profileVC = navController.viewControllers.first(where: { $0 is UserProfileViewController }) {
            navController.popToViewController(profileVC, animated: true)
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let profileVC = storyboard.instantiateViewController(withIdentifier: "UserProfileViewController") as? UserProfileViewController {
                navController.pushViewController(profileVC, animated: true)
            }
        }
    }
    
    private func navigateToDashboard() {
        guard let navController = navigationController else { return }
        
        if let dashboardVC = navController.viewControllers.first(where: { $0 is DashboardViewController }) {
            navController.popToViewController(dashboardVC, animated: true)
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let dashboardVC = storyboard.instantiateViewController(withIdentifier: "DashboardViewController") as? DashboardViewController {
                navController.setViewControllers([dashboardVC], animated: true)
            }
        }
    }

    // MARK: - Helpers
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
    
    private func setupSportDropdown() {
        let actions = sports.map { sport in
            UIAction(title: sport) { _ in
                self.selectedSport = sport
            }
        }
        sportButton.menu = UIMenu(title: "Select Sport", children: actions)
        sportButton.showsMenuAsPrimaryAction = true
    }
    
    @objc private func didTapCalendarButton() {
        performSegue(withIdentifier: "toCalendarSegue", sender: self)
    }
    
}

extension ScheduleViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return games.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let game = games[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ScheduleCell", for: indexPath) as! ScheduleCell
        
        cell.teamLabel.text = game.team
        cell.opponentLabel.text = "vs \(game.opponent)"
        cell.locationLabel.text = game.location
        cell.timeLabel.text = timeFormatter.string(from: game.date)
        
         if indexPath.row % 2 == 0 {
             cell.backgroundColor = UIColor(named: "AppBackground")
         } else {
             cell.backgroundColor = UIColor(named: "CardBackground")
         }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
//        scheduleTestNotifications(indexPath: indexPath)
    }
    
    func scheduleTestNotifications(indexPath: IndexPath) {
        let game = games[indexPath.row]
                
        print("Scheduling test notification for game: \(game.team) vs \(game.opponent)")
        
        let center = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = "Test Notification: Game Data"
        content.body = "You tapped on \(game.team) vs \(game.opponent) at \(game.location)."
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        let request = UNNotificationRequest(identifier: "test-\(game.id)", content: content, trigger: trigger)
        
        center.add(request) { error in
            if let error = error {
                print("Error scheduling test notification: \(error.localizedDescription)")
            } else {
                print("Test notification scheduled. Put app in background.")
            }
        }
    }

    
}
