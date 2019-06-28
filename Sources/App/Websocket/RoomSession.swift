import Vapor

struct RoomSession: Content, Hashable {
    var update: GameUpdate?
    let room: Room?
    let id: String?
    
    init(update: GameUpdate? = nil, room: Room? = nil, id: String? = nil) {
        self.update = update
        self.room = room
        self.id = id
    }
}

extension RoomSession: Parameter {
  static func resolveParameter(_ parameter: String, on container: Container) throws -> String {
    return parameter
  }
}
