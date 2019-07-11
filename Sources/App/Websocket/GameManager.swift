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
import Jobs

class GameManager {
    let id: String
    var roomSession: RoomSession
    
    // MARK: Game Shit
    private var currentReadyCount = 0
    
    private lazy var countDownJob: Job = Jobs.add(interval: .seconds(0), action: {})
    
    init(id: String, roomSession: RoomSession) {
        self.id = id
        self.roomSession = roomSession
    }
    
    func sendRoomSession(_ req: Request) throws -> Future<RoomSession> {
        return Future.map(on: req) { RoomSessionManager.rooms.connections[self.id]?.room ?? self.roomSession }
    }
    
    func handleReadyUp(_ req: Request, user: User) throws -> Future<RoomSession> {
        user.isReady.toggle()
        
        currentReadyCount += user.isReady ? 1 : -1
        
        if currentReadyCount == roomSession.room?.users?.count {
            countdown()
        } else {
            countDownJob.stop()
        }
        
        return user.save(on: req).flatMap { _ in
            return try self.sendRoomSession(req)
        }
    }
    
    func countdown() {
        // Start a timer
        var count = 10
        countDownJob = Jobs.add(interval: .seconds(1)) {
            count -= 1
            if count < 0 {
                self.roomSession.update?.updateType = .GoToGame
                self.countDownJob.stop()
            }
            
            RoomSessionManager.rooms.update(self.roomSession, for: self.id)
        }
        countDownJob.start()
    }
    
    
    
}
