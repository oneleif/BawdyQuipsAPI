import Vapor

struct RoomSession: Content, Hashable {
    let id: String
    let update: GameUpdate?
    let room: Room?
    
    init(id: String, update: GameUpdate? = nil, room: Room? = nil) {
        self.id = id
        self.update = update
        self.room = room
    }
}

extension RoomSession: Parameter {
  static func resolveParameter(_ parameter: String, on container: Container) throws -> RoomSession {
    let session = RoomSession(id: parameter)
    return session
  }
}
