import Foundation

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
    let team: String
    let opponent: String
    let location: String
    let date: Date
}

struct Activity {
    let text: String
}

// MARK: - Mock Data Generator

class MockDataGenerator {
    static func generateMockData() -> (user: DashboardUser, upcomingGames: [Game], teams: [DashboardTeam], activity: Activity) {
        // Create specific dates for October 2024
        let calendar = Calendar.current
        let october7 = calendar.date(from: DateComponents(year: 2024, month: 10, day: 7, hour: 18))!
        let october8 = calendar.date(from: DateComponents(year: 2024, month: 10, day: 8, hour: 19))!
        let october12 = calendar.date(from: DateComponents(year: 2024, month: 10, day: 12, hour: 18))!
        
        let g1 = Game(
            team: "Arch and Friends",
            opponent: "The Bevo Buddies",
            location: "Whittaker Fields",
            date: october8
        )
        
        let g2 = Game(
            team: "The Dodge Fathers",
            opponent: "Spike it",
            location: "Gregory Gym",
            date: october12
        )
        
        let g3 = Game(
            team: "The Dodge Fathers",
            opponent: "Batman",
            location: "Belmont Hall",
            date: october7
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