import Vapor

struct RoomSession: Content, Hashable {
    let update: GameUpdate?
    let room: Room?
    
    init(update: GameUpdate? = nil, room: Room? = nil) {
        self.update = update
        self.room = room
    }
}

extension RoomSession: Parameter {
  static func resolveParameter(_ parameter: String, on container: Container) throws -> String {
    return parameter
  }
}
