import UIKit

class TeamCardCell: UICollectionViewCell {
    
    // MARK: - Properties
    var onViewTeamTapped: ((DashboardTeam) -> Void)?
    private var team: DashboardTeam?
    
    // MARK: - UI Elements
    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "CardBackground")
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 8
        view.layer.shadowOpacity = 0.2
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textColor = .label
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let sportLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let recordLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .label //this used to be blue, maybe make it diff than .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let standingLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nextGameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .tertiaryLabel
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let viewTeamButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("View Team", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(named: "WarmOrange")
        button.layer.cornerRadius = 8
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - Setup
    private func setupUI() {
        contentView.addSubview(cardView)
        cardView.addSubview(nameLabel)
        cardView.addSubview(sportLabel)
        cardView.addSubview(recordLabel)
        cardView.addSubview(standingLabel)
        cardView.addSubview(nextGameLabel)
        cardView.addSubview(viewTeamButton)
        
        viewTeamButton.addTarget(self, action: #selector(viewTeamButtonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            nameLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            
            sportLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            sportLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            sportLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            
            recordLabel.topAnchor.constraint(equalTo: sportLabel.bottomAnchor, constant: 8),
            recordLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            recordLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            
            standingLabel.topAnchor.constraint(equalTo: recordLabel.bottomAnchor, constant: 4),
            standingLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            standingLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            
            nextGameLabel.topAnchor.constraint(equalTo: standingLabel.bottomAnchor, constant: 8),
            nextGameLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            nextGameLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            
            viewTeamButton.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16),
            viewTeamButton.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            viewTeamButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            viewTeamButton.heightAnchor.constraint(equalToConstant: 32)
        ])
    }
    
    // MARK: - Configuration
    func configure(with team: DashboardTeam, dateFormatter: (Date) -> String) {
        self.team = team
        
        nameLabel.text = team.name
        sportLabel.text = team.sport
        recordLabel.text = team.record
        standingLabel.text = team.divisionStanding
        
        if let nextGame = team.nextGame {
            nextGameLabel.text = "Next: \(nextGame.opponent)\n\(dateFormatter(nextGame.date))"
        } else {
            nextGameLabel.text = "No upcoming games"
        }
    }
    
    // MARK: - Actions
    @objc private func viewTeamButtonTapped() {
        guard let team = team else { return }
        onViewTeamTapped?(team)
    }
}
