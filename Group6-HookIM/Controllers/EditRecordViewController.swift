import UIKit
import FirebaseFirestore

class EditRecordViewController: UIViewController {

    @IBOutlet weak var winsTextField: UITextField!
    @IBOutlet weak var lossesTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var timeTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var opponentButton: UIButton!
    
    var wins: Int = 0
    var losses: Int = 0
    
    //Passed in from CaptainTeamViewController
    var sport: String?
    var division: String?
    var currentTeamId: String?
    var currentTeamName: String?

    //Store opponent options
    private let db = Firestore.firestore()
    private var opponentTeams: [TeamLite] = []
    private var selectedOpponentId: String?
    
    struct TeamLite {
        let id: String
        let name: String
    }
    
    private let datePicker = UIDatePicker()
    private let timePicker = UIDatePicker()

    //Picker for dates
    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .none
        return df
    }()

    //Picker for times
    private let timeFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .none
        df.timeStyle = .short
        return df
    }()
    
    //Closure to send data back
    var onSave: ((Int, Int) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        winsTextField.text = "\(wins)"
        lossesTextField.text = "\(losses)"
        winsTextField.keyboardType = .numberPad
        lossesTextField.keyboardType = .numberPad
        
        //For dark mode
        winsTextField.backgroundColor = UIColor(named: "CardBackground")
        winsTextField.textColor = .label
        
        lossesTextField.backgroundColor = UIColor(named: "CardBackground")
        lossesTextField.textColor = .label
        
        dateTextField.backgroundColor = UIColor(named: "CardBackground")
        timeTextField.backgroundColor = UIColor(named: "CardBackground")
        locationTextField.backgroundColor = UIColor(named: "CardBackground")

        
        view.backgroundColor = UIColor(named: "AppBackground")
        
        styleOpponentButton()
        loadOpponentTeams()
        setupDateField()
        setupTimeField()
    }
    
    //Helper function for date picker
    private func setupDateField() {
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.minimumDate = Date()
        datePicker.addTarget(self,
                             action: #selector(dateChanged),
                             for: .valueChanged)

        dateTextField.inputView = datePicker
        dateTextField.inputAccessoryView = makeToolbar(doneSelector: #selector(doneWithDate))
    }

    //Helper function for time picker
    private func setupTimeField() {
        timePicker.datePickerMode = .time
        timePicker.preferredDatePickerStyle = .wheels
        timePicker.minuteInterval = 5
        timePicker.addTarget(self,
                             action: #selector(timeChanged),
                             for: .valueChanged)

        timeTextField.inputView = timePicker
        timeTextField.inputAccessoryView = makeToolbar(doneSelector: #selector(doneWithTime))
    }
    
    private func makeToolbar(doneSelector: Selector) -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: "Done", style: .done, target: self, action: doneSelector)
        toolbar.items = [flex, done]
        return toolbar
    }
    
    @objc private func dateChanged() {
        dateTextField.text = dateFormatter.string(from: datePicker.date)
    }

    @objc private func timeChanged() {
        timeTextField.text = timeFormatter.string(from: timePicker.date)
    }

    @objc private func doneWithDate() {
        if dateTextField.text?.isEmpty ?? true {
            dateChanged()
        }
        view.endEditing(true)
    }

    @objc private func doneWithTime() {
        if timeTextField.text?.isEmpty ?? true {
            timeChanged()
        }
        view.endEditing(true)
    }
    
    //Choosing opponents if they are in the same sport and division
    private func styleOpponentButton() {
        opponentButton.configuration = nil
        opponentButton.setTitle("Select Opponent", for: .normal)
        opponentButton.setTitleColor(.black, for: .normal)
        opponentButton.backgroundColor = .white
        opponentButton.layer.cornerRadius = 8
        opponentButton.layer.borderWidth = 1
        opponentButton.layer.borderColor = UIColor.systemGray4.cgColor
    }
    
    private func loadOpponentTeams() {
        guard let sport = sport,
        let division = division else { return }

        db.collection("teams")
            .whereField("sport", isEqualTo: sport)
            .whereField("division", isEqualTo: division)
            .getDocuments { [weak self] snap, err in
                guard let self = self else { return }
                if let err = err {
                    print("Opponent teams fetch error:", err)
                    return
                }

                let docs = snap?.documents ?? []
                self.opponentTeams = docs.compactMap { d in
                    //Skip current team so you don't play yourself
                    if d.documentID == self.currentTeamId { return nil }
                    let data = d.data()
                    guard let name = data["name"] as? String else { return nil }
                    return TeamLite(id: d.documentID, name: name)
                }.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
                self.buildOpponentMenu()
            }
    }
    
    //Builds drop down
    private func buildOpponentMenu() {
        guard !opponentTeams.isEmpty else {
            opponentButton.menu = nil
            opponentButton.showsMenuAsPrimaryAction = false
            opponentButton.setTitle("No opponents available", for: .normal)
            opponentButton.setTitleColor(.secondaryLabel, for: .normal)
            return
        }

        let actions = opponentTeams.map { team in
            UIAction(title: team.name) { [weak self] _ in
                self?.selectedOpponentId = team.id
                self?.opponentButton.setTitle(team.name, for: .normal)
            }
        }

        opponentButton.menu = UIMenu(title: "Select Opponent", children: actions)
        opponentButton.showsMenuAsPrimaryAction = true
    }
    
    //Alert for any missin data
    private func showSimpleAlert(title: String, message: String) {
        let a = UIAlertController(title: title, message: message, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "OK", style: .default))
        present(a, animated: true)
    }
    
    
    @IBAction func opponentButtonTapped(_ sender: Any) {
        if opponentTeams.isEmpty {
                showSimpleAlert(
                    title: "No Opponents Available",
                    message: "There are no other teams in this sport and division yet."
                )
            }
    }
    
    private func combinedGameDate() -> Date? {
        let calendar = Calendar.current
        let d = datePicker.date
        let t = timePicker.date

        var comps = calendar.dateComponents([.year, .month, .day], from: d)
        let timeComps = calendar.dateComponents([.hour, .minute, .second], from: t)
        comps.hour = timeComps.hour
        comps.minute = timeComps.minute
        comps.second = timeComps.second

        return calendar.date(from: comps)
    }
    
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        //Save wins and losses
        let newWins = Int(winsTextField.text ?? "") ?? wins
        let newLosses = Int(lossesTextField.text ?? "") ?? losses

        //Create next game
        let opponentChosen = (selectedOpponentId != nil)
        let location = (locationTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let dateStr  = (dateTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let timeStr  = (timeTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

        let hasLocation = !location.isEmpty
        let hasDate     = !dateStr.isEmpty
        let hasTime     = !timeStr.isEmpty

        let hasAnyNextGameField  = opponentChosen || hasLocation || hasDate || hasTime
        let hasAllNextGameFields = opponentChosen && hasLocation && hasDate && hasTime

        //If they don't fill in all fields then incomplete alert
        if hasAnyNextGameField && !hasAllNextGameFields {
            showSimpleAlert(
                title: "Incomplete Game Info",
                message: "To schedule a next game, please fill Opponent, Location, Date, and Time.\n\nOr clear all fields to skip setting a game."
            )
            return
        }

        //If all Next Game fields are filled, create a game document
        if hasAllNextGameFields {
            guard
                let gameDate = combinedGameDate(),
                let teamAId = currentTeamId,
                let teamAName = currentTeamName,
                let oppId = selectedOpponentId,
                let opp = opponentTeams.first(where: { $0.id == oppId })
            else {
                //Something is wrong with our data – bail safely
                showSimpleAlert(title: "Error", message: "Could not build game info. Please try again.")
                return
            }

            let gameData: [String: Any] = [
                "ldate": Timestamp(date: gameDate),
                "division": division ?? "",
                "location": location,
                "sport": sport ?? "",
                "status": "upcoming",
                "teamA_id": teamAId,
                "teamA_name": teamAName,
                "teamA_score": "0",
                "teamB_id": opp.id,
                "teamB_name": opp.name,
                "teamB_score": "0"
            ]

            db.collection("games").addDocument(data: gameData) { err in
                if let err = err {
                    print("Error creating game:", err)
                } else {
                    print("Next game created successfully")
                }
            }
        }

        //Update wins/losses in the parent VC
        onSave?(newWins, newLosses)

        //Pop back
        navigationController?.popViewController(animated: true)
    }

}
