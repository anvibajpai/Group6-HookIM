import Foundation
import FirebaseFirestore

// MARK: - Data Models

struct DashboardUser {
    let name: String
    let teams: [DashboardTeam]
}

struct DashboardTeam {
    let id: UUID
    let firebaseDocumentId: String
    var name: String
    var sport: String
    var record: String
    var divisionStanding: String
    var nextGame: Game?
    
    init(name: String, sport: String, record: String, divisionStanding: String, nextGame: Game?) {
        self.id = UUID()
        self.firebaseDocumentId = UUID().uuidString
        self.name = name
        self.sport = sport
        self.record = record
        self.divisionStanding = divisionStanding
        self.nextGame = nextGame
    }
    
    init?(dictionary: [String: Any], id: String) {
        guard let name = dictionary["name"] as? String,
              let sport = dictionary["sport"] as? String,
              let wins = dictionary["wins"] as? Int,
              let losses = dictionary["losses"] as? Int else {
            return nil
        }
        
        self.id = UUID(uuidString: id) ?? UUID()
        self.firebaseDocumentId = id
        self.name = name
        self.sport = sport
        self.record = "\(wins)W - \(losses)L"
        
        if let standing = dictionary["divisionStanding"] as? String {
            self.divisionStanding = standing
        } else {
            self.divisionStanding = "—"
        }
        
        self.nextGame = nil
    }
}

struct Game {
    let id: String
    
    let team: String
    let opponent: String
    let location: String
    let date: Date
    let sport: String
    let division: String
    
    init?(dictionary: [String: Any], id: String) {
        let location = dictionary["Location"] as? String ?? dictionary["location"] as? String
        let teamAName = dictionary["teamA_name"] as? String
        let teamBName = dictionary["teamB_name"] as? String
        let sport = dictionary["Sport"] as? String ?? dictionary["sport"] as? String
        let division = dictionary["Division"] as? String ?? dictionary["division"] as? String
        
        guard let location = location,
              let teamAName = teamAName,
              let teamBName = teamBName,
              let sport = sport,
              let division = division else {
            return nil
        }
        
        self.id = id
        
        let date: Date
        if let dateTimestamp = dictionary["date"] as? Timestamp {
            date = dateTimestamp.dateValue()
        } else if let dateTimestamp = dictionary["Date"] as? Timestamp {
            date = dateTimestamp.dateValue()
        } else {
            date = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        }
        
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



