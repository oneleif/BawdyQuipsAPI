import Vapor

struct RoomSession: Content, Hashable {
  let id: String
}

extension RoomSession: Parameter {
  static func resolveParameter(_ parameter: String, on container: Container) throws -> RoomSession {
    return .init(id: parameter)
  }
}
