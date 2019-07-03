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
    let sessionManager = RoomSessionManager.rooms
    
    func boot(router: Router) throws {
        let authSessionRouter = router.grouped(User.authSessionsMiddleware())
        let protectedRouter = authSessionRouter.grouped(RedirectMiddleware<User>(path: "/login"))
        
        protectedRouter.post("create", use: sessionManager.createRoomSession)
        
        protectedRouter.post("close", String.parameter) { req -> HTTPStatus in
            let session = try req.parameters.next(String.self)
            self.sessionManager.close(session)
            return .ok
        }
        
        protectedRouter.post("update",
                             String.parameter,
                             use: update)
        
        protectedRouter.post("updateView",
                             String.parameter,
                             use: updateView)
    }
    
    func update(req: Request) throws -> Future<View> {
        // get session ID from the URL
        let session = try req.parameters.next(String.self)
        // create a room update from the POST request body
        return try RoomSession.decode(from: req).flatMap(to: View.self) { roomSession in
            return try self.updateRoomSession(req: req, roomSession: roomSession, session: session).flatMap { updatedSession in
                return try self.getView(req: req, session: session).map { view  in
                    self.sessionManager.update(updatedSession, for: session)
                    
                    return view
                }
            }
        }
    }
    
    // Updates the server's roomSession appropriately
    func updateRoomSession(req: Request, roomSession: RoomSession, session: String) throws -> Future<RoomSession> {
        
        guard let update = roomSession.update,
            let updateType = update.updateType else {
                return Future.map(on: req) { self.sessionManager.connections[session]?.room ?? roomSession }
        }
        return User.query(on: req).filter(\.id, .equal, update.user ?? -1).all()
            .flatMap { user in
                guard let user = user.first else {
                    return Future.map(on: req) { self.sessionManager.connections[session]?.room ?? roomSession }
                }
                
                
                switch updateType {
                case .ReadyUp:
                    // TODO
                    return try self.sessionManager.connections[session]!.gameManager.handleReadyUp(req, user: user)
                case .GoToGame:
                    print("go go go")
                default:
                    print("qwerty")
                }
                
                
                return Future.map(on: req) { self.sessionManager.connections[session]?.room ?? roomSession }
        }
    }
    
    
    
    func getView(req: Request, session: String) throws -> Future<View> {
        // create a room update from the POST request body
        return try RoomSession.decode(from: req).flatMap(to: View.self) { roomSession in
            
            guard let update = roomSession.update,
                let serverSession = self.sessionManager.connections[session]?.room,
                let room = serverSession.room else {
                    
                    return try req.view().render("Children/lobby")
            }
            
            var view: String = "Children/lobby"
            if let scene = update.updateType {
                switch scene {
                case .GoToLobby, .PlayerJoined, .ReadyUp:
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
    
    func updateView(req: Request) throws -> Future<View> {
        // get session ID from the URL
        let session = try req.parameters.next(String.self)
        // create a room update from the POST request body
        return try RoomSession.decode(from: req).flatMap(to: View.self) { roomSession in
            
            guard let update = roomSession.update,
                let serverSession = self.sessionManager.connections[session]?.room,
                let room = serverSession.room else {
                    
                    return try req.view().render("Children/lobby")
            }
            
            var view: String = "Children/lobby"
            if let scene = update.updateType {
                switch scene {
                case .GoToLobby, .PlayerJoined, .ReadyUp:
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
