import Vapor

struct RoomUpdate: Content {
    enum UpdateType: Int, Codable {
        case VoteForCard
        case SelectCard
        case VoteForAnswer
        case GoToGame
        case GoToVoting
        case GoToScoring
    }
    
    let updateType: UpdateType
    let update: String
}
