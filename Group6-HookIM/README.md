# Group 6 Hook IM

## Contributions
**Anvi Bajpai (25%)**
- Created and set up the project and linked it to GitHub.
- Implemented a User class to store user data.
- Built the Splash Page and Login Screen.
- Developed the Create Account screen.
- Created the Upload Image screen, including new Info.plist keys for permissions (NSCameraUsageDescription & NSPhotoLibraryUsageDescription) and integrated Photos and AVFoundation frameworks.
- Built the Sports Selection, Free Agent, and Division screen.
- Set up segues to the Dashboard ViewController, passing user data to the main page after login or account creation.
- Created the standings page with fake data for now.

**Ismael Ahmed (25%)**
- Made dashboard header and added icons 
- Made the upcoming games card in Dashboard screen 
- Made the navbar at the bottom with segues to relevant parts

**Arnav Chopra (25%)**
- created schedule page with all upcoming games. 
- included ability to filter by game
- created requests page to see incoming and outgoing join requests, as well as request history

**Shriya Danam (25%)**
- Implemented teams tab with captain view 
-Implemented free agent board. When a player gets clicked on an alert pops up 
-Implemented edit record to edit a teams wins and losses 
-Implemented add team 

## Deviations
- Decided not to have an "Already have an account? Login in" button since the back button allows users to navigate back to login screen
- For a cleaner look and allowing for longer names, first and last name text fields on Create account screen are wider and on separate lines
- Added alert messaages on each login and account creation screen for incorrect or incomplete inputs.
- Dashboard screen has certain deviations with the constraints so UI is still a bit sloppy, but the overall functionality is there
- Only have team view for the captain right now, will add player and user view later because there were last minute conflicts that prevented us from adding those changes.
- After looking at design comments, we will probably use iOS notifications instead of what we put in design to simplify screens a bit.
- changed appearance of the add team button to make it more intuitive 
-made schedule page a table view instead of calendar since had trouble with figuring out how to use the iOS calendar, will fix later
- Dashboard does not yet segue to calendar due to merge issues last minute.

