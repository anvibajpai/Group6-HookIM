//
//  GameScheduleTableViewCell.swift
//  Group6-HookIM
//
//  Created by Arnav Chopra on 10/21/25.
//

// GameScheduleTableViewCell.swift
import UIKit

class GameScheduleTableViewCell: UITableViewCell {

    static let identifier = "GameScheduleTableViewCell"

    let teamNamesLabel = UILabel()
    let scoreLabel = UILabel()
    let timeLabel = UILabel()
    let locationLabel = UILabel()

    func configure(with game: LeagueGame) {
        teamNamesLabel.text = "\(game.teamA) vs \(game.teamB)"
        scoreLabel.text = game.scoreDisplay
        timeLabel.text = game.timeDisplay
        locationLabel.text = game.location

        teamNamesLabel.font = .systemFont(ofSize: 16, weight: .bold)
        scoreLabel.font = .systemFont(ofSize: 16, weight: .bold)
        timeLabel.font = .systemFont(ofSize: 14)
        locationLabel.font = .systemFont(ofSize: 14)
        scoreLabel.textAlignment = .right
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(teamNamesLabel)
        contentView.addSubview(scoreLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(locationLabel)

        // position the labels
        teamNamesLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        locationLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            teamNamesLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            teamNamesLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),

            scoreLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            scoreLabel.leadingAnchor.constraint(equalTo: teamNamesLabel.trailingAnchor, constant: 8),
            scoreLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            scoreLabel.widthAnchor.constraint(equalToConstant: 80),

            timeLabel.topAnchor.constraint(equalTo: teamNamesLabel.bottomAnchor, constant: 6),
            timeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            timeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),

            locationLabel.topAnchor.constraint(equalTo: timeLabel.topAnchor),
            locationLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
