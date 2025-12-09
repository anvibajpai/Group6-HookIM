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

### **Instructions**

* After cloning, run the project normally — **no pods needed**.
* Enable Firebase for the following:

  * Authentication
  * Firestore Database
  * Firebase Storage
* Firebase project contains:

  * `/users`
  * `/teams`
  * `/games`
  * `/invites`
  * `/images` (Storage)
* For image upload:

  * Ensure **Info.plist** contains:

    * `NSCameraUsageDescription`
    * `NSPhotoLibraryUsageDescription`
* Works best on **iPhone 16 / 16 Pro** for constraints/UI purposes.
* To view an account with a fully populated Dashboard (upcoming games, etc.), log in using:
    * Email: 123@utexas.edu
    * Password: 123456


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
| **Settings Page**                                                    | Beta                | Beta               | Simplified UI vs original design                                | Arnav (95%, Anvi 5% UI)                         |
| **Firebase Integration (users, games, invites, teams)**                      | Alpha–Final         | Alpha–Final        | Expanded schema from design doc                                 | Anvi (33%), Arnav (33%), Shriya (33%) |
| **Team Pages (Captain, Player, Viewer modes)**                               | Beta                | Beta               | Player/User View finishes in Final                              | Shriya (100%)                         |
| **Free Agent Board**                                                         | Beta                | Beta               | None                                                            | Shriya (100%)                         |
| **Create Team Page + Backend Logic**                                         | Alpha               | Alpha              | Updated design of + button                                      | Shriya (100%)                         |
| **Edit Team Page (wins/losses, create new games)**                                  | Beta                | Beta               | In user mode, teams are view only. The only way to add people to a team is through the Free Agent Board                                                            | Shriya (100%)                         |
| **Schedule Page (all upcoming games, sport filter)**                         | Alpha               | Alpha              | None                                                            | Arnav (100%)                          |
| **Calendar Page using UICalendarView**                                       | Beta                | Beta               | None                                                            | Arnav (100%)                          |
| **Native iOS Notifications for games**                                       | Final               | Final              | Replaced planned custom designs with iOS notifications          | Arnav (100%)                          |
| **Dark/Light Mode Toggle**                                                   | Beta                | Beta               | Added Dark Mode option    | Arnav (100%)                          |
| **Invites Page (incoming/outgoing + acceptance)**                            | Beta                | Beta               | None                                                            | Arnav (100%)                          |
| **User Profile Page**    | Beta                | Beta               |  Edit all info, update Firebase, Free Agent toggle                                          | Anvi (100%)                           |
| **Sign Out Functionality**                                                   | Beta                | Beta               | Added since missing from design doc                             | Anvi (100%)                           |
| **Standings Page (W/L/Pts)**                                                 | Final               | Final              | Uses test data                                                  | Shriya (80%), Anvi (20% UI)                           |

