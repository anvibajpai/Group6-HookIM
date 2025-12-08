//
//  DashboardViewController.swift
//  Group6-HookIM
//
//  Created by Anvi Bajpai on 10/17/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

// MARK: - Color Helpers
extension UIColor {
    static let nearBlack   = UIColor(white: 0.06, alpha: 1)
    static let cardBG      = UIColor(white: 0.95, alpha: 1)
    static let softGray    = UIColor(white: 0.85, alpha: 1)
}


// MARK: - Dashboard VC
class DashboardViewController: UIViewController, UITabBarDelegate {
    
    var user: User!
    func fetchCurrentUser(completion: @escaping (User?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(nil)
            return
        }

        Firestore.firestore().collection("users").document(uid).getDocument { snapshot, error in
            if error != nil {
                completion(nil)
                return
            }

            if let data = snapshot?.data(),
               let user = User(from: data) {
                completion(user)
            } else {
                completion(nil)
            }
        }
    }
    
    // MARK: - Outlets
    @IBOutlet weak var activityLabel: UILabel!
    @IBOutlet weak var bottomTabBar: UITabBar!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var greetingLabel: UILabel!
    @IBOutlet weak var headerContainer: UIView!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var myTeamsTitle: UILabel!
    @IBOutlet weak var notificationButton: UIButton!
    @IBOutlet weak var recentActivityTitle: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var teamsCollection: UICollectionView!
    @IBOutlet weak var upcomingGamesCard: UIView!
    @IBOutlet weak var upcomingGamesTitle: UILabel!
    @IBOutlet weak var upcomingTable: UITableView!
    
    // MARK: - Properties
    private var upcomingGames: [Game] = []
    private var myTeams: [DashboardTeam] = []
    private var recentActivity: Activity?
    private var selectedTeamIdForNavigation: String? // Team ID to pass to Teams view
    
   
    private func formatDateWithOrdinal(_ date: Date) -> String {
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "MMMM"
        let month = monthFormatter.string(from: date)
        
        let hourFormatter = DateFormatter()
        hourFormatter.dateFormat = "ha"
        let time = hourFormatter.string(from: date)
        
        let ordinalSuffix: String
        switch day {
        case 1, 21, 31: ordinalSuffix = "st"
        case 2, 22: ordinalSuffix = "nd"
        case 3, 23: ordinalSuffix = "rd"
        default: ordinalSuffix = "th"
        }
        
        return "\(month) \(day)\(ordinalSuffix), \(time)"
    }
    
   
    private let contentStack = UIStackView()
    
    private let header = UIView()
    private let greetLabel = UILabel()
    private let bellButton = UIButton(type: .system)
    private let rightLogo = UIImageView()
    
    private let upcomingContainer = UIView()
    private let upcomingTitle = UILabel()
    private let upcomingCard = UIView()
    
    private let teamsTitle = UILabel()
    
    private let recentTitle = UILabel()
    private let recentLabel = UILabel()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        navigationController?.navigationBar.barTintColor = UIColor(named: "WarmOrange")
        navigationController?.navigationBar.tintColor = .white
        
