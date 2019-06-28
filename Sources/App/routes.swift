import Vapor
import Leaf

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    let usersController = UserController()
    let gameController = WebSocketController()
    let updateController = RoomUpdateController()
    
    try router.register(collection: usersController)
    try router.register(collection: gameController)
    try router.register(collection: updateController)
}
