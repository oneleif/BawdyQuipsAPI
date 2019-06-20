//
//  WebSocketController.swift
//  App
//
//  Created by Zach Eriksen on 6/17/19.
//

import Foundation
import Vapor

class WebSocketController: RouteCollection {
    func boot(router: Router) throws {
        let sessionManager = RoomSessionManager.rooms
        
        router.post("create", use: sessionManager.createRoomSession)
        
        router.post("close", String.parameter) { req -> HTTPStatus in
            let session = try req.parameters.next(String.self)
            sessionManager.close(session)
            return .ok
        }
        
        router.post("update", String.parameter) { req -> Future<View> in
            // get session ID from the URL
            let session = try req.parameters.next(String.self)
            // create a room update from the POST request body
            return try RoomSession.decode(from: req).flatMap(to: View.self) { roomSession in
                
                guard let update = roomSession.update,
                    let room = roomSession.room else {
                        return try req.view().render("Children/lobby")
                }
                
                var view: String = "Children/lobby"
                
                if let scene = update.scene {
                    switch scene {
                    case .Lobby:
                        view = "Children/lobby"
                    case .Playing:
                        view = "Children/game"
                    case .Voting:
                        view = "Children/voting"
                    case .Scoreboard:
                        view = "Children/scoreboard"
                    }
                }
                
                let context = GameContext(sessionID: session, update: update)
                sessionManager.update(roomSession, for: session)
                
                return try req.view().render(view, context)
                
            }
        }
    }
}

struct GameContext: Encodable{
    let sessionID: String
    let update: GameUpdate
}
