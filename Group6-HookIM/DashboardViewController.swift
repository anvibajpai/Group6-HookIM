//
//  DashboardViewController.swift
//  Group6-HookIM
//
//  Created by Anvi Bajpai on 10/17/25.
//

import UIKit

class DashboardViewController: UIViewController {

    var user: User!  // User object passed from previous screen
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       print("First name: \(user.firstName)")
       print("Last name: \(user.lastName)")
       print("Gender: \(user.gender)")
       print("Email: \(user.email)")
       print("Division: \(user.division ?? "none")")
       print("Free Agent: \(user.isFreeAgent)")
       print("Interested Sports: \(user.interestedSports.isEmpty ? "none" : user.interestedSports.joined(separator: ", "))")

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
