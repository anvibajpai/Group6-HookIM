//
//  CaptainTeamViewController.swift
//  Group6-HookIM
//
//  Created by Shriya Danam on 10/22/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

final class RosterCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    
    var onPlus: (() -> Void)?

    @IBAction func plusTapped(_ sender: UIButton) { onPlus?() }
}


class CaptainTeamViewController: UIViewController, UITabBarDelegate {
    
    @IBOutlet weak var winsLabel: UILabel!
    @IBOutlet weak var lossLabel: UILabel!
    @IBOutlet weak var ptsLabel: UILabel!
    @IBOutlet weak var teamNameSelector: UIButton!
    @IBOutlet weak var sportLabel: UILabel!
    
    @IBOutlet weak var addRosterButton: UIButton!
    @IBOutlet weak var editStatsButton: UIButton!
    
    @IBOutlet weak var rosterTitleLabel: UILabel!
    @IBOutlet weak var rosterTableView: UITableView!
    
    @IBOutlet weak var categoryLabel: UILabel!
    
    @IBOutlet weak var warningMessage: UILabel!
    private var bottomTabBar: UITabBar!
    private var canManageTeam = false
    
    struct Player { let name: String }
        
    struct TeamLite {
        let id: String
        let name: String
        let sport: String
        let division: String
        var wins: Int
        var losses: Int
        var points: Int
        let memberUids: [String]

        init?(id: String, data: [String: Any]) {
            guard
                let name = data["name"] as? String,
                let sport = data["sport"] as? String,
                let division = data["division"] as? String,
                let wins = data["wins"] as? Int,
                let losses = data["losses"] as? Int,
                let points = data["points"] as? Int,
                let memberUids = data["memberUids"] as? [String]
            else { return nil }
            self.id = id
            self.name = name
            self.sport = sport
            self.division = division
            self.wins = wins
            self.losses = losses
            self.points = points
            self.memberUids = memberUids
        }
    }
    
   private let db = Firestore.firestore()
   private var myTeams: [TeamLite] = []
   private var selectedTeam: TeamLite?
   private var roster: [Player] = []
   var teamIdToSelect: String?

    
    private var wins: Int = 0
    private var losses: Int = 0
    
    override func viewDidLoad() {
       super.viewDidLoad()
       rosterTableView.dataSource = self
       rosterTableView.delegate   = self
       rosterTableView.tableFooterView = UIView()
       
       // Basic styling so the menu shows as a dropdown
       teamNameSelector.configuration = nil
       teamNameSelector.backgroundColor = .white
       teamNameSelector.setTitleColor(.black, for: .normal)
       teamNameSelector.layer.cornerRadius = 8
       teamNameSelector.layer.borderWidth = 1
       teamNameSelector.layer.borderColor = UIColor.systemGray4.cgColor
       teamNameSelector.setTitle("My Team", for: .normal)

        loadAllTeams()
       setupTabBar()
        placeRosterTableExactly()
   }
    
    private var rosterConstraints: [NSLayoutConstraint] = []

