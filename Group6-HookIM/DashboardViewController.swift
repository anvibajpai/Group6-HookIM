//
//  DashboardViewController.swift
//  Group6-HookIM
//
//  Created by Anvi Bajpai on 10/17/25.
//

import UIKit
//
//
//// MARK: - Simple Models
struct Game {
    let team: String
    let opponent: String
    let location: String
    let time: String
}

struct TeamCard {
    let title: String
    let subtitle: String
    let record: String
    let divisionStanding: String
    let nextGame: String
}
//
//// MARK: - Color Helpers
extension UIColor {
    static let warmOrange = UIColor(red: 170/255, green: 82/255, blue: 30/255, alpha: 1)
    static let nearBlack   = UIColor(white: 0.06, alpha: 1)
    static let cardBG      = UIColor(white: 0.95, alpha: 1)
    static let softGray    = UIColor(white: 0.85, alpha: 1)
}
//
//// MARK: - Team Card Cell
final class TeamCardCell: UICollectionViewCell {
    static let reuseID = "TeamCardCell"

    let container = UIView()
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    let recordLabel = UILabel()
    let standingLabel = UILabel()
    let nextGameTitle = UILabel()
    let nextGameLabel = UILabel()
    let button = UIButton(type: .system)

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .clear
        build()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func build() {
        container.backgroundColor = .white
        container.layer.cornerRadius = 12
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOpacity = 0.15
        container.layer.shadowRadius = 4
        container.layer.shadowOffset = CGSize(width: 0, height: 2)

        [titleLabel, subtitleLabel, recordLabel, standingLabel, nextGameTitle, nextGameLabel, button].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview($0)
        }
        contentView.addSubview(container)
        container.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.numberOfLines = 2
        subtitleLabel.font = .systemFont(ofSize: 12)
        subtitleLabel.textColor = .gray

        recordLabel.font = .systemFont(ofSize: 20, weight: .bold)
        standingLabel.font = .systemFont(ofSize: 10)
        standingLabel.textColor = .gray

        nextGameTitle.font = .systemFont(ofSize: 12)
        nextGameTitle.textColor = .gray
        nextGameTitle.text = "Next Game"

        nextGameLabel.font = .systemFont(ofSize: 11, weight: .regular)
        nextGameLabel.numberOfLines = 2

        button.setTitle("View Team", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .warmOrange
        button.layer.cornerRadius = 8
        button.titleLabel?.font = .systemFont(ofSize: 12, weight: .semibold)

        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            container.topAnchor.constraint(equalTo: contentView.topAnchor),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            recordLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 12),
            recordLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),

            standingLabel.leadingAnchor.constraint(equalTo: recordLabel.leadingAnchor),
            standingLabel.topAnchor.constraint(equalTo: recordLabel.bottomAnchor, constant: 2),

            nextGameTitle.topAnchor.constraint(equalTo: standingLabel.bottomAnchor, constant: 12),
            nextGameTitle.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),

            nextGameLabel.topAnchor.constraint(equalTo: nextGameTitle.bottomAnchor, constant: 4),
            nextGameLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            nextGameLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            button.heightAnchor.constraint(equalToConstant: 36),
            button.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            button.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12)
        ])
    }

    func configure(_ m: TeamCard) {
        titleLabel.text = m.title
        subtitleLabel.text = m.subtitle
        recordLabel.text = m.record
        standingLabel.text = m.divisionStanding
        nextGameLabel.text = m.nextGame
    }
}

