import Vapor

struct RoomSession: Content, Hashable {
    let id: String
    let something: GameUpdate
    //TODO: add some way to reference a room
}

extension RoomSession: Parameter {
  static func resolveParameter(_ parameter: String, on container: Container) throws -> RoomSession {
    let session = RoomSession(id: parameter, something: GameUpdate())
    return session
  }
}
