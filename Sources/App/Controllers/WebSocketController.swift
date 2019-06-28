//
//  WebSocketController.swift
//  App
//
//  Created by Zach Eriksen on 6/17/19.
//

import Foundation
import Vapor
import Authentication
import FluentSQL

class WebSocketController: RouteCollection {
    func boot(router: Router) throws {
        let sessionManager = RoomSessionManager.rooms
        
        let authSessionRouter = router.grouped(User.authSessionsMiddleware())
        let protectedRouter = authSessionRouter.grouped(RedirectMiddleware<User>(path: "/login"))
        
        protectedRouter.post("create", use: sessionManager.createRoomSession)
        
        protectedRouter.post("close", String.parameter) { req -> HTTPStatus in
            let session = try req.parameters.next(String.self)
            sessionManager.close(session)
            return .ok
        }
        
        protectedRouter.post("update", String.parameter) { req -> Future<View> in
            // get session ID from the URL
            let session = try req.parameters.next(String.self)
            // create a room update from the POST request body
            return try RoomSession.decode(from: req).flatMap(to: View.self) { roomSession in
                
                guard let update = roomSession.update,
                    let serverSession = sessionManager.connections[session]?.room,
                    let room = serverSession.room else {
                        
                        return try req.view().render("Children/lobby")
                }
                
                var view: String = "Children/lobby"
                
                
                sessionManager.update(serverSession, for: session)
                
                if let scene = update.updateType {
                    switch scene {
                    case .GoToLobby, .PlayerJoined:
                        //TODO: init cards and the rest of room
                        return try self.getLobby(req: req, id: session, room: room)
                    case .GoToGame, .SelectCard:
                        view = "Children/game"
                    case .GoToVoting, .VoteForAnswer:
                        view = "Children/voting"
                    case .GoToScoring:
                        view = "Children/scoreboard"
                    }
                    
                }
                
                
                return try req.view().render(view)
                
            }
        }
        
        protectedRouter.post("refreshView", String.parameter) { req -> Future<View> in
            // get session ID from the URL
            let session = try req.parameters.next(String.self)
            // create a room update from the POST request body
            return try RoomSession.decode(from: req).flatMap(to: View.self) { roomSession in
                
                guard let update = roomSession.update,
                    let serverSession = sessionManager.connections[session]?.room,
                    let room = serverSession.room else {
                        
                        return try req.view().render("Children/lobby")
                }
                
                var view: String = "Children/lobby"
                if let scene = update.updateType {
                    switch scene {
                    case .GoToLobby, .PlayerJoined:
                        //TODO: init cards and the rest of room
                        return try self.getLobby(req: req, id: session, room: room)
                    case .GoToGame, .SelectCard:
                        view = "Children/game"
                    case .GoToVoting, .VoteForAnswer:
                        view = "Children/voting"
                    case .GoToScoring:
                        view = "Children/scoreboard"
                    }
                    
                }
                
                
                return try req.view().render(view)
                
            }
        }
    }
    
    func getLobby(req: Request, id: String, room: Room) throws -> Future<View> {
        guard let users = room.users else {
            return try req.view().render("Children/lobby")
        }
        
        // Query 1st
        return User.query(on: req)
            .filter(\User.roomID == id)
            .all()
            .flatMap { (users) -> Future<View> in
            let states: [UserLobbyState] = users.map { (user) -> UserLobbyState in
                return UserLobbyState(user: user.username, readyState: user.isReady)
            }
                l("States: \(states) (id: \(id))")
            return try req.view().render("Children/lobby",
                                         LobbyContext(sessionID: id, states: states))
        }
    }
}

struct XYZContext: Encodable {
    let lobby: LobbyContext?
}

struct LobbyContext: Encodable{
    let sessionID: String
    let states: [UserLobbyState]
}

struct UserLobbyState: Encodable{
    let user: String
    let readyState: Bool
}
