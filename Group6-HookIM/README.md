# Group 6 Hook IM

## Contributions
**Anvi Bajpai (25% alpha, 25% beta)**
- Created and set up the project and linked it to GitHub.
- Implemented a User class to store user data.
- Built the Splash Page and Login Screen.
- Developed the Create Account screen.
- Created the Upload Image screen, including new Info.plist keys for permissions (NSCameraUsageDescription & NSPhotoLibraryUsageDescription) and integrated Photos and AVFoundation frameworks.
- Built the Sports Selection, Free Agent, and Division screen.
- Set up segues to the Dashboard ViewController, passing user data to the main page after login or account creation.
- Created the standings page with fake data.
- Set up Firebase integration for the project, including Firestore and Storage databases.
- Implemented email/password authentication for both login and account creation flows.
- Added sign-out functionality on the user profile page.
- Connected profile creation to backend so that user-selected data (such as name, gender, sports, and free-agent status) is stored in the Firestore database during account creation.
- Created a Firebase Storage database to handle user profile image uploads.
- Linked profile updates so that changes made on the User Profile page automatically update the corresponding user data in Firebase.

**Ismael Ahmed (25% alpha, 25% beta)**
- Made dashboard header and added icons 
- Made the upcoming games card in Dashboard screen 
- Made the navbar at the bottom with segues to relevant parts
- Made the navbar present on the other pages as well for easier navigation and connected necessary segues
- Made the notification settings page 
- Implemented upcoming games and teams card to show all games and teams even if the viewer isn't in a team 
- Made dashboard pull from firebase database so it can update whenever there is a new user and new game that is put into the schedule
- Connected the teams cards to connect to the specific teams page whenever the "view teams" button is clicked

**Arnav Chopra (25% alpha, 25% beta)**
- Created schedule page with all upcoming games. 
- Included ability to filter by league and sport type.
- Created calendar page to visualize all upcoming games using iOS 16+ UICalendarView.
- Implemented native iOS notifications for upcoming games.
- Implemented dark/light mode throughout the app.
- Implemented toggling ability for notifications and dark mode using UserDefaults.
- Created 'games' and 'invites' struct in Firebase to support these functionalities.
- Added in-app team invite page to display incoming/outgoing invites as well as history. Also linked this with the 'teams' database to update a team when an invite is accepted.

**Shriya Danam (25% alpha, 25% beta)**
- Implemented teams tab with a team selector for all teams 
- Implemented dual functionality. If a user is a part of a team, then they will be able to see all add functionality. If they are not, they will not and all segues will be blocked. 
- Implemented free agent board. When a player gets clicked on an alert pops up and they get added to the roster. 
- Implemented viewable roster on teams tab for any team 
- Implemented edit record to edit a teams wins and losses and add games 
- Implemented add team on front and backend 
- Created and implemented 'teams' collection in Firebase to support the above 

## Deviations
- Decided not to have an "Already have an account? Login in" button since the back button allows users to navigate back to login screen
- For a cleaner look and allowing for longer names, first and last name text fields on Create account screen are wider and on separate lines
- Added alert messages on each login and account creation screen for incorrect or incomplete inputs.
- Only have team view for the captain right now, will add player and user view later because there were last minute conflicts that prevented us from adding those changes.
- After looking at design comments, we will probably use iOS notifications instead of what we put in design to simplify screens a bit.
- Changed appearance of the add team button to make it more intuitive 
- Sign out button on profile page is a deviation from our original design, since we initially forgot to include this feature.
- We initially had 'Free Agent' status as a togglable feature, we decided to move this to User profile and add dark mode as a togglable feature.

