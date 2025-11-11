//
//  NotificationSettingsViewController.swift
//  Group6-HookIM
//
//  Created on 11/25/25.
//

import UIKit

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
    
    private func setupUI() {
        view.backgroundColor = UIColor(named: "Charcoal")
        
       
        headerView.backgroundColor = UIColor(red: 0.611764729, green: 0.3882353008, blue: 0.1607843041, alpha: 1)
        
        titleLabel.text = "Notification Settings"
        titleLabel.textColor = .label
        titleLabel.font = .boldSystemFont(ofSize: 24)
        
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = .white
        
        logoImageView.image = UIImage(systemName: "tortoise.fill")
        logoImageView.tintColor = .white
        logoImageView.contentMode = .scaleAspectFit
        
        contentView.backgroundColor = UIColor(named: "Charcoal")
        
        gameScheduleToggle.isOn = gameScheduleEnabled
        darkModeToggle.isOn = darkModeEnabled
        
        if let orangeColor = UIColor(named: "BurntOrange") {
            gameScheduleToggle.onTintColor = orangeColor
            darkModeToggle.onTintColor = orangeColor
        }
        
        saveButton.setTitle("Save", for: .normal)
        saveButton.setTitleColor(.white, for: .normal)
        if let orangeColor = UIColor(named: "BurntOrange") {
            saveButton.backgroundColor = orangeColor
        }
        saveButton.layer.cornerRadius = 8
        saveButton.titleLabel?.font = .boldSystemFont(ofSize: 18)
        
        bottomBanner.backgroundColor = UIColor(red: 0.7490196078, green: 0.3411764706, blue: 0.0, alpha: 0.7)
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

