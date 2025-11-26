# **Group 6 - Hook ’IM**

## **Team Members**

* **Arnav Chopra**
* **Anvi Bajpai**
* **Ismael Ahmad**
* **Shriya Danam**

## **Project Name**

**Hook ’IM**

---

# **Dependencies**

* **Xcode:** 16+
* **Swift:** 5.9
* **iOS Deployment Target:** 16.0
* **Frameworks Used:**

  * Firebase Auth
  * Firebase Firestore
  * Firebase Storage
  * Photos / PhotosUI
  * UIKit
  * UICalendarView (iOS 16+)

### **Special Instructions**

* After cloning, run the project normally — **no pods needed**.
* You must enable Firebase for the following:

  * Authentication
  * Firestore Database
  * Firebase Storage
* Ensure your Firebase project contains:

  * `/users`
  * `/teams`
  * `/games`
  * `/invites`
  * `/images` (Storage)
* For image upload:

  * Ensure your **Info.plist** contains:

    * `NSCameraUsageDescription`
    * `NSPhotoLibraryUsageDescription`
* Works best on **iPhone 15 Pro / 14 Pro** or any 6.1" simulator.

---

# **Feature Table**

| **Feature Description**                                                      | **Release Planned** | **Release Actual** | **Deviations (if any)**                                         | **Who / % Worked On**                 |
| ---------------------------------------------------------------------------- | ------------------- | ------------------ | --------------------------------------------------------------- | ------------------------------------- |
| **Splash Page** – Loads app & routes user to login                           | Alpha               | Alpha              | None                                                            | Anvi (100%)                           |
| **Login + Create Account (name, gender, UT email, password)**                | Alpha               | Alpha              | Removed “Already have an account?” since back button was enough | Anvi (100%)                           |
| **Upload Image Page** – Take/upload profile pic & upload to Firebase Storage | Alpha               | Alpha              | Added Info.plist keys + improved styling                        | Anvi (100%)                           |
| **Sports Selection + Free Agent + Division Setup**                           | Alpha               | Alpha              | Added alerts for errors; more checks than originally planned    | Anvi (100%)                           |
| **Dashboard (upcoming games, team cards, activity feed)**                    | Beta                | Beta               | None                                                            | Ismael (100%)                         |
| **Bottom Navigation Bar on all core screens**                                | Alpha               | Alpha              | None                                                            | Ismael (100%)                         |
| **Notification Settings**                                                    | Beta                | Beta               | Simplified UI vs original design                                | Ismael (100%)                         |
| **Firebase Integration (users, games, invites, teams)**                      | Alpha–Final         | Alpha–Final        | Expanded schema from design doc                                 | Anvi (40%), Arnav (40%), Shriya (20%) |
| **Team Pages (Captain, Player, Viewer modes)**                               | Beta                | Beta               | Player/User View finishes in Final                              | Shriya (100%)                         |
| **Free Agent Board**                                                         | Beta                | Beta               | None                                                            | Shriya (100%)                         |
| **Create Team Page + Backend Logic**                                         | Alpha               | Alpha              | Updated design of + button                                      | Shriya (100%)                         |
| **Edit Team Page (wins/losses, add games)**                                  | Beta                | Beta               | None                                                            | Shriya (100%)                         |
| **Schedule Page (all upcoming games, sport filter)**                         | Alpha               | Alpha              | None                                                            | Arnav (100%)                          |
| **Calendar Page using UICalendarView**                                       | Beta                | Beta               | None                                                            | Arnav (100%)                          |
| **Native iOS Notifications for games**                                       | Final               | Final              | Replaced planned custom designs with iOS notifications          | Arnav (100%)                          |
| **Dark/Light Mode Toggle**                                                   | Beta                | Beta               | Moved Free Agent toggle to Profile & replaced with Dark Mode    | Arnav (100%)                          |
| **Invites Page (incoming/outgoing + acceptance)**                            | Beta                | Beta               | None                                                            | Arnav (100%)                          |
| **User Profile Page (edit all info, update Firebase, Free Agent toggle)**    | Beta                | Beta               | Added sign-out button                                           | Anvi (100%)                           |
| **Sign Out Functionality**                                                   | Beta                | Beta               | Added since missing from design doc                             | Anvi (100%)                           |
| **Standings Page (W/L/Pts)**                                                 | Final               | Final              | Uses test data                                                  | Anvi (100%)                           |


---

# **Contributions Summary**

### **Anvi Bajpai**

* Project setup + GitHub linking
* User class
* Splash Page
* Login & Create Account
* Upload Image
* Sports Selection & Free Agent setup
* Firebase integration (Auth, Firestore, Storage)
* Profile Page + updating user data
* Standings Page
* Sign out functionality

### **Ismael Ahmad**

* Dashboard UI (header, icons)
* Teams & upcoming games card on Dashboard
* Bottom navigation bar on all pages
* Notification settings
* Firebase integration for dashboard updates
* Team card → Team page linking

### **Arnav Chopra**

* Schedule page (filter by sport/league)
* Calendar page using UICalendarView
* Native iOS notifications
* Dark/light mode
* Notification toggles via UserDefaults
* Invites system (incoming/outgoing + Firebase updates)
* Firebase games/invites structs

### **Shriya Danam**

* Teams tab (selector + all views)
* Free Agent Board
* Editable roster for captains
* Edit Record page (wins/losses/games)
* Create Team page (front + backend)
* Firebase teams collection

---

# **Deviations from Design Document**

* Removed “Already have an account?” button since the back button provided the same functionality.
* First & last name on Create Account screen placed on separate lines for improved readability.
* Added more alerts on login and signup for user error handling.
* Player and User views for team pages initially delayed due to Beta conflicts; finished for Final.
* Based on the design document comments, we replaced the originally planned custom notification screens with iOS notifications. 
* Updated “Add Team” button design to better match iOS patterns.
* Added an in-app Sign Out button on Profile page, missing from initial design.
* Added full dark mode support.
