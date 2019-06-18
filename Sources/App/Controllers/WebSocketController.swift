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
        
        router.post("close", RoomSession.parameter) { req -> HTTPStatus in
            let session = try req.parameters.next(RoomSession.self)
            sessionManager.close(session)
            return .ok
        }
        
        router.post("update", RoomSession.parameter) { req -> Future<View> in
            // get session ID from the URL
            let session = try req.parameters.next(RoomSession.self)
            // create a room update from the POST request body
            return try RoomUpdate.decode(from: req).flatMap(to: View.self) { roomUpdate in
                
                // broadcast the room update
                return try roomUpdate.getUpdate(req).flatMap(to: View.self) { update in
                    
                    guard let updateType = update.updateType,
                        let sessionUpdate = session.update,
                        let scene = update.scene else {
                        return try req.view().render("Children/lobby")
                    }
                    
                    // TODO: Update
                    switch updateType {
                    case .CreateLobby:
                        print("wut")
                    case .GoToGame:
                        print("butt")
                    default:
                        print("nothing")
                    }
                    
                    
                    let context = GameContext(sessionID: session.id, update: sessionUpdate)
                    sessionManager.update(update, for: session)
                    var view: String
                    
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
                    
                    return try req.view().render(view, context)
                }
            }
        }
    }
}

struct GameContext: Encodable{
    let sessionID: String
    let update: GameUpdate
}
