import Vapor

struct RoomSession: Content, Hashable {
    let id: String
    //TODO: add some way to reference a room
}

extension RoomSession: Parameter {
  static func resolveParameter(_ parameter: String, on container: Container) throws -> RoomSession {
    return .init(id: parameter)
  }
}