        if let items = bottomTabBar.items, items.count > 0 {
            bottomTabBar.selectedItem = items[0] // Home item
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchCurrentUser { user in
            guard let user = user else {
                return
            }

            self.user = user
            DispatchQueue.main.async {
                self.updateUI()
                self.loadFirebaseData()
                self.buildUI()
                self.layoutUI()
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
       
        scrollView.contentOffset = .zero
        scrollView.contentInsetAdjustmentBehavior = .never
    }
    
    private func updateUI() {
        greetLabel.text = "\(user.firstName) \(user.lastName)"
    }
    
    // MARK: - Actions
    @IBAction func notificationButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if let invitesVC = storyboard.instantiateViewController(withIdentifier: "InvitesViewController") as? InvitesViewController {
            self.navigationController?.pushViewController(invitesVC, animated: true)
        }
}
    
    private func loadFirebaseData() {
        guard let userId = Auth.auth().currentUser?.uid else {
            self.upcomingGames = []
            self.myTeams = []
            self.recentActivity = Activity(text: "No recent activity")
            DispatchQueue.main.async {
                self.populateData()
            }
            return
        }
        
        fetchUserTeams(userId: userId) { [weak self] teams in
            guard let self = self else { return }
            self.myTeams = teams
            self.fetchUpcomingGames(for: teams) { games in
                self.upcomingGames = games
                self.updateTeamsWithNextGames(games: games)
                self.recentActivity = Activity(text: "No recent activity")
                DispatchQueue.main.async {
                    self.populateData()
                }
            }
        }
    }
    
    private func fetchUserTeams(userId: String, completion: @escaping ([DashboardTeam]) -> Void) {
        let userRef = Firestore.firestore().collection("users").document(userId)
        
        userRef.getDocument { [weak self] document, error in
            guard let self = self else { return }
            
            if error != nil {
                completion([])
                return
            }
            
            guard let data = document?.data() else {
                self.fetchUserTeamsFromSubcollection(userId: userId, completion: completion)
                return
            }
            
            var teamIds: [String] = []
            
            if let teamsArray = data["teams"] as? [String] {
                teamIds = teamsArray
            } else if let teamsArray = data["teams"] as? [Any] {
                teamIds = teamsArray.compactMap { $0 as? String }
            }
            
            if teamIds.isEmpty {
                self.fetchUserTeamsFromSubcollection(userId: userId, completion: completion)
                return
            }
            
            self.fetchTeamDetails(teamIds: teamIds, completion: completion)
        }
    }
    
    private func fetchUserTeamsFromSubcollection(userId: String, completion: @escaping ([DashboardTeam]) -> Void) {
        Firestore.firestore().collection("users").document(userId)
            .collection("teams").getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if error != nil {
                    completion([])
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    completion([])
                    return
                }
                
                let teamIds = documents.compactMap { doc -> String? in
                    return doc.data()["teamId"] as? String ?? doc.documentID
                }
                
                self.fetchTeamDetails(teamIds: teamIds, completion: completion)
            }
    }
    
    private func fetchTeamDetails(teamIds: [String], completion: @escaping ([DashboardTeam]) -> Void) {
        if teamIds.isEmpty {
            completion([])
            return
        }
        
        let group = DispatchGroup()
        var teams: [DashboardTeam] = []
        
        for teamId in teamIds {
            group.enter()
            Firestore.firestore().collection("teams").document(teamId)
                .getDocument { document, error in
                    defer { group.leave() }
                    
                    if error != nil {
                        return
                    }
                    
                    guard let document = document, document.exists,
                          let data = document.data(),
                          let team = DashboardTeam(dictionary: data, id: teamId) else {
                        return
                    }
                    
                    teams.append(team)
                }
        }
        
        group.notify(queue: .main) {
            completion(teams)
        }
    }
    
