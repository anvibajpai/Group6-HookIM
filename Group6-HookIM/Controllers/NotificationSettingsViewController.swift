//
//  NotificationSettingsViewController.swift
//  Group6-HookIM
//
//  Created by Arnav Chopra on 11/11/25.
//

import UIKit
import UserNotifications

class NotificationSettingsViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var gameScheduleToggle: UISwitch!
    @IBOutlet weak var darkModeToggle: UISwitch!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var bottomBanner: UIView!
    
    // MARK: - Properties
    private var gameScheduleEnabled: Bool = true
    private var darkModeEnabled: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        loadSettings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkNotificationPermissions()
    }

    private func setupUI() {
        view.backgroundColor = .systemGray5
        contentView.backgroundColor = .systemGray5
        
        headerView.backgroundColor = UIColor(red: 156/255, green: 99/255, blue: 41/255, alpha: 1)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        
        titleLabel.text = "Notification Settings"
        titleLabel.textColor = .label
        titleLabel.font = .boldSystemFont(ofSize: 24)

        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = .label
        
        logoImageView.image = UIImage(systemName: "tortoise.fill")
        logoImageView.tintColor = .label
        logoImageView.contentMode = .scaleAspectFit
        
        // Save button
        saveButton.setTitle("Save", for: .normal)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.backgroundColor = .systemOrange
        saveButton.layer.cornerRadius = 8
        
        gameScheduleToggle.isOn = gameScheduleEnabled
        darkModeToggle.isOn = darkModeEnabled
        gameScheduleToggle.onTintColor = .systemOrange
        darkModeToggle.onTintColor = .systemOrange
        
        saveButton.setTitle("Save", for: .normal)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.backgroundColor = .systemOrange
        saveButton.layer.cornerRadius = 8
        saveButton.titleLabel?.font = .boldSystemFont(ofSize: 18)
        
        bottomBanner.backgroundColor = UIColor(red: 156/255, green: 99/255, blue: 41/255, alpha: 1)
        bottomBanner.translatesAutoresizingMaskIntoConstraints = false
        bottomBanner.heightAnchor.constraint(equalToConstant: 120).isActive = true
        bottomBanner.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    private func loadSettings() {
        gameScheduleEnabled = UserDefaults.standard.bool(forKey: "gameScheduleNotifications")
        if !UserDefaults.standard.bool(forKey: "gameScheduleNotificationsSet") {
            gameScheduleEnabled = true
        }
        
        darkModeEnabled = UserDefaults.standard.bool(forKey: "darkModeEnabled")
        if !UserDefaults.standard.bool(forKey: "darkModeEnabledSet") {
            darkModeEnabled = true
        }
        
        gameScheduleToggle.isOn = gameScheduleEnabled
        darkModeToggle.isOn = darkModeEnabled
    }
    
    // checks at the OS level to update value at the app level
    private func checkNotificationPermissions() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if settings.authorizationStatus == .denied {
                    self.gameScheduleToggle.isOn = false
                    self.gameScheduleToggle.isEnabled = false
                    
                    self.gameScheduleEnabled = false
                    UserDefaults.standard.set(false, forKey: "gameScheduleNotifications")
                    UserDefaults.standard.set(true, forKey: "gameScheduleNotificationsSet")
                    
                    self.showPermissionAlert()
                    
                } else {
                    self.gameScheduleToggle.isEnabled = true
                }
            }
        }
    }
    
    private func showPermissionAlert() {
        let alert = UIAlertController(title: "Notifications Disabled",
                                    message: "You have disabled notifications for this app. To use this feature, please go to your iPhone's Settings > HookIM > Notifications.",
                                    preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Actions
    @IBAction func backButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func gameScheduleToggleChanged(_ sender: UISwitch) {
        gameScheduleEnabled = sender.isOn
    }
    
    @IBAction func darkModeToggleChanged(_ sender: UISwitch) {
        darkModeEnabled = sender.isOn
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        // Save settings
        UserDefaults.standard.set(gameScheduleEnabled, forKey: "gameScheduleNotifications")
        UserDefaults.standard.set(true, forKey: "gameScheduleNotificationsSet")
        
        UserDefaults.standard.set(darkModeEnabled, forKey: "darkModeEnabled")
        UserDefaults.standard.set(true, forKey: "darkModeEnabledSet")
        
        if !gameScheduleEnabled {
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        } else {
            // we need the user to visit scheduleVC or calendarVC to automatically schedule notifs
        }
        
        if let windowScene = view.window?.windowScene {
            windowScene.windows.forEach { window in
                window.overrideUserInterfaceStyle = darkModeEnabled ? .dark : .light
            }
        }
        
        let alert = UIAlertController(title: "Settings Saved", message: "Your notification preferences have been saved.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }
}