    private func placeRosterTableExactly() {
        rosterTableView.translatesAutoresizingMaskIntoConstraints = false

        let bottomRefs = view.constraints.filter { c in
            (c.firstItem === rosterTableView && c.firstAttribute == .bottom) ||
            (c.secondItem === rosterTableView && c.secondAttribute == .bottom)
        }
        NSLayoutConstraint.deactivate(bottomRefs + rosterConstraints)

        rosterConstraints = [
            rosterTableView.topAnchor.constraint(equalTo: rosterTitleLabel.bottomAnchor, constant: 12),
            rosterTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 50),
            rosterTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -50),
            rosterTableView.heightAnchor.constraint(equalToConstant: 160)
        ]
        NSLayoutConstraint.activate(rosterConstraints)

        view.bringSubviewToFront(rosterTableView)
        view.layoutIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshSelectedTeamAndRoster()
        loadAllTeams()
        navigationController?.setNavigationBarHidden(false, animated: animated)
        // Set Teams tab as selected
        if let items = bottomTabBar?.items, items.count > 1 {
            bottomTabBar.selectedItem = items[1] // Teams item
        }
        
        
        if let teamIdToSelect = teamIdToSelect,
           !myTeams.isEmpty,
           let teamToSelect = myTeams.first(where: { $0.id == teamIdToSelect }) {
            selectTeam(teamToSelect)
            self.teamIdToSelect = nil
        }
    }
    
    private func selectTeam(_ team: TeamLite) {
        selectedTeam = team
        teamNameSelector.setTitle(team.name, for: .normal)
        buildTeamMenu()
        applyTeam(team)

        // compute permission
        let uid = Auth.auth().currentUser?.uid
        canManageTeam = uid != nil && team.memberUids.contains(uid!)

        // lock/unlock UI
        addRosterButton.isHidden = !canManageTeam
        
        let title = canManageTeam ? "Edit Game Stats" : "Not part of team"
        editStatsButton.setTitle(title, for: .normal)
//        editStatsButton.isEnabled = canManageTeam
        editStatsButton.alpha = canManageTeam ? 1.0 : 0.5

        roster.removeAll()
        rosterTableView.reloadData()
        fetchRoster(for: team)
    }
    
    private func refreshSelectedTeamAndRoster() {
        guard let id = selectedTeam?.id else { return }
            db.collection("teams").document(id).getDocument { [weak self] doc, _ in
                guard let self = self, let data = doc?.data(), let fresh = TeamLite(id: id, data: data) else { return }
                self.selectedTeam = fresh
                self.applyTeam(fresh)
                // recompute permission
                let uid = Auth.auth().currentUser?.uid
                self.canManageTeam = uid != nil && fresh.memberUids.contains(uid!)
                self.addRosterButton.isHidden = !self.canManageTeam
                
                let title = canManageTeam ? "Edit Game Stats" : "Not part of team"
                editStatsButton.setTitle(title, for: .normal)
//                editStatsButton.isEnabled = canManageTeam
                editStatsButton.alpha = canManageTeam ? 1.0 : 0.5
                self.fetchRoster(for: fresh)
        }
    }
    
    func updateLabels() {
            winsLabel.text = "\(wins)"
            lossLabel.text = "\(losses)"
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "editRecordSegue", !canManageTeam {
            let a = UIAlertController(
                title: "View Only",
                message: "Only team members can edit stats.",
                preferredStyle: .alert
            )
            a.addAction(UIAlertAction(title: "OK", style: .default))
            present(a, animated: true)
            return false
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "editRecordSegue",
                   let vc = segue.destination as? EditRecordViewController {
                    
                    // Need a currently selected team
                    guard let current = selectedTeam else { return }

                    // Pre-fill editor
                    vc.wins = wins
                    vc.losses = losses
                    vc.sport = current.sport
                    vc.division = current.division
                    vc.currentTeamId = current.id
                    vc.currentTeamName = current.name  

                    // Callback from editor when Save is tapped
                    vc.onSave = { [weak self] updatedWins, updatedLosses in
                        guard let self = self else { return }
                        guard var current = self.selectedTeam else {
                            // Optional: show an alert if no team is selected
                            let a = UIAlertController(title:  "No Team Selected",
                                                      message: "Please select a team first.",
                                                      preferredStyle: .alert)
                            a.addAction(UIAlertAction(title: "OK", style: .default))
                            self.present(a, animated: true)
                            return
                        }

                        // 1) Update local UI state
                        self.wins = updatedWins
                        self.losses = updatedLosses
                        self.updateLabels()

                        // 2) Update in-memory models
                        current.wins = updatedWins
                        current.losses = updatedLosses
                        self.selectedTeam = current
                        if let idx = self.myTeams.firstIndex(where: { $0.id == current.id }) {
                            self.myTeams[idx] = current
                        }

                        // 3) Persist to Firestore for THIS team
                        self.db.collection("teams").document(current.id)
                            .updateData([
                                "wins": updatedWins,
                                "losses": updatedLosses
                            ]) { err in
                                if let err = err {
                                    print(" Firestore update error: \(err)")
                                }
                            }
                    }
                }
            
            if segue.identifier == "freeAgentBoardSegue",
                   let vc = segue.destination as? FreeAgentBoardViewController {
                    vc.sportText = selectedTeam?.sport
                    vc.teamId = selectedTeam?.id
                }
            }
    
    private func loadAllTeams() {
        db.collection("teams").getDocuments { [weak self] qs, err in
            guard let self = self else { return }
            if let err = err { print("teams fetch error:", err); return }

            let fetched: [TeamLite] = qs?.documents.compactMap {
                TeamLite(id: $0.documentID, data: $0.data())
            } ?? []

            self.myTeams = fetched.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
            self.buildTeamMenu()
            
            
            if let teamIdToSelect = self.teamIdToSelect,
               let teamToSelect = self.myTeams.first(where: { $0.id == teamIdToSelect }) {
                self.selectTeam(teamToSelect)
                self.teamIdToSelect = nil
            } else if self.selectedTeam == nil, let first = self.myTeams.first {
                self.selectTeam(first)
            }
        }
    }
    
    private func loadUserTeams() {                            // NEW
                guard let uid = Auth.auth().currentUser?.uid else { return }
                db.collection("users").document(uid).getDocument { [weak self] snap, err in
                    guard let self = self else { return }
                    if let err = err { print("User fetch error: \(err)"); return }
                    let teamIDs = (snap?.data()?["teams"] as? [String]) ?? []
                    guard !teamIDs.isEmpty else {
                        self.teamNameSelector.setTitle("No Teams Yet", for: .normal)
                        self.applyTeam(nil)
                        return
                    }

                    // Fetch teams by id in chunks of <= 10
                    var fetched: [TeamLite] = []
                    let chunks = stride(from: 0, to: teamIDs.count, by: 10).map {
                        Array(teamIDs[$0 ..< min($0+10, teamIDs.count)])
                    }
                    let group = DispatchGroup()
                    for chunk in chunks {
                        group.enter()
                        self.db.collection("teams")
                            .whereField(FieldPath.documentID(), in: chunk)
                            .getDocuments { qs, _ in
                                qs?.documents.forEach { d in
                                    if let t = TeamLite(id: d.documentID, data: d.data()) {
                                        fetched.append(t)
                                    }
                                }
                                group.leave()
                            }
                    }
                    group.notify(queue: .main) {
                        // Preserve order from user.teams
                        self.myTeams = teamIDs.compactMap { id in fetched.first { $0.id == id } }
                        self.buildTeamMenu()
                        if self.selectedTeam == nil, let first = self.myTeams.first {
                            self.selectTeam(first)
                        }
                    }
                }
            }

    
    
    
    private func buildTeamMenu() {                            // NEW
                let actions = myTeams.map { team in
                    UIAction(title: team.name,
                             state: (team.id == selectedTeam?.id ? .on : .off)) { [weak self] _ in
                        self?.selectTeam(team)
                    }
                }
                teamNameSelector.menu = UIMenu(title: "My Teams", children: actions)
                teamNameSelector.showsMenuAsPrimaryAction = true
            }

            private func applyTeam(_ team: TeamLite?) {
                if let t = team {
                    wins = t.wins
                    losses = t.losses
                    sportLabel.text = t.sport
                    categoryLabel.text = t.division
                    ptsLabel.text = "\(t.points)"
                } else {
                    wins = 0; losses = 0
                    sportLabel.text = "—"
                    categoryLabel.text = "—"
                    ptsLabel.text = "—"
                }
                updateLabels()
            }
    
    private func fetchRoster(for team: TeamLite) {
                let ids = team.memberUids
        guard !ids.isEmpty else {roster = []; rosterTableView.reloadData(); return }

                var collected: [(String, Player)] = []
                let chunks = stride(from: 0, to: ids.count, by: 10).map {
                    Array(ids[$0 ..< min($0 + 10, ids.count)])
                }
                let group = DispatchGroup()
                for chunk in chunks {
                    group.enter()
                    db.collection("users")
                        .whereField(FieldPath.documentID(), in: chunk)
                        .getDocuments { snap, _ in
                            snap?.documents.forEach { d in
                                let first = d.data()["firstName"] as? String ?? ""
                                let last  = d.data()["lastName"]  as? String ?? ""
                                let name = [first, last].joined(separator: " ").trimmingCharacters(in: .whitespaces)
                                collected.append((d.documentID, Player(name: name.isEmpty ? "Unnamed" : name)))
                            }
                            group.leave()
                        }
                }
                group.notify(queue: .main) {
                    // Keep original order from memberUids
                    self.roster = ids.compactMap { id in collected.first { $0.0 == id }?.1 }
                    self.rosterTableView.reloadData()
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
        bottomTabBar.selectedItem = teamsItem
        
        view.addSubview(bottomTabBar)
        
        NSLayoutConstraint.activate([
            bottomTabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomTabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomTabBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        // Adjust table view bottom constraint
        rosterTableView.translatesAutoresizingMaskIntoConstraints = false
        // Find and deactivate existing bottom constraints
        let constraintsToDeactivate = view.constraints.filter { constraint in
            (constraint.firstItem === rosterTableView && constraint.firstAttribute == .bottom) ||
            (constraint.secondItem === rosterTableView && constraint.secondAttribute == .bottom)
        }
        NSLayoutConstraint.deactivate(constraintsToDeactivate)
        // Add new constraint to tab bar
        rosterTableView.bottomAnchor.constraint(equalTo: bottomTabBar.topAnchor).isActive = true
    }
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let items = tabBar.items, let selectedIndex = items.firstIndex(of: item) else { return }
        
        switch selectedIndex {
        case 0: // Home
            navigateToDashboard()
        case 1: // Teams
            // Already on teams, do nothing
            return
        case 2: // Schedule
            navigateToSchedule()
        case 3: // Standings
            navigateToStandings()
        case 4: // Profile
            navigateToProfile()
        default:
            break
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
    
    private func navigateToStandings() {
        guard let navController = navigationController else { return }
        
        // Check if StandingsViewController is already in the stack
        if let standingsVC = navController.viewControllers.first(where: { $0 is StandingsViewController }) {
            navController.popToViewController(standingsVC, animated: true)
        } else {
            // Instantiate and push directly
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let standingsVC = storyboard.instantiateViewController(withIdentifier: "StandingsViewController") as? StandingsViewController {
                navController.pushViewController(standingsVC, animated: true)
            }
        }
    }
    
    private func navigateToProfile() {
        guard let navController = navigationController else { return }
        
        // Check if UserProfileViewController is already in the stack
        if let profileVC = navController.viewControllers.first(where: { $0 is UserProfileViewController }) {
            navController.popToViewController(profileVC, animated: true)
        } else {
            // Instantiate and push directly
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let profileVC = storyboard.instantiateViewController(withIdentifier: "UserProfileViewController") as? UserProfileViewController {
                navController.pushViewController(profileVC, animated: true)
            }
        }
    }
    
    private func navigateToDashboard() {
        guard let navController = navigationController else { return }
        
        // Check if DashboardViewController is already in the stack (should be root)
        if let dashboardVC = navController.viewControllers.first(where: { $0 is DashboardViewController }) {
            navController.popToViewController(dashboardVC, animated: true)
        } else {
            // If for some reason Dashboard is not in stack, instantiate and set as root
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let dashboardVC = storyboard.instantiateViewController(withIdentifier: "DashboardViewController") as? DashboardViewController {
                navController.setViewControllers([dashboardVC], animated: true)
            }
        }
    }
}

extension CaptainTeamViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        roster.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RosterCell", for: indexPath) as! RosterCell
                    let player = roster[indexPath.row]
                    cell.nameLabel.text = player.name
                    cell.onPlus = { [weak self] in
                        guard let self else { return }
                        let alert = UIAlertController(title: "Added",
                                                      message: "\(player.name) tapped +",
                                                      preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(alert, animated: true)
                    }
            return cell
        }
        
        // swipe to delete (just edits the in-memory list)
        func tableView(_ tableView: UITableView,
                       trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
        -> UISwipeActionsConfiguration? {
            let delete = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _,_,done in
                        self?.roster.remove(at: indexPath.row)
                        tableView.deleteRows(at: [indexPath], with: .automatic)
                        done(true)
                    }
            return UISwipeActionsConfiguration(actions: [delete])
        }
}