    private func fetchUpcomingGames(for teams: [DashboardTeam], completion: @escaping ([Game]) -> Void) {
        
        Firestore.firestore().collection("games")
            .whereField("status", isEqualTo: "upcoming")
            .order(by: "date", descending: false)
            .getDocuments { [weak self] (querySnapshot, error) in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error fetching games: \(error.localizedDescription)")
                    completion([])
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    print("No documents found")
                    completion([])
                    return
                }
                
                
                let games = documents.compactMap { doc in
                    return Game(dictionary: doc.data(), id: doc.documentID)
                }
                
                completion(games)
            }
    }
    
    private func updateTeamsWithNextGames(games: [Game]) {
        for i in 0..<myTeams.count {
            let team = myTeams[i]
            let nextGame = games.first { game in
                game.team == team.name || game.opponent == team.name
            }
            myTeams[i].nextGame = nextGame
        }
    }
    
    // MARK: - Build
    private func buildUI() {
        view.backgroundColor = UIColor(named: "AppBackground")
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        
        contentView.backgroundColor = UIColor.clear
        
        
        upcomingTable.dataSource = self
        upcomingTable.delegate = self
        upcomingTable.register(UpcomingGameCell.self, forCellReuseIdentifier: "UpcomingGameCellID")
        upcomingTable.separatorStyle = .none
        upcomingTable.backgroundColor = .clear
        
        teamsCollection.dataSource = self
        teamsCollection.delegate = self
        teamsCollection.register(TeamCardCell.self, forCellWithReuseIdentifier: "TeamCardCellID")
        teamsCollection.backgroundColor = .clear
        teamsCollection.showsHorizontalScrollIndicator = false
       
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 240, height: 160)
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        teamsCollection.collectionViewLayout = layout
        
        
        upcomingGamesTitle.text = "Upcoming Games"
        myTeamsTitle.text = "My Teams"
        recentActivityTitle.text = "Recent Activity"
        upcomingGamesTitle.textColor = .label
        myTeamsTitle.textColor = .label
        recentActivityTitle.textColor = .label
        activityLabel.textColor = .label
        
        upcomingGamesCard.backgroundColor = UIColor(named: "CardBackground")
        upcomingGamesCard.layer.cornerRadius = 16
        upcomingGamesCard.clipsToBounds = true
        
        upcomingTable.isScrollEnabled = true
        
        bottomTabBar.delegate = self
        
        headerContainer.backgroundColor = UIColor(red: 0.611764729, green: 0.3882353008, blue: 0.1607843041, alpha: 1)
        bottomTabBar.backgroundColor = UIColor(red: 0.7490196078, green: 0.3411764706, blue: 0.0, alpha: 0.7)
        
        notificationButton.tintColor = .white
        notificationButton.isHidden = false
    }
    
    // MARK: - Layout
    private func layoutUI() {
   
        NSLayoutConstraint.deactivate(scrollView.constraints)
        NSLayoutConstraint.deactivate(contentView.constraints)
        NSLayoutConstraint.deactivate(headerContainer.constraints)
        NSLayoutConstraint.deactivate(notificationButton.constraints)
        NSLayoutConstraint.deactivate(logoImageView.constraints)
        NSLayoutConstraint.deactivate(upcomingGamesTitle.constraints)
        NSLayoutConstraint.deactivate(upcomingGamesCard.constraints)
        NSLayoutConstraint.deactivate(upcomingTable.constraints)
        NSLayoutConstraint.deactivate(myTeamsTitle.constraints)
        NSLayoutConstraint.deactivate(teamsCollection.constraints)
        NSLayoutConstraint.deactivate(recentActivityTitle.constraints)
        NSLayoutConstraint.deactivate(activityLabel.constraints)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        headerContainer.translatesAutoresizingMaskIntoConstraints = false
        greetingLabel.translatesAutoresizingMaskIntoConstraints = false
        notificationButton.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        upcomingGamesTitle.translatesAutoresizingMaskIntoConstraints = false
        upcomingGamesCard.translatesAutoresizingMaskIntoConstraints = false
        upcomingTable.translatesAutoresizingMaskIntoConstraints = false
        myTeamsTitle.translatesAutoresizingMaskIntoConstraints = false
        teamsCollection.translatesAutoresizingMaskIntoConstraints = false
        recentActivityTitle.translatesAutoresizingMaskIntoConstraints = false
        activityLabel.translatesAutoresizingMaskIntoConstraints = false
        bottomTabBar.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.contentOffset = .zero
        
        if !upcomingGamesCard.subviews.contains(upcomingTable) {
            upcomingGamesCard.addSubview(upcomingTable)
        }
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomTabBar.topAnchor),
            
            bottomTabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomTabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomTabBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            headerContainer.topAnchor.constraint(equalTo: contentView.topAnchor),
            headerContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            headerContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            headerContainer.heightAnchor.constraint(equalToConstant: 120),
            
            greetingLabel.centerXAnchor.constraint(equalTo: headerContainer.centerXAnchor),
            greetingLabel.centerYAnchor.constraint(equalTo: headerContainer.centerYAnchor),
            
            notificationButton.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor, constant: 16),
            notificationButton.centerYAnchor.constraint(equalTo: headerContainer.centerYAnchor),
            notificationButton.widthAnchor.constraint(equalToConstant: 28),
            notificationButton.heightAnchor.constraint(equalToConstant: 28),
            
            logoImageView.trailingAnchor.constraint(equalTo: headerContainer.trailingAnchor, constant: -14),
            logoImageView.topAnchor.constraint(equalTo: headerContainer.topAnchor, constant: 10.5),
            logoImageView.widthAnchor.constraint(equalToConstant: 82),
            logoImageView.heightAnchor.constraint(equalToConstant: 79),
            
            upcomingGamesTitle.topAnchor.constraint(equalTo: headerContainer.bottomAnchor, constant: 20),
            upcomingGamesTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            upcomingGamesTitle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            upcomingGamesCard.topAnchor.constraint(equalTo: upcomingGamesTitle.bottomAnchor, constant: 10),
            upcomingGamesCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            upcomingGamesCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            upcomingGamesCard.heightAnchor.constraint(equalToConstant: 400),
            
            upcomingTable.topAnchor.constraint(equalTo: upcomingGamesCard.topAnchor, constant: 10),
            upcomingTable.leadingAnchor.constraint(equalTo: upcomingGamesCard.leadingAnchor, constant: 10),
            upcomingTable.trailingAnchor.constraint(equalTo: upcomingGamesCard.trailingAnchor, constant: -10),
            upcomingTable.bottomAnchor.constraint(equalTo: upcomingGamesCard.bottomAnchor, constant: -10),
            
            myTeamsTitle.topAnchor.constraint(equalTo: upcomingGamesCard.bottomAnchor, constant: 20),
            myTeamsTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            myTeamsTitle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            teamsCollection.topAnchor.constraint(equalTo: myTeamsTitle.bottomAnchor, constant: 10),
            teamsCollection.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            teamsCollection.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            teamsCollection.heightAnchor.constraint(equalToConstant: 180),
            
            recentActivityTitle.topAnchor.constraint(equalTo: teamsCollection.bottomAnchor, constant: 20),
            recentActivityTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            recentActivityTitle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            activityLabel.topAnchor.constraint(equalTo: recentActivityTitle.bottomAnchor, constant: 10),
            activityLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            activityLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            activityLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    // MARK: - Populate
    private func populateData() {
        greetingLabel.text = "Hi, \(user.firstName)!"
        
        
        upcomingTable.reloadData()
        teamsCollection.reloadData()
        
       
        activityLabel.text = recentActivity?.text ?? "No recent activity"
    }
    
    private func instantiateFromMainStoryboard(withIdentifier id: String) -> UIViewController {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: id)
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showTeamsSegue",
           let destinationVC = segue.destination as? CaptainTeamViewController,
           let teamId = selectedTeamIdForNavigation {
            destinationVC.teamIdToSelect = teamId
            
            selectedTeamIdForNavigation = nil
        }
    }
    
    // MARK: - UITabBarDelegate
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let items = tabBar.items, let selectedIndex = items.firstIndex(of: item) else { return }
        
        switch selectedIndex {
        case 0:
            return
            
        case 1:
            
            selectedTeamIdForNavigation = nil
            performSegue(withIdentifier: "showTeamsSegue", sender: self)
            
        case 2:
            performSegue(withIdentifier: "showScheduleSegue", sender: self)
            
        case 3:
            performSegue(withIdentifier: "showStandingsSegue", sender: self)
            
        case 4:
            performSegue(withIdentifier: "showProfileSegue", sender: self)
            
        default:
            break
        }
    }
    
}

// MARK: - UITableViewDataSource
extension DashboardViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return upcomingGames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UpcomingGameCellID", for: indexPath) as! UpcomingGameCell
        let game = upcomingGames[indexPath.row]
        cell.configure(with: game, dateFormatter: formatDateWithOrdinal)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension DashboardViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

// MARK: - Collection View DataSource
extension DashboardViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return myTeams.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TeamCardCellID", for: indexPath) as! TeamCardCell
        let team = myTeams[indexPath.item]
        cell.configure(with: team, dateFormatter: formatDateWithOrdinal)
        cell.onViewTeamTapped = { [weak self] team in
            self?.selectedTeamIdForNavigation = team.firebaseDocumentId
            self?.performSegue(withIdentifier: "showTeamsSegue", sender: self)
        }
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension DashboardViewController: UICollectionViewDelegate {
   
}