//// MARK: - Dashboard VC
//class DashboardViewController: UIViewController {
//
//    var user: User!  // Provided by previous screen
//
//    // Data (replace with your real models/service)
//    private let games: [Game] = [
//        .init(team: "Arch and Friends", opponent: "The Bevo Buddies", location: "Whittaker Fields", time: "October 8th, 7PM"),
//        .init(team: "The Dodge Fathers", opponent: "Spike it", location: "Gregory Gym", time: "October 12th, 6PM"),
//        .init(team: "The Dodge Fathers", opponent: "Batman", location: "Belmont Hall", time: "October 7th, 6PM")
//    ]
//    private let teams: [TeamCard] = [
//        .init(title: "The Dodge Fathers", subtitle: "Co-ed Dodgeball", record: "5W - 2L", divisionStanding: "3rd in Division", nextGame: "Today, 6PM vs Batman"),
//        .init(title: "Arch and Friends", subtitle: "Men's Flag Football", record: "3W - 2L", divisionStanding: "3rd in Division", nextGame: "Oct 8th, 7PM vs The Bevo Buddies"),
//        .init(title: "Arch & Friends (2)", subtitle: "Men's 6v6", record: "3W - 2L", divisionStanding: "2nd in Division", nextGame: "Oct 8th, 7PM")
//    ]
//
//    // Views
//    private let scrollView = UIScrollView()
//    private let contentStack = UIStackView()
//
//    private let header = UIView()
//    private let greetLabel = UILabel()
//    private let bellButton = UIButton(type: .system)
//    private let rightLogo = UIImageView()
//
//    private let upcomingContainer = UIView()
//    private let upcomingTitle = UILabel()
//    private let upcomingCard = UIView()
//    private let pillHeaderRow = UIStackView()
//    private let gameRowsStack = UIStackView()
//
//    private let teamsTitle = UILabel()
//    private var teamsCollection: UICollectionView!
//
//    private let recentTitle = UILabel()
//    private let recentLabel = UILabel()
//
//    private let tabBarView = UIView()
//    private let tabButtons: [UIButton] = (0..<5).map { _ in UIButton(type: .system) }
//    private let selectedDotViews: [UIView] = (0..<5).map { _ in UIView() }
//    private var selectedTab: Int = 2
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // Debug print user
//        print("First name: \(user.firstName)")
//        print("Last name: \(user.lastName)")
//        print("Gender: \(user.gender)")
//        print("Email: \(user.email)")
//        print("Division: \(user.division ?? "none")")
//        print("Free Agent: \(user.isFreeAgent)")
//        print("Interested Sports: \(user.interestedSports.isEmpty ? "none" : user.interestedSports.joined(separator: ", "))")
//
//        buildUI()
//        layoutUI()
//        populateData()
//    }
//
//    // MARK: - Build
//    private func buildUI() {
//        view.backgroundColor = .nearBlack
//        navigationController?.setNavigationBarHidden(true, animated: false)
//
//        // Scroll area
//        scrollView.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(scrollView)
//
//        contentStack.axis = .vertical
//        contentStack.spacing = 20
//        contentStack.translatesAutoresizingMaskIntoConstraints = false
//        scrollView.addSubview(contentStack)
//
//        // Header (orange)
//        header.backgroundColor = .warmOrange
//        header.translatesAutoresizingMaskIntoConstraints = false
//        header.heightAnchor.constraint(equalToConstant: 120).isActive = true
//
//        bellButton.setImage(UIImage(systemName: "bell"), for: .normal)
//        bellButton.tintColor = .white
//        bellButton.backgroundColor = UIColor(white: 0, alpha: 0.2)
//        bellButton.layer.cornerRadius = 10
//        bellButton.translatesAutoresizingMaskIntoConstraints = false
//
//        greetLabel.textColor = .white
//        greetLabel.font = .boldSystemFont(ofSize: 20)
//        greetLabel.translatesAutoresizingMaskIntoConstraints = false
//
//        rightLogo.image = UIImage(systemName: "tortoise.fill") // replace with your asset logo
//        rightLogo.tintColor = .white
//        rightLogo.contentMode = .scaleAspectFit
//        rightLogo.translatesAutoresizingMaskIntoConstraints = false
//
//        header.addSubview(bellButton)
//        header.addSubview(greetLabel)
//        header.addSubview(rightLogo)
//        contentStack.addArrangedSubview(header)
//
//        // Upcoming Games
//        let upWrap = UIView(); upWrap.translatesAutoresizingMaskIntoConstraints = false
//        upcomingTitle.text = "Upcoming Games"
//        upcomingTitle.textColor = .white
//        upcomingTitle.font = .boldSystemFont(ofSize: 17)
//
//        upcomingCard.backgroundColor = .cardBG
//        upcomingCard.layer.cornerRadius = 14
//        upcomingCard.layer.shadowOpacity = 0.15
//        upcomingCard.layer.shadowColor = UIColor.black.cgColor
//        upcomingCard.layer.shadowRadius = 4
//        upcomingCard.layer.shadowOffset = CGSize(width: 0, height: 2)
//        upcomingCard.translatesAutoresizingMaskIntoConstraints = false
//
//        // Pills header
//        pillHeaderRow.axis = .horizontal
//        pillHeaderRow.alignment = .fill
//        pillHeaderRow.distribution = .fillEqually
//        pillHeaderRow.spacing = 8
//        pillHeaderRow.translatesAutoresizingMaskIntoConstraints = false
//
//        // Rows stack
//        gameRowsStack.axis = .vertical
//        gameRowsStack.spacing = 8
//        gameRowsStack.translatesAutoresizingMaskIntoConstraints = false
//
//        upcomingCard.addSubview(pillHeaderRow)
//        upcomingCard.addSubview(gameRowsStack)
//
//        upWrap.addSubview(upcomingTitle)
//        upWrap.addSubview(upcomingCard)
//        contentStack.addArrangedSubview(upWrap)
//
//        // My Teams (horizontal collection)
//        teamsTitle.text = "My Teams"
//        teamsTitle.textColor = .white
//        teamsTitle.font = .boldSystemFont(ofSize: 17)
//
//        let layout = UICollectionViewFlowLayout()
//        layout.scrollDirection = .horizontal
//        layout.minimumLineSpacing = 14
//        layout.itemSize = CGSize(width: 240, height: 200)
//
//        teamsCollection = UICollectionView(frame: .zero, collectionViewLayout: layout)
//        teamsCollection.translatesAutoresizingMaskIntoConstraints = false
//        teamsCollection.backgroundColor = .clear
//        teamsCollection.showsHorizontalScrollIndicator = false
//        teamsCollection.register(TeamCardCell.self, forCellWithReuseIdentifier: TeamCardCell.reuseID)
//        teamsCollection.dataSource = self
//
//        let teamsWrap = UIStackView(arrangedSubviews: [teamsTitle, teamsCollection])
//        teamsWrap.axis = .vertical
//        teamsWrap.spacing = 12
//        teamsWrap.translatesAutoresizingMaskIntoConstraints = false
//        contentStack.addArrangedSubview(teamsWrap)
//
//        // Recent Activity
//        recentTitle.text = "Recent Activity"
//        recentTitle.textColor = .white
//        recentTitle.font = .boldSystemFont(ofSize: 17)
//
//        recentLabel.textColor = UIColor.white.withAlphaComponent(0.85)
//        recentLabel.numberOfLines = 0
//        recentLabel.font = .systemFont(ofSize: 14)
//        recentLabel.text = "You and the [Team Name] beat [Opponent Name] [Score]!"
//
//        let recentWrap = UIStackView(arrangedSubviews: [recentTitle, recentLabel])
//        recentWrap.axis = .vertical
//        recentWrap.spacing = 8
//        recentWrap.translatesAutoresizingMaskIntoConstraints = false
//        contentStack.addArrangedSubview(recentWrap)
//
//        // Spacer for tab bar
//        let spacer = UIView()
//        spacer.translatesAutoresizingMaskIntoConstraints = false
//        spacer.heightAnchor.constraint(equalToConstant: 70).isActive = true
//        contentStack.addArrangedSubview(spacer)
//
//        // Bottom Tab Bar
//        tabBarView.backgroundColor = .warmOrange
//        tabBarView.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(tabBarView)
//
//        let symbols = ["house.fill", "person.3.fill", "calendar", "rosette", "person.crop.circle"]
//        let stack = UIStackView()
//        stack.axis = .horizontal
//        stack.spacing = 0
//        stack.distribution = .equalSpacing
//        stack.translatesAutoresizingMaskIntoConstraints = false
//
//        tabBarView.addSubview(stack)
//
//        for i in 0..<5 {
//            let v = UIStackView()
//            v.axis = .vertical
//            v.alignment = .center
//            v.spacing = 4
//            v.translatesAutoresizingMaskIntoConstraints = false
//
//            selectedDotViews[i].backgroundColor = .white
//            selectedDotViews[i].layer.cornerRadius = 3
//            selectedDotViews[i].translatesAutoresizingMaskIntoConstraints = false
//            selectedDotViews[i].heightAnchor.constraint(equalToConstant: 6).isActive = true
//            selectedDotViews[i].widthAnchor.constraint(equalToConstant: 6).isActive = true
//            selectedDotViews[i].alpha = (i == selectedTab) ? 1 : 0
//
//            tabButtons[i].setImage(UIImage(systemName: symbols[i]), for: .normal)
//            tabButtons[i].tintColor = .white
//            tabButtons[i].tag = i
//            tabButtons[i].addTarget(self, action: #selector(tabTapped(_:)), for: .touchUpInside)
//
//            v.addArrangedSubview(selectedDotViews[i])
//            v.addArrangedSubview(tabButtons[i])
//            stack.addArrangedSubview(v)
//        }
//
//        // Constraints for tab bar inner stack
//        NSLayoutConstraint.activate([
//            stack.leadingAnchor.constraint(equalTo: tabBarView.leadingAnchor, constant: 28),
//            stack.trailingAnchor.constraint(equalTo: tabBarView.trailingAnchor, constant: -28),
//            stack.topAnchor.constraint(equalTo: tabBarView.topAnchor, constant: 6),
//            stack.bottomAnchor.constraint(equalTo: tabBarView.bottomAnchor, constant: -10)
//        ])
//    }
//
//    // MARK: - Layout
//    private func layoutUI() {
//        NSLayoutConstraint.activate([
//            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//
//            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10),
//            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 18),
//            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -18),
//            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
//            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -36),
//
//            // Header subviews
//            bellButton.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 12),
//            bellButton.centerYAnchor.constraint(equalTo: header.centerYAnchor),
//            bellButton.widthAnchor.constraint(equalToConstant: 44),
//            bellButton.heightAnchor.constraint(equalToConstant: 44),
//
//            greetLabel.centerXAnchor.constraint(equalTo: header.centerXAnchor),
//            greetLabel.centerYAnchor.constraint(equalTo: header.centerYAnchor),
//
//            rightLogo.trailingAnchor.constraint(equalTo: header.trailingAnchor, constant: -16),
//            rightLogo.centerYAnchor.constraint(equalTo: header.centerYAnchor),
//            rightLogo.widthAnchor.constraint(equalToConstant: 36),
//            rightLogo.heightAnchor.constraint(equalToConstant: 36),
//
//            // Upcoming wrap pieces
//            upcomingTitle.topAnchor.constraint(equalTo: (contentStack.arrangedSubviews[1]).topAnchor),
//            upcomingTitle.leadingAnchor.constraint(equalTo: contentStack.leadingAnchor),
//
//            upcomingCard.topAnchor.constraint(equalTo: upcomingTitle.bottomAnchor, constant: 8),
//            upcomingCard.leadingAnchor.constraint(equalTo: contentStack.leadingAnchor),
//            upcomingCard.trailingAnchor.constraint(equalTo: contentStack.trailingAnchor),
//
//            pillHeaderRow.topAnchor.constraint(equalTo: upcomingCard.topAnchor, constant: 12),
//            pillHeaderRow.leadingAnchor.constraint(equalTo: upcomingCard.leadingAnchor, constant: 12),
//            pillHeaderRow.trailingAnchor.constraint(equalTo: upcomingCard.trailingAnchor, constant: -12),
//
//            gameRowsStack.topAnchor.constraint(equalTo: pillHeaderRow.bottomAnchor, constant: 10),
//            gameRowsStack.leadingAnchor.constraint(equalTo: upcomingCard.leadingAnchor, constant: 10),
//            gameRowsStack.trailingAnchor.constraint(equalTo: upcomingCard.trailingAnchor, constant: -10),
//            gameRowsStack.bottomAnchor.constraint(equalTo: upcomingCard.bottomAnchor, constant: -12),
//
//            // Teams collection height
//            teamsCollection.heightAnchor.constraint(equalToConstant: 200),
//
//            // Tab bar
//            tabBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            tabBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            tabBarView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
//        ])
//    }
//
//    // MARK: - Populate
//    private func populateData() {
//        greetLabel.text = "Hi, \(user.firstName)!"
//
//        // Header pill labels
//        ["Team","Opponent","Location","Time"].forEach { title in
//            pillHeaderRow.addArrangedSubview(makeHeaderPill(title))
//        }
//
//        // Rows
//        games.forEach { g in
//            let row = UIStackView()
//            row.axis = .horizontal
//            row.spacing = 8
//            row.distribution = .fillEqually
//
//            row.addArrangedSubview(makeRowPill(g.team))
//            row.addArrangedSubview(makeRowPill(g.opponent))
//            row.addArrangedSubview(makeRowPill(g.location))
//            row.addArrangedSubview(makeRowPill(g.time))
//
//            gameRowsStack.addArrangedSubview(row)
//        }
//    }
//
//    // MARK: - Builders
//    private func makeHeaderPill(_ text: String) -> UIView {
//        let l = UILabel()
//        l.text = text
//        l.textAlignment = .center
//        l.font = .systemFont(ofSize: 12, weight: .semibold)
//        l.textColor = .black
//        let bg = UIView()
//        bg.backgroundColor = .white
//        bg.layer.cornerRadius = 16
//        bg.layer.borderColor = UIColor.softGray.cgColor
//        bg.layer.borderWidth = 1
//        bg.translatesAutoresizingMaskIntoConstraints = false
//        l.translatesAutoresizingMaskIntoConstraints = false
//        bg.addSubview(l)
//        NSLayoutConstraint.activate([
//            l.topAnchor.constraint(equalTo: bg.topAnchor, constant: 6),
//            l.bottomAnchor.constraint(equalTo: bg.bottomAnchor, constant: -6),
//            l.leadingAnchor.constraint(equalTo: bg.leadingAnchor, constant: 8),
//            l.trailingAnchor.constraint(equalTo: bg.trailingAnchor, constant: -8),
//            bg.heightAnchor.constraint(greaterThanOrEqualToConstant: 30)
//        ])
//        return bg
//    }
//
//    private func makeRowPill(_ text: String) -> UIView {
//        let l = UILabel()
//        l.text = text
//        l.font = .systemFont(ofSize: 13)
//        l.textColor = .black
//        l.numberOfLines = 2
//
//        let bg = UIView()
//        bg.backgroundColor = .white
//        bg.layer.cornerRadius = 8
//        bg.layer.borderColor = UIColor.softGray.cgColor
//        bg.layer.borderWidth = 1
//        bg.translatesAutoresizingMaskIntoConstraints = false
//        l.translatesAutoresizingMaskIntoConstraints = false
//        bg.addSubview(l)
//        NSLayoutConstraint.activate([
//            l.topAnchor.constraint(equalTo: bg.topAnchor, constant: 8),
//            l.bottomAnchor.constraint(equalTo: bg.bottomAnchor, constant: -8),
//            l.leadingAnchor.constraint(equalTo: bg.leadingAnchor, constant: 8),
//            l.trailingAnchor.constraint(equalTo: bg.trailingAnchor, constant: -8),
//            bg.heightAnchor.constraint(greaterThanOrEqualToConstant: 36)
//        ])
//        return bg
//    }
//
//    // MARK: - Actions
//    @objc private func tabTapped(_ sender: UIButton) {
//        selectedDotViews[selectedTab].alpha = 0
//        selectedTab = sender.tag
//        selectedDotViews[selectedTab].alpha = 1
//        // TODO: hook up real navigation if needed
//    }
//}
//
//// MARK: - Collection View DataSource
//extension DashboardViewController: UICollectionViewDataSource {
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        teams.count
//    }
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TeamCardCell.reuseID, for: indexPath) as! TeamCardCell
//        cell.configure(teams[indexPath.item])
//        return cell
//    }
//}


