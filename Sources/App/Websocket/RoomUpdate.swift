import Vapor

struct RoomUpdate: Content {
    enum UpdateType: Int, Codable {
        case VoteForCard
        case SelectCard
        case VoteForAnswer
        case SceneChange
    }
    
    let updateType: UpdateType
    let update: String
}
