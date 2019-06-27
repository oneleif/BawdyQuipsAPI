//
//  RoomUpdateController.swift
//  App
//
//  Created by Zach Eriksen on 6/26/19.
//

import Vapor
import FluentSQL
import Crypto
import Authentication

class RoomUpdateController: RouteCollection {
    let sessionManager = RoomSessionManager.rooms
    
    func boot(router: Router) throws {
        
        let authSessionRouter = router.grouped(User.authSessionsMiddleware())
        
        let protectedRouter = authSessionRouter.grouped(RedirectMiddleware<User>(path: "/login"))
        
        protectedRouter.post("api", "lobby", "init", use: lobbyInit)
    }
    
    func lobbyInit(_ req: Request) throws -> Future<RoomSession>{
        // get session Id from the request params
        let session = try req.parameters.next(String.self)
        
        return try RoomSession.decode(from: req)
            .flatMap(to: RoomSession.self){ roomSession in
                
                guard let update = roomSession.update,
                    let user = update.user,
                    let type = update.updateType,
                    type == .PlayerJoined,
                    let serverRoom = self.sessionManager.connections[session]?.room.room,
                    var serverSession = self.sessionManager.connections[session]?.room else {
                        return Future.map(on: req) { self.sessionManager.connections[session]!.room }
                }
                
                //if there's no users in the room, make this one the admin
                if var users = serverRoom.users {
                    users.append(user)
                } else {
                    serverRoom.admin = user
                    serverRoom.users = [user]
                }
                
                serverSession.update = update
                
                return Future.map(on: req) {
                    RoomSession(update: nil, room: nil)
                }
                
                
        }
    }
}