class DashboardViewController: UIViewController {
    
    var user: User!  // Provided by previous screen
    
    private let games: [Game] = [
        .init(team: "Arch and Friends", opponent: "The Bevo Buddies", location: "Whittaker Fields", time: "October 8th, 7PM"),
        .init(team: "The Dodge Fathers", opponent: "Spike it", location: "Gregory Gym", time: "October 12th, 6PM"),
        .init(team: "The Dodge Fathers", opponent: "Batman", location: "Belmont Hall", time: "October 7th, 6PM")
    ]
    private let teams: [TeamCard] = [
        .init(title: "The Dodge Fathers", subtitle: "Co-ed Dodgeball", record: "5W - 2L", divisionStanding: "3rd in Division", nextGame: "Today, 6PM vs Batman"),
        .init(title: "Arch and Friends", subtitle: "Men's Flag Football", record: "3W - 2L", divisionStanding: "3rd in Division", nextGame: "Oct 8th, 7PM vs The Bevo Buddies"),
        .init(title: "Arch & Friends (2)", subtitle: "Men's 6v6", record: "3W - 2L", divisionStanding: "2nd in Division", nextGame: "Oct 8th, 7PM")
    ]
    
    // Views
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    
    private let header = UIView()
    private let greetLabel = UILabel()
    private let bellButton = UIButton(type: .system)
    private let rightLogo = UIImageView()
    
