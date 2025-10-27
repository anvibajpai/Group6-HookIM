//
//  RequestsViewController.swift
//  Group6-HookIM
//
//  Created by Arnav Chopra on 10/21/25.
//

// RequestsViewController.swift
import UIKit

class RequestsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // dummy data for each section
    private var incomingRequests: [PendingRequest] = [
        PendingRequest(requestingUser: "Anvi", teamName: "The Champs", type: .teamInvite),
        PendingRequest(requestingUser: "Ismael", teamName: "Bevo Ballers", type: .playerRequest)
    ]
    
    private var outgoingRequests: [OutgoingRequest] = [
        OutgoingRequest(recipient: "Shriya", teamName: "The Dodge Fathers", status: .pending),
        OutgoingRequest(recipient: "Arnav", teamName: "Spike It", status: .accepted)
    ]
    
    private var historyItems: [RequestHistoryItem] = [
        RequestHistoryItem(message: "You accepted an invite to 'The Dodge Fathers'.", date: Date().addingTimeInterval(-86400)), // 1 day ago
        RequestHistoryItem(message: "Your request for 'Ismael' to join 'Bevo Ballers' was declined.", date: Date().addingTimeInterval(-172800)) // 2 days ago
    ]
    
    private var currentDataSource: [Any] = []

    private let segmentedControl: UISegmentedControl = {
        let items = ["Incoming", "Outgoing", "History"]
        let control = UISegmentedControl(items: items)
        control.selectedSegmentIndex = 0
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "requestCell")
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Requests"
        view.backgroundColor = .systemBackground
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didTapDone))
        
        segmentedControl.addTarget(self, action: #selector(didChangeSegment), for: .valueChanged)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        view.addSubview(segmentedControl)
        view.addSubview(tableView)
        setupConstraints()
        
        updateDataSource()
    }

    // MARK: - UI Setup
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            tableView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: - Logic
    @objc private func didTapDone() {
        dismiss(animated: true)
    }
    
    @objc private func didChangeSegment() {
        updateDataSource()
    }
    
    private func updateDataSource() {
        switch segmentedControl.selectedSegmentIndex {
        case 0: // Incoming
            currentDataSource = incomingRequests
        case 1: // Outgoing
            currentDataSource = outgoingRequests
        case 2: // History
            currentDataSource = historyItems
        default:
            currentDataSource = []
        }
        tableView.reloadData()
    }
    
    // MARK: - UITableView DataSource & Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentDataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "requestCell")
        cell.textLabel?.font = .systemFont(ofSize: 16)
        cell.detailTextLabel?.font = .systemFont(ofSize: 12)
        cell.detailTextLabel?.textColor = .gray
        
        let item = currentDataSource[indexPath.row]
        
        if let request = item as? PendingRequest {
            cell.textLabel?.text = request.message
            // indicates tapability
            cell.accessoryType = .disclosureIndicator
        } else if let request = item as? OutgoingRequest {
            cell.textLabel?.text = request.message
            cell.detailTextLabel?.text = "Status: \(request.status.rawValue)"
            cell.selectionStyle = .none
        } else if let history = item as? RequestHistoryItem {
            cell.textLabel?.text = history.message
            cell.detailTextLabel?.text = history.dateString
            cell.selectionStyle = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // disallow tapping an outgoing
        // TODO: add cancellation
        guard segmentedControl.selectedSegmentIndex == 0,
              let request = currentDataSource[indexPath.row] as? PendingRequest else {
            return
        }
        
        
        let alert = UIAlertController(title: "Respond to Request", message: request.message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Accept", style: .default, handler: { _ in
            // TODO: firebase call here
            self.incomingRequests.remove(at: indexPath.row)
            self.updateDataSource()
        }))
        alert.addAction(UIAlertAction(title: "Reject", style: .destructive, handler: { _ in
            self.incomingRequests.remove(at: indexPath.row)
            self.updateDataSource()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
}
