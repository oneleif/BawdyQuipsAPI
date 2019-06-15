import Vapor
import Leaf

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    let sessionManager = RoomSessionManager.rooms
    
    let usersController = UserController()
    try router.register(collection: usersController)
    
    // MARK: Status Checks
    router.get("status") { _ in "ok \(Date())" }
    
    router.get("word-test") { request in
        return wordKey(with: request)
    }
    
    // MARK: Poster Routes
    router.post("create", use: sessionManager.createRoomSession)
    
    router.post("close", RoomSession.parameter) { req -> HTTPStatus in
        let session = try req.parameters.next(RoomSession.self)
        sessionManager.close(session)
        return .ok
    }
    
    router.post("update", RoomSession.parameter) { req -> Future<View> in
        //get session ID from the URL
        let session = try req.parameters.next(RoomSession.self)
        //create a room update from the POST request body
        return try RoomUpdate.decode(from: req).flatMap(to: View.self) { roomUpdate in
            
            //broadcast the room update
            return try roomUpdate.getUpdate(req).flatMap(to: View.self) { update in
                let context = GameContext(sessionID: session.id, update: session.update)
                sessionManager.update(update, for: session)
                return try req.view().render("Children/game", context)
            }
        }
    }
}

struct GameContext: Encodable{
    let sessionID: String
    let update: GameUpdate
}