    private let upcomingContainer = UIView()
    private let upcomingTitle = UILabel()
    private let upcomingCard = UIView()
    private let pillHeaderRow = UIStackView()
    private let gameRowsStack = UIStackView()
    
    private let teamsTitle = UILabel()
    private var teamsCollection: UICollectionView!
    
    private let recentTitle = UILabel()
    private let recentLabel = UILabel()
    
    private let tabBarView = UIView()
    private let tabButtons: [UIButton] = (0..<5).map { _ in UIButton(type: .system) }
    private let selectedDotViews: [UIView] = (0..<5).map { _ in UIView() }
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
        
        buildUI()
        layoutUI()
        populateData()
    }
    
    // MARK: - Build
    private func buildUI() {
        view.backgroundColor = .black
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        // Scroll area
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        contentStack.axis = .vertical
        contentStack.spacing = 20
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)
        
        // Header (orange)
        header.backgroundColor = .orange
        header.translatesAutoresizingMaskIntoConstraints = false
        header.heightAnchor.constraint(equalToConstant: 120).isActive = true
        
        bellButton.setImage(UIImage(systemName: "bell"), for: .normal)
        bellButton.tintColor = .white
        bellButton.backgroundColor = UIColor(white: 0, alpha: 0.2)
        bellButton.layer.cornerRadius = 10
        bellButton.translatesAutoresizingMaskIntoConstraints = false
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
        
        // Pills header
        pillHeaderRow.axis = .horizontal
        pillHeaderRow.alignment = .fill
        pillHeaderRow.distribution = .fillEqually
        pillHeaderRow.spacing = 8
        pillHeaderRow.translatesAutoresizingMaskIntoConstraints = false
        
        // Rows stack
        gameRowsStack.axis = .vertical
        gameRowsStack.spacing = 8
        gameRowsStack.translatesAutoresizingMaskIntoConstraints = false
        
        upcomingCard.addSubview(pillHeaderRow)
        upcomingCard.addSubview(gameRowsStack)
        
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
        teamsCollection.register(TeamCardCell.self, forCellWithReuseIdentifier: TeamCardCell.reuseID)
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
        recentLabel.text = "You and the [Team Name] beat [Opponent Name] [Score]!"
        
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
    }
    
    // MARK: - Layout
    private func layoutUI() {
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
            
            pillHeaderRow.topAnchor.constraint(equalTo: upcomingCard.topAnchor, constant: 12),
            pillHeaderRow.leadingAnchor.constraint(equalTo: upcomingCard.leadingAnchor, constant: 12),
            pillHeaderRow.trailingAnchor.constraint(equalTo: upcomingCard.trailingAnchor, constant: -12),
            
            gameRowsStack.topAnchor.constraint(equalTo: pillHeaderRow.bottomAnchor, constant: 10),
            gameRowsStack.leadingAnchor.constraint(equalTo: upcomingCard.leadingAnchor, constant: 10),
            gameRowsStack.trailingAnchor.constraint(equalTo: upcomingCard.trailingAnchor, constant: -10),
            gameRowsStack.bottomAnchor.constraint(equalTo: upcomingCard.bottomAnchor, constant: -12),
            
            // Teams collection height
            teamsCollection.heightAnchor.constraint(equalToConstant: 200),
            
            // Tab bar
            tabBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tabBarView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    // MARK: - Populate
    private func populateData() {
        greetLabel.text = "Hi, \(user.firstName)!"
        
        // Header pill labels
        ["Team","Opponent","Location","Time"].forEach { title in
            pillHeaderRow.addArrangedSubview(makeHeaderPill(title))
        }
        
        // Rows
        games.forEach { g in
            let row = UIStackView()
            row.axis = .horizontal
            row.spacing = 8
            row.distribution = .fillEqually
            
            row.addArrangedSubview(makeRowPill(g.team))
            row.addArrangedSubview(makeRowPill(g.opponent))
            row.addArrangedSubview(makeRowPill(g.location))
            row.addArrangedSubview(makeRowPill(g.time))
            
            gameRowsStack.addArrangedSubview(row)
        }
    }
    
    // MARK: - Builders
    private func makeHeaderPill(_ text: String) -> UIView {
        let l = UILabel()
        l.text = text
        l.textAlignment = .center
        l.font = .systemFont(ofSize: 12, weight: .semibold)
        l.textColor = .black
        let bg = UIView()
        bg.backgroundColor = .white
        bg.layer.cornerRadius = 16
        bg.layer.borderColor = UIColor.softGray.cgColor
        bg.layer.borderWidth = 1
        bg.translatesAutoresizingMaskIntoConstraints = false
        l.translatesAutoresizingMaskIntoConstraints = false
        bg.addSubview(l)
        NSLayoutConstraint.activate([
            l.topAnchor.constraint(equalTo: bg.topAnchor, constant: 6),
            l.bottomAnchor.constraint(equalTo: bg.bottomAnchor, constant: -6),
            l.leadingAnchor.constraint(equalTo: bg.leadingAnchor, constant: 8),
            l.trailingAnchor.constraint(equalTo: bg.trailingAnchor, constant: -8),
            bg.heightAnchor.constraint(greaterThanOrEqualToConstant: 30)
        ])
        return bg
    }
    
    private func makeRowPill(_ text: String) -> UIView {
        let l = UILabel()
        l.text = text
        l.font = .systemFont(ofSize: 13)
        l.textColor = .black
        l.numberOfLines = 2
        
        let bg = UIView()
        bg.backgroundColor = .white
        bg.layer.cornerRadius = 8
        bg.layer.borderColor = UIColor.softGray.cgColor
        bg.layer.borderWidth = 1
        bg.translatesAutoresizingMaskIntoConstraints = false
        l.translatesAutoresizingMaskIntoConstraints = false
        bg.addSubview(l)
        NSLayoutConstraint.activate([
            l.topAnchor.constraint(equalTo: bg.topAnchor, constant: 8),
            l.bottomAnchor.constraint(equalTo: bg.bottomAnchor, constant: -8),
            l.leadingAnchor.constraint(equalTo: bg.leadingAnchor, constant: 8),
            l.trailingAnchor.constraint(equalTo: bg.trailingAnchor, constant: -8),
            bg.heightAnchor.constraint(greaterThanOrEqualToConstant: 36)
        ])
        return bg
    }
    
    // MARK: - Actions
    
    @objc private func tabTapped(_ sender: UIButton) {
        let newTab = sender.tag

        // do nothing
        if newTab == 0 {
            selectedDotViews[selectedTab].alpha = 0
            selectedTab = 0
            selectedDotViews[selectedTab].alpha = 1
            return
        }

        if newTab == 2 { // schedule
            let scheduleVC = ScheduleViewController()
            let navController = UINavigationController(rootViewController: scheduleVC)
            navController.modalPresentationStyle = .fullScreen

            // show schedule
            present(navController, animated: true) {
                // reset dashboard back to "Home" so that home shows up on dismissak
                self.selectedDotViews[newTab].alpha = 0
                self.selectedTab = 0
                self.selectedDotViews[self.selectedTab].alpha = 1
            }
        } else {
            // temp for adding other tabs
            print("Tapped tab index \(newTab)")
        }
    }
    
//    @objc private func tabTapped(_ sender: UIButton) {
//        selectedDotViews[selectedTab].alpha = 0
//        selectedTab = sender.tag
//        selectedDotViews[selectedTab].alpha = 1
//        // TODO: hook up real navigation if needed
//    }
    
    // MARK: - Actions

    @objc private func didTapNotifications() {
        let requestsVC = RequestsViewController()
        let navController = UINavigationController(rootViewController: requestsVC)
        // modal presentation = slides up from the bottom
        present(navController, animated: true)
    }
}

// MARK: - Collection View DataSource
extension DashboardViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        teams.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TeamCardCell.reuseID, for: indexPath) as! TeamCardCell
        cell.configure(teams[indexPath.item])
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


