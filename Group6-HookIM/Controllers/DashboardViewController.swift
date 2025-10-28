//
//  DashboardViewController.swift
//  Group6-HookIM
//
//  Created by Anvi Bajpai on 10/17/25.
//

import UIKit

// MARK: - Color Helpers
extension UIColor {
    static let warmOrange = UIColor(red: 170/255, green: 82/255, blue: 30/255, alpha: 1)
    static let nearBlack   = UIColor(white: 0.06, alpha: 1)
    static let cardBG      = UIColor(white: 0.95, alpha: 1)
    static let softGray    = UIColor(white: 0.85, alpha: 1)
}

// MARK: - Team Card Cell (using external TeamCardCell class)


// MARK: - Dashboard VC
class DashboardViewController: UIViewController {
    
    var user: User!  // Provided by previous screen
    
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
        
        // Debug print user
        print("First name: \(user.firstName)")
        print("Last name: \(user.lastName)")
        print("Gender: \(user.gender)")
        print("Email: \(user.email)")
        print("Division: \(user.division ?? "none")")
        print("Free Agent: \(user.isFreeAgent)")
        print("Interested Sports: \(user.interestedSports.isEmpty ? "none" : user.interestedSports.joined(separator: ", "))")
        
        loadMockData()
        buildUI()
        layoutUI()
        populateData()
        
        // Debug: Check if outlets are connected
        print("upcomingGamesTitle: \(upcomingGamesTitle)")
        print("myTeamsTitle: \(myTeamsTitle)")
        print("recentActivityTitle: \(recentActivityTitle)")
        print("upcomingTable: \(upcomingTable)")
        print("teamsCollection: \(teamsCollection)")
        print("activityLabel: \(activityLabel)")
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
        teamsCollection.register(TeamCardCell.self, forCellWithReuseIdentifier: "TeamCardCellID")
        teamsCollection.backgroundColor = .clear
        teamsCollection.showsHorizontalScrollIndicator = false
        
        // Ensure section titles are visible
        upcomingGamesTitle.textColor = .white
        myTeamsTitle.textColor = .white
        recentActivityTitle.textColor = .white
        activityLabel.textColor = .white
        
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
        // Comment out programmatic layout since we're using storyboard constraints
        /*
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 18),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -18),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -36),
            
            // Header subviews
            bellButton.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 12),
            bellButton.centerYAnchor.constraint(equalTo: header.centerYAnchor),
            bellButton.widthAnchor.constraint(equalToConstant: 44),
            bellButton.heightAnchor.constraint(equalToConstant: 44),
            
            greetLabel.centerXAnchor.constraint(equalTo: header.centerXAnchor),
            greetLabel.centerYAnchor.constraint(equalTo: header.centerYAnchor),
            
            rightLogo.trailingAnchor.constraint(equalTo: header.trailingAnchor, constant: -16),
            rightLogo.centerYAnchor.constraint(equalTo: header.centerYAnchor),
            rightLogo.widthAnchor.constraint(equalToConstant: 36),
            rightLogo.heightAnchor.constraint(equalToConstant: 36),
            
            // Upcoming wrap pieces
            upcomingTitle.topAnchor.constraint(equalTo: (contentStack.arrangedSubviews[1]).topAnchor),
            upcomingTitle.leadingAnchor.constraint(equalTo: contentStack.leadingAnchor),
            
            upcomingCard.topAnchor.constraint(equalTo: upcomingTitle.bottomAnchor, constant: 8),
            upcomingCard.leadingAnchor.constraint(equalTo: contentStack.leadingAnchor),
            upcomingCard.trailingAnchor.constraint(equalTo: contentStack.trailingAnchor),
            upcomingCard.heightAnchor.constraint(equalToConstant: 200),
            
            upcomingTable.topAnchor.constraint(equalTo: upcomingCard.topAnchor, constant: 10),
            upcomingTable.leadingAnchor.constraint(equalTo: upcomingCard.leadingAnchor, constant: 10),
            upcomingTable.trailingAnchor.constraint(equalTo: upcomingCard.trailingAnchor, constant: -10),
            upcomingTable.bottomAnchor.constraint(equalTo: upcomingCard.bottomAnchor, constant: -10),
            
            // Teams collection height
            teamsCollection.heightAnchor.constraint(equalToConstant: 200),
            
            // Tab bar
            tabBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tabBarView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        */
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
            guard let teamVC = instantiateFromMainStoryboard(withIdentifier: "CaptainTeamViewController") as? CaptainTeamViewController else { return }
            vcToPush = teamVC
            
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
            guard let standingsVC = instantiateFromMainStoryboard(withIdentifier: "StandingsViewController") as? StandingsViewController else { return }
            vcToPush = standingsVC
            
        case 4: // Profile (placeholder)
            let placeholderVC = UIViewController()
            placeholderVC.view.backgroundColor = .systemBackground
            placeholderVC.title = "Profile"
            vcToPush = placeholderVC
            
        default:
            // Should never happen
            return
        }
        
        // show new screen
        navigationController?.pushViewController(vcToPush, animated: true)
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
