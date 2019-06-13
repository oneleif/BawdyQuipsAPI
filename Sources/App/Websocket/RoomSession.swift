import Vapor

struct RoomSession: Content, Hashable {
    let id: String
    let update: GameUpdate
}

extension RoomSession: Parameter {
  static func resolveParameter(_ parameter: String, on container: Container) throws -> RoomSession {
    let session = RoomSession(id: parameter, update: GameUpdate())
    return session
  }
}
