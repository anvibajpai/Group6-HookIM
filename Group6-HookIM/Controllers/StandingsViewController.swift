//
//  StandingsViewController.swift
//  Group6-HookIM
//
//  Created by Anvi Bajpai on 10/21/25.
//

import UIKit
import FirebaseFirestore

// Data Model
struct Team {
    let name: String
    let wins: Int
    let losses: Int
    var points: Int { wins * 2 }
}

//Model to manage sports and their categories
struct SportDivision {
    let sport: String
    let division: String
    let title: String
}

class StandingsCell: UITableViewCell {
    @IBOutlet weak var teamLabel: UILabel!
    @IBOutlet weak var lossesLabel: UILabel!
    @IBOutlet weak var winsLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
}

class StandingsViewController: UIViewController, UITabBarDelegate {

    @IBOutlet weak var sportButton: UIButton!
    @IBOutlet weak var tableView: UITableView!

    private var bottomTabBar: UITabBar!
    private let db = Firestore.firestore()
        

    // All available sport+division combos from backend
    private var sportDivisions: [SportDivision] = []

    //Currently selected sport+division
    private var selectedSportDivision: SportDivision? {
        didSet {
            sportButton.setTitle(selectedSportDivision?.title ?? "Select League", for: .normal)
            if let _ = selectedSportDivision {
                fetchStandings()
            } else {
                teamsForSelectedDivision = []
                tableView.reloadData()
            }
        }
    }

    //Teams for selected sport+division
    private var teamsForSelectedDivision: [Team] = []

    //make nav bar appear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barTintColor = UIColor(named: "WarmOrange")
        navigationController?.navigationBar.tintColor = .white
        navigationController?.setNavigationBarHidden(false, animated: animated)
        if let items = bottomTabBar?.items, items.count > 3 {
            bottomTabBar.selectedItem = items[3]
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Standings"
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView() // hide empty cells
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView()

        //for dark mode
        view.backgroundColor = UIColor(named: "AppBackground")
        tableView.backgroundColor = .clear
        
        sportButton.setTitleColor(.label, for: .normal)
        sportButton.backgroundColor = UIColor(named: "CardBackground")
                
        if let navController = navigationController {
            navController.navigationBar.backgroundColor = UIColor(named: "WarmOrange")
        }
        
        setupTabBar()
        loadSportDivisions()
    }
    
    //Loads all the possible divisions we have right now
    private func loadSportDivisions() {
        db.collection("teams").getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }
            if let error = error {
                print("Error loading sport/divisions: \(error)")
                return
            }

            var map: [String: SportDivision] = [:]

            for doc in snapshot?.documents ?? [] {
                let data = doc.data()
                guard
                    let sport = data["sport"] as? String,
                    let division = data["division"] as? String
                else { continue }

                let key = "\(sport)|\(division)"
                if map[key] == nil {
                    let title = "\(division) \(sport)"
                    map[key] = SportDivision(sport: sport, division: division, title: title)
                }
            }

            self.sportDivisions = Array(map.values).sorted { $0.title < $1.title }

