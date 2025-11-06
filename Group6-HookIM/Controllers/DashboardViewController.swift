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
    static let warmOrange = UIColor(red: 170/255, green: 82/255, blue: 30/255, alpha: 1)
    static let nearBlack   = UIColor(white: 0.06, alpha: 1)
    static let cardBG      = UIColor(white: 0.95, alpha: 1)
    static let softGray    = UIColor(white: 0.85, alpha: 1)
}

// MARK: - Team Card Cell (using external TeamCardCell class)


// MARK: - Dashboard VC
class DashboardViewController: UIViewController, UITabBarDelegate {
    
    var user: User!
    func fetchCurrentUser(completion: @escaping (User?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(nil)
            return
        }

        Firestore.firestore().collection("users").document(uid).getDocument { snapshot, error in
            if let error = error {
                print("Error fetching user: \(error.localizedDescription)")
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
    
    // Helper function to format date with ordinal suffix
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
    
    // Views
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
    
    private let tabBarView = UIView()
    private let tabButtons: [UIButton] = (0..<5).map { _ in UIButton(type: .system) }
    private let selectedDotViews: [UIView] = (0..<5).map { _ in UIView() }
    
    // --- THIS IS YOUR CHANGE (set default to 0) ---
    private var selectedTab: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchCurrentUser { user in
            guard let user = user else {
                print("No logged in user found.")
                return
            }

            self.user = user
            DispatchQueue.main.async {
                self.updateUI()
                // Debug print user
                print("First name: \(user.firstName)")
                print("Last name: \(user.lastName)")
                print("Gender: \(user.gender)")
                print("Email: \(user.email)")
                print("Division: \(user.division ?? "none")")
                print("Free Agent: \(user.isFreeAgent)")
                print("Interested Sports: \(user.interestedSports.isEmpty ? "none" : user.interestedSports.joined(separator: ", "))")
                
                self.loadMockData()
                self.buildUI()
                self.layoutUI()
                self.populateData()
                
                // Debug: Check if outlets are connected
                print("upcomingGamesTitle: \(self.upcomingGamesTitle)")
                print("myTeamsTitle: \(self.myTeamsTitle)")
                print("recentActivityTitle: \(self.recentActivityTitle)")
                print("upcomingTable: \(self.upcomingTable)")
                print("teamsCollection: \(self.teamsCollection)")
                print("activityLabel: \(self.activityLabel)")
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Ensure scroll view starts at the top after layout
        scrollView.contentOffset = .zero
        scrollView.contentInsetAdjustmentBehavior = .never
    }
    
    private func updateUI() {
        greetLabel.text = "\(user.firstName) \(user.lastName)"
    }
    
    // MARK: - Actions
    @IBAction func notificationButtonTapped(_ sender: UIButton) {
        print("Notification button tapped")
        // TODO: Implement notification functionality
    }
    
    private func loadMockData() {
        let mockData = MockDataGenerator.generateMockData()
        upcomingGames = mockData.upcomingGames
        myTeams = mockData.teams
        recentActivity = mockData.activity
    }
    
    // MARK: - Build
    private func buildUI() {
        view.backgroundColor = .nearBlack
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        // Ensure content view is visible
        contentView.backgroundColor = UIColor.clear
        
        // Set up table view and collection view data sources
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
        // Match layout to SportsDashboard
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 240, height: 160)
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        teamsCollection.collectionViewLayout = layout
        
        // Ensure section titles are visible and set text
        upcomingGamesTitle.text = "Upcoming Games"
        myTeamsTitle.text = "My Teams"
        recentActivityTitle.text = "Recent Activity"
        upcomingGamesTitle.textColor = .white
        myTeamsTitle.textColor = .white
        recentActivityTitle.textColor = .white
        activityLabel.textColor = .white
        
        // Ensure the upcoming games card has visible styling (matching SportsDashboard)
        upcomingGamesCard.backgroundColor = .cardBG
        upcomingGamesCard.layer.cornerRadius = 16
        upcomingGamesCard.clipsToBounds = true
        
        // Configure table view to match SportsDashboard
        upcomingTable.isScrollEnabled = false
        
        // Set up tab bar delegate
        bottomTabBar.delegate = self
        
        // Debug: Check if elements are visible
        print("upcomingGamesTitle.isHidden: \(upcomingGamesTitle.isHidden)")
        print("myTeamsTitle.isHidden: \(myTeamsTitle.isHidden)")
        print("recentActivityTitle.isHidden: \(recentActivityTitle.isHidden)")
        print("upcomingTable.isHidden: \(upcomingTable.isHidden)")
        print("teamsCollection.isHidden: \(teamsCollection.isHidden)")
        
        // Comment out programmatic UI creation since we're using storyboard
        /*
        // Scroll area
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        contentStack.axis = .vertical
        contentStack.spacing = 20
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)
        
        // Header (orange)
        header.backgroundColor = .warmOrange
        header.translatesAutoresizingMaskIntoConstraints = false
        header.heightAnchor.constraint(equalToConstant: 120).isActive = true
        
        bellButton.setImage(UIImage(systemName: "bell"), for: .normal)
        bellButton.tintColor = .white
        bellButton.backgroundColor = UIColor(white: 0, alpha: 0.2)
        bellButton.layer.cornerRadius = 10
        bellButton.translatesAutoresizingMaskIntoConstraints = false
        // --- THIS IS YOUR CHANGE (added action) ---
        bellButton.addTarget(self, action: #selector(didTapNotifications), for: .touchUpInside)
        
        greetLabel.textColor = .white
        greetLabel.font = .boldSystemFont(ofSize: 20)
        greetLabel.translatesAutoresizingMaskIntoConstraints = false
        
        rightLogo.image = UIImage(systemName: "tortoise.fill") // replace with your asset logo
        rightLogo.tintColor = .white
        rightLogo.contentMode = .scaleAspectFit
        rightLogo.translatesAutoresizingMaskIntoConstraints = false
        
        header.addSubview(bellButton)
        header.addSubview(greetLabel)
        header.addSubview(rightLogo)
        contentStack.addArrangedSubview(header)
        
        // Upcoming Games
        let upWrap = UIView(); upWrap.translatesAutoresizingMaskIntoConstraints = false
        upcomingTitle.text = "Upcoming Games"
        upcomingTitle.textColor = .white
        upcomingTitle.font = .boldSystemFont(ofSize: 17)
        
        upcomingCard.backgroundColor = .cardBG
        upcomingCard.layer.cornerRadius = 14
        upcomingCard.layer.shadowOpacity = 0.15
        upcomingCard.layer.shadowColor = UIColor.black.cgColor
        upcomingCard.layer.shadowRadius = 4
        upcomingCard.layer.shadowOffset = CGSize(width: 0, height: 2)
        upcomingCard.translatesAutoresizingMaskIntoConstraints = false
        
        // Configure table view
        upcomingTable.translatesAutoresizingMaskIntoConstraints = false
        upcomingTable.dataSource = self
        upcomingTable.delegate = self
        upcomingTable.isScrollEnabled = false
        upcomingTable.backgroundColor = .clear
        upcomingTable.separatorStyle = .none
        upcomingTable.register(UpcomingGameCell.self, forCellReuseIdentifier: "UpcomingGameCellID")
        
        upcomingCard.addSubview(upcomingTable)
        
        upWrap.addSubview(upcomingTitle)
        upWrap.addSubview(upcomingCard)
        contentStack.addArrangedSubview(upWrap)
        
        // My Teams (horizontal collection)
        teamsTitle.text = "My Teams"
        teamsTitle.textColor = .white
        teamsTitle.font = .boldSystemFont(ofSize: 17)
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 14
        layout.itemSize = CGSize(width: 240, height: 200)
        
        teamsCollection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        teamsCollection.translatesAutoresizingMaskIntoConstraints = false
        teamsCollection.backgroundColor = .clear
        teamsCollection.showsHorizontalScrollIndicator = false
        teamsCollection.register(TeamCardCell.self, forCellWithReuseIdentifier: "TeamCardCellID")
        teamsCollection.dataSource = self
        
        let teamsWrap = UIStackView(arrangedSubviews: [teamsTitle, teamsCollection])
        teamsWrap.axis = .vertical
        teamsWrap.spacing = 12
        teamsWrap.translatesAutoresizingMaskIntoConstraints = false
        contentStack.addArrangedSubview(teamsWrap)
        
        // Recent Activity
        recentTitle.text = "Recent Activity"
        recentTitle.textColor = .white
        recentTitle.font = .boldSystemFont(ofSize: 17)
        
        recentLabel.textColor = UIColor.white.withAlphaComponent(0.85)
        recentLabel.numberOfLines = 0
        recentLabel.font = .systemFont(ofSize: 14)
        recentLabel.text = recentActivity?.text ?? "No recent activity"
        
        let recentWrap = UIStackView(arrangedSubviews: [recentTitle, recentLabel])
        recentWrap.axis = .vertical
        recentWrap.spacing = 8
        recentWrap.translatesAutoresizingMaskIntoConstraints = false
        contentStack.addArrangedSubview(recentWrap)
        
        // Spacer for tab bar
        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        spacer.heightAnchor.constraint(equalToConstant: 70).isActive = true
        contentStack.addArrangedSubview(spacer)
        
        // Bottom Tab Bar
        tabBarView.backgroundColor = .warmOrange
        tabBarView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tabBarView)
        
        let symbols = ["house.fill", "person.3.fill", "calendar", "rosette", "person.crop.circle"]
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 0
        stack.distribution = .equalSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        tabBarView.addSubview(stack)
        
        for i in 0..<5 {
            let v = UIStackView()
            v.axis = .vertical
            v.alignment = .center
            v.spacing = 4
            v.translatesAutoresizingMaskIntoConstraints = false
            
            selectedDotViews[i].backgroundColor = .white
            selectedDotViews[i].layer.cornerRadius = 3
            selectedDotViews[i].translatesAutoresizingMaskIntoConstraints = false
            selectedDotViews[i].heightAnchor.constraint(equalToConstant: 6).isActive = true
            selectedDotViews[i].widthAnchor.constraint(equalToConstant: 6).isActive = true
            selectedDotViews[i].alpha = (i == selectedTab) ? 1 : 0
            
            tabButtons[i].setImage(UIImage(systemName: symbols[i]), for: .normal)
            tabButtons[i].tintColor = .white
            tabButtons[i].tag = i
            tabButtons[i].addTarget(self, action: #selector(tabTapped(_:)), for: .touchUpInside)
            
            v.addArrangedSubview(selectedDotViews[i])
            v.addArrangedSubview(tabButtons[i])
            stack.addArrangedSubview(v)
        }
        
        // Constraints for tab bar inner stack
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: tabBarView.leadingAnchor, constant: 28),
            stack.trailingAnchor.constraint(equalTo: tabBarView.trailingAnchor, constant: -28),
            stack.topAnchor.constraint(equalTo: tabBarView.topAnchor, constant: 6),
            stack.bottomAnchor.constraint(equalTo: tabBarView.bottomAnchor, constant: -10)
        ])
        */
    }
    
    // MARK: - Layout
    private func layoutUI() {
        // Deactivate any existing constraints from storyboard to avoid conflicts
        // We need to deactivate on all views we're repositioning
        NSLayoutConstraint.deactivate(scrollView.constraints)
        NSLayoutConstraint.deactivate(contentView.constraints)
        NSLayoutConstraint.deactivate(headerContainer.constraints)
        NSLayoutConstraint.deactivate(upcomingGamesTitle.constraints)
        NSLayoutConstraint.deactivate(upcomingGamesCard.constraints)
        NSLayoutConstraint.deactivate(upcomingTable.constraints)
        NSLayoutConstraint.deactivate(myTeamsTitle.constraints)
        NSLayoutConstraint.deactivate(teamsCollection.constraints)
        NSLayoutConstraint.deactivate(recentActivityTitle.constraints)
        NSLayoutConstraint.deactivate(activityLabel.constraints)
        
        // Set translatesAutoresizingMaskIntoConstraints for storyboard outlets
        // This is critical - storyboard views default to true, which conflicts with programmatic constraints
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
        
        // Ensure scroll view starts at the top
        scrollView.contentOffset = .zero
        
        // Ensure table view is inside the card (may not be set in storyboard)
        if !upcomingGamesCard.subviews.contains(upcomingTable) {
            upcomingGamesCard.addSubview(upcomingTable)
        }
        
        // Match SportsDashboard constraints exactly
        NSLayoutConstraint.activate([
            // Scroll view constraints
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomTabBar.topAnchor),
            
            // Tab bar constraints
            bottomTabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomTabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomTabBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            // Content view constraints
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Header container constraints
            headerContainer.topAnchor.constraint(equalTo: contentView.topAnchor),
            headerContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            headerContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            headerContainer.heightAnchor.constraint(equalToConstant: 120),
            
            // Greeting label constraints
            greetingLabel.centerXAnchor.constraint(equalTo: headerContainer.centerXAnchor),
            greetingLabel.centerYAnchor.constraint(equalTo: headerContainer.centerYAnchor),
            
            // Notification button constraints
            notificationButton.trailingAnchor.constraint(equalTo: headerContainer.trailingAnchor, constant: -20),
            notificationButton.topAnchor.constraint(equalTo: headerContainer.topAnchor, constant: 20),
            notificationButton.widthAnchor.constraint(equalToConstant: 30),
            notificationButton.heightAnchor.constraint(equalToConstant: 30),
            
            // Logo constraints
            logoImageView.centerXAnchor.constraint(equalTo: headerContainer.centerXAnchor),
            logoImageView.bottomAnchor.constraint(equalTo: headerContainer.bottomAnchor, constant: -20),
            logoImageView.widthAnchor.constraint(equalToConstant: 40),
            logoImageView.heightAnchor.constraint(equalToConstant: 40),
            
            // Upcoming games title constraints
            upcomingGamesTitle.topAnchor.constraint(equalTo: headerContainer.bottomAnchor, constant: 20),
            upcomingGamesTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            upcomingGamesTitle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Upcoming games card constraints
            upcomingGamesCard.topAnchor.constraint(equalTo: upcomingGamesTitle.bottomAnchor, constant: 10),
            upcomingGamesCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            upcomingGamesCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            upcomingGamesCard.heightAnchor.constraint(equalToConstant: 200),
            
            // Table view constraints (inside card)
            upcomingTable.topAnchor.constraint(equalTo: upcomingGamesCard.topAnchor, constant: 10),
            upcomingTable.leadingAnchor.constraint(equalTo: upcomingGamesCard.leadingAnchor, constant: 10),
            upcomingTable.trailingAnchor.constraint(equalTo: upcomingGamesCard.trailingAnchor, constant: -10),
            upcomingTable.bottomAnchor.constraint(equalTo: upcomingGamesCard.bottomAnchor, constant: -10),
            
            // My teams title constraints
            myTeamsTitle.topAnchor.constraint(equalTo: upcomingGamesCard.bottomAnchor, constant: 20),
            myTeamsTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            myTeamsTitle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Teams collection constraints
            teamsCollection.topAnchor.constraint(equalTo: myTeamsTitle.bottomAnchor, constant: 10),
            teamsCollection.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            teamsCollection.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            teamsCollection.heightAnchor.constraint(equalToConstant: 180),
            
            // Recent activity title constraints
            recentActivityTitle.topAnchor.constraint(equalTo: teamsCollection.bottomAnchor, constant: 20),
            recentActivityTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            recentActivityTitle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Activity label constraints
            activityLabel.topAnchor.constraint(equalTo: recentActivityTitle.bottomAnchor, constant: 10),
            activityLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            activityLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            activityLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    // MARK: - Populate
    private func populateData() {
        greetingLabel.text = "Hi, \(user.firstName)!"
        
        // Debug: Check data
        print("upcomingGames count: \(upcomingGames.count)")
        print("myTeams count: \(myTeams.count)")
        print("recentActivity: \(recentActivity?.text ?? "nil")")
        
        // Reload table view and collection view
        upcomingTable.reloadData()
        teamsCollection.reloadData()
        
        // Update activity label
        activityLabel.text = recentActivity?.text ?? "No recent activity"
        
        print("Activity label text set to: \(activityLabel.text ?? "nil")")
    }
    
    private func instantiateFromMainStoryboard(withIdentifier id: String) -> UIViewController {
        // Assumes your storyboard file is named "Main.storyboard"
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: id)
    }
    
    // MARK: - Actions
    @objc private func didTapNotifications() {
        let requestsVC = RequestsViewController()
        let navController = UINavigationController(rootViewController: requestsVC)
        // modal presentation = slides up from the bottom
        present(navController, animated: true)
    }
    
    @objc private func tabTapped(_ sender: UIButton) {
        let newTab = sender.tag
        
        // home tab. only works from home for now
        if newTab == 0 {
            selectedDotViews[selectedTab].alpha = 0
            selectedTab = newTab
            selectedDotViews[selectedTab].alpha = 1
            return
        }
        
        let vcToPush: UIViewController
        
        switch newTab {
        case 1: // Teams
            performSegue(withIdentifier: "showTeamsSegue", sender: self)
            return
            
        case 2: // Schedule
            let scheduleVC = ScheduleViewController()
                    
            let navController = UINavigationController(rootViewController: scheduleVC)
            navController.modalPresentationStyle = .fullScreen
            
            present(navController, animated: true) {
                self.selectedDotViews[newTab].alpha = 0
                self.selectedTab = 0
                self.selectedDotViews[self.selectedTab].alpha = 1
            }
            // exit for special case
            return
            
        case 3: // Standings
            performSegue(withIdentifier: "showStandingsSegue", sender: self)
            return
            
        case 4: // Profile
            performSegue(withIdentifier: "showProfileSegue", sender: self)
            return
            
        default:
            // Should never happen
            return
        }
        
        // show new screen
        navigationController?.pushViewController(vcToPush, animated: true)
    }
    
    // MARK: - UITabBarDelegate
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let items = tabBar.items, let selectedIndex = items.firstIndex(of: item) else { return }
        
        // Handle tab selection based on index
        switch selectedIndex {
        case 0: // Home
            // Already on home, do nothing or scroll to top
            return
            
        case 1: // Teams
            performSegue(withIdentifier: "showTeamsSegue", sender: self)
            
        case 2: // Schedule
            let scheduleVC = ScheduleViewController()
            let navController = UINavigationController(rootViewController: scheduleVC)
            navController.modalPresentationStyle = .fullScreen
            present(navController, animated: true)
            
        case 3: // Standings
            performSegue(withIdentifier: "showStandingsSegue", sender: self)
            
        case 4: // Profile
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
            print("View Team tapped for: \(team.name)")
            // TODO: Navigate to team detail
        }
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension DashboardViewController: UICollectionViewDelegate {
    // Add delegate methods if needed (selection, highlighting, etc.)
}


//class DashboardViewController: UIViewController {
//
//
//    var user: User!  // User object passed from previous screen
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//       print("First name: \(user.firstName)")
//       print("Last name: \(user.lastName)")
//       print("Gender: \(user.gender)")
//       print("Email: \(user.email)")
//       print("Division: \(user.division ?? "none")")
//       print("Free Agent: \(user.isFreeAgent)")
//       print("Interested Sports: \(user.interestedSports.isEmpty ? "none" : user.interestedSports.joined(separator: ", "))")
//
//        // Do any additional setup after loading the view.
//    }
    

    /*
     MARK: - Navigation

     In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         Get the new view controller using segue.destination.
         Pass the selected object to the new view controller.
    }
    */

//}
