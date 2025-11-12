import Foundation
import FirebaseFirestore

// MARK: - Data Models

struct DashboardUser {
    let name: String
    let teams: [DashboardTeam]
}

struct DashboardTeam {
    let id: UUID = UUID()
    let name: String
    let sport: String
    let record: String
    let divisionStanding: String
    let nextGame: Game?
}

struct Game {
    let id: String
    
    let team: String
    let opponent: String
    let location: String
    let date: Date
    let sport: String
    let division: String
    
    // read these values in from firebase w error handling
    init?(dictionary: [String: Any], id: String) {
        guard let date = (dictionary["date"] as? Timestamp)?.dateValue(),
              let location = dictionary["location"] as? String,
              let teamAName = dictionary["teamA_name"] as? String,
              let teamBName = dictionary["teamB_name"] as? String,
              let sport = dictionary["sport"] as? String,
              let division = dictionary["division"] as? String else {
            
            return nil
        }
        self.id = id
        
        self.date = date
        self.location = location
        self.team = teamAName
        self.opponent = teamBName
        self.sport = sport
        self.division = division
    }
    
    // TODO: delete this once we're fully migrated to firebase
    init(id: String = UUID().uuidString, team: String, opponent: String, location: String, date: Date, sport: String, division: String) {
        self.id = id
        self.team = team
        self.opponent = opponent
        self.location = location
        self.date = date
        self.sport = sport
        self.division = division
    }
}

struct Invite {
    let id: String
    
    let senderID: String
    let senderName: String
    let recipientID: String
    let recipientName: String
    
    let teamID: String
    let teamName: String
    let sport: String
    let division: String
    
    let status: String
    let createdAt: Date
    
    init?(dictionary: [String: Any], id: String) {
        guard let senderID = dictionary["sender_id"] as? String,
              let senderName = dictionary["sender_name"] as? String,
              let recipientID = dictionary["recipient_id"] as? String,
              let recipientName = dictionary["recipient_name"] as? String,
              let teamID = dictionary["team_id"] as? String,
              let teamName = dictionary["team_name"] as? String,
              let sport = dictionary["sport"] as? String,
              let division = dictionary["division"] as? String,
              let status = dictionary["status"] as? String,
              let createdAt = (dictionary["created_at"] as? Timestamp)?.dateValue() else {
            print("Error: Failed to parse invite document")
            return nil
        }
        
        self.id = id
        self.senderID = senderID
        self.senderName = senderName
        self.recipientID = recipientID
        self.recipientName = recipientName
        self.teamID = teamID
        self.teamName = teamName
        self.sport = sport
        self.division = division
        self.status = status
        self.createdAt = createdAt
    }
}

struct Activity {
    let text: String
}

// MARK: - Mock Data Generator

class MockDataGenerator {
    static func generateMockData() -> (user: DashboardUser, upcomingGames: [Game], teams: [DashboardTeam], activity: Activity) {
        let calendar = Calendar.current
        let october7 = calendar.date(from: DateComponents(year: 2025, month: 10, day: 7, hour: 18))!
        let october8 = calendar.date(from: DateComponents(year: 2025, month: 10, day: 8, hour: 19))!
        let october12 = calendar.date(from: DateComponents(year: 2025, month: 10, day: 12, hour: 18))!
        
        let g1 = Game(
            team: "Arch and Friends",
            opponent: "The Bevo Buddies",
            location: "Whittaker Fields",
            date: october8,
            sport: "Flag Football",
            division: "Men's"
        )
        
        let g2 = Game(
            team: "The Dodge Fathers",
            opponent: "Spike it",
            location: "Gregory Gym",
            date: october12,
            sport: "Dodgeball",
            division: "Co-ed"
        )
        
        let g3 = Game(
            team: "The Dodge Fathers",
            opponent: "Batman",
            location: "Belmont Hall",
            date: october7,
            sport: "Dodgeball",
            division: "Co-ed"
        )
        
        let upcomingGames = [g1, g2, g3]
        
        let t1 = DashboardTeam(
            name: "The Dodge Fathers",
            sport: "Co-ed Dodgeball",
            record: "5W - 2L",
            divisionStanding: "3rd in Division",
            nextGame: g3
        )
        
        let t2 = DashboardTeam(
            name: "Arch and Friends",
            sport: "Men's Flag Football",
            record: "3W - 2L",
            divisionStanding: "2nd in Division",
            nextGame: g1
        )
        
        let t3 = DashboardTeam(
            name: "Arch and ...",
            sport: "Men's Flag",
            record: "3W - 2L",
            divisionStanding: "—",
            nextGame: nil
        )
        
        let teams = [t1, t2, t3]
        
        let user = DashboardUser(name: "Ismael", teams: teams)
        let activity = Activity(text: "You and the Dodge Fathers beat Bevo Buddies 3–1!")
        
        return (user, upcomingGames, teams, activity)
    }
}