            DispatchQueue.main.async {
                self.setupSportDropdown()
                self.selectedSportDivision = self.sportDivisions.first
            }
        }
    }
    
    //Gets the standings for each team
    private func fetchStandings() {
        guard let sd = selectedSportDivision else { return }

        db.collection("teams")
            .whereField("sport", isEqualTo: sd.sport)
            .whereField("division", isEqualTo: sd.division)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                if let error = error {
                    print("Error fetching standings: \(error)")
                    self.teamsForSelectedDivision = []
                    DispatchQueue.main.async { self.tableView.reloadData() }
                    return
                }

                var teams: [Team] = []

                for doc in snapshot?.documents ?? [] {
                    let data = doc.data()
                    let name  = data["name"] as? String ?? "Unnamed Team"
                    let wins  = data["wins"] as? Int ?? 0
                    let losses = data["losses"] as? Int ?? 0
                    teams.append(Team(name: name, wins: wins, losses: losses))
                }

                //Sort by points desc, then wins desc
                teams.sort {
                    if $0.points == $1.points { return $0.wins > $1.wins }
                    return $0.points > $1.points
                }

                self.teamsForSelectedDivision = teams

                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
    }
    
    //Setup sport and division dropdow menu
    private func setupSportDropdown() {
        guard !sportDivisions.isEmpty else {
            sportButton.menu = nil
            sportButton.setTitle("No leagues available", for: .normal)
            sportButton.showsMenuAsPrimaryAction = false
            return
        }

        let actions = sportDivisions.map { sd in
            UIAction(title: sd.title) { [weak self] _ in
                self?.selectedSportDivision = sd
            }
        }
        sportButton.menu = UIMenu(title: "Select League", children: actions)
        sportButton.showsMenuAsPrimaryAction = true
    }
    
    
    //Tab bar
    private func setupTabBar() {
        bottomTabBar = UITabBar()
        bottomTabBar.translatesAutoresizingMaskIntoConstraints = false
        bottomTabBar.backgroundColor = UIColor(named: "WarmOrange")
        bottomTabBar.delegate = self
        
        let homeItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 0)
        let teamsItem = UITabBarItem(title: "Teams", image: UIImage(systemName: "person.3"), tag: 1)
        let scheduleItem = UITabBarItem(title: "Schedule", image: UIImage(systemName: "calendar"), tag: 2)
        let standingsItem = UITabBarItem(title: "Leaderboard", image: UIImage(systemName: "trophy"), tag: 3)
        let profileItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person"), tag: 4)
        
        bottomTabBar.items = [homeItem, teamsItem, scheduleItem, standingsItem, profileItem]
        bottomTabBar.selectedItem = standingsItem
        
        view.addSubview(bottomTabBar)
        
        NSLayoutConstraint.activate([
            bottomTabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomTabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomTabBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        // Adjust table view bottom constraint
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
        case 0: navigateToDashboard()
        case 1: navigateToTeams()
        case 2: navigateToSchedule()
        case 3: return // already here
        case 4: navigateToProfile()
        default: break
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
    
    private func navigateToSchedule() {
        guard let navController = navigationController else { return }
        
        // Check if ScheduleViewController is already in the stack
        if let scheduleVC = navController.viewControllers.first(where: { $0 is ScheduleViewController }) {
            navController.popToViewController(scheduleVC, animated: true)
        } else {
            // Instantiate and push directly
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let scheduleVC = storyboard.instantiateViewController(withIdentifier: "ScheduleViewController") as? ScheduleViewController {
                navController.pushViewController(scheduleVC, animated: true)
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
}

//For standings tabl e
extension StandingsViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    // Header row
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView()
        header.backgroundColor = .secondarySystemBackground

        let labels = ["Team", "W", "L", "Pts"].map { text -> UILabel in
            let label = UILabel()
            label.text = text
            label.font = .systemFont(ofSize: 14, weight: .semibold)
            label.textAlignment = .center
            label.textColor = .label
            return label
        }
        
        let stack = UIStackView(arrangedSubviews: labels)
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.alignment = .center
        stack.spacing = 12

        header.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: header.topAnchor, constant: 8),
            stack.bottomAnchor.constraint(equalTo: header.bottomAnchor, constant: -8),
            stack.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: header.trailingAnchor, constant: -16)
        ])

        return header
    }
    

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return teamsForSelectedDivision.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "StandingsCell",
                                                 for: indexPath) as! StandingsCell
        let team = teamsForSelectedDivision[indexPath.row]

        cell.teamLabel.text = team.name
        cell.winsLabel.text = "\(team.wins)"
        cell.lossesLabel.text = "\(team.losses)"
        cell.pointsLabel.text = "\(team.points)"

        cell.teamLabel.numberOfLines = 0
        cell.teamLabel.lineBreakMode = .byWordWrapping

        if indexPath.row % 2 == 0 {
            cell.backgroundColor = UIColor(named: "CardBackground")
        } else {
            cell.backgroundColor = UIColor(named: "AppBackground")
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
