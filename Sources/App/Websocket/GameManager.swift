//
//  GameManager.swift
//  App
//
//  Created by Zach Eriksen on 7/1/19.
//

import Foundation
import Vapor
import Authentication
import FluentSQL

struct GameManager {
    let update: GameUpdate = GameUpdate()
    let id: String
    let roomSession: RoomSession
    
    func sendRoomSession(_ req: Request) throws -> Future<RoomSession> {
        return Future.map(on: req) { RoomSessionManager.rooms.connections[self.id]?.room ?? self.roomSession }
    }
    
    func handleReadyUp(_ req: Request, user: User) throws -> Future<RoomSession> {
        user.isReady.toggle()
        
        return user.save(on: req).flatMap { _ in
            return try self.sendRoomSession(req)
        }
    }
    
    
    
}
