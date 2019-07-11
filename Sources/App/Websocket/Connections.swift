//
//  Connections.swift
//  App
//
//  Created by Zach Eriksen on 7/1/19.
//

import Foundation
import Vapor
import WebSocket

struct Connections {
    var room: RoomSession
    var sessions: [WebSocket]
    var gameManager: GameManager
    
    init(room: RoomSession, sessions: [WebSocket], id: String) {
        self.room = room
        self.sessions = sessions
        self.gameManager = GameManager(id: id, roomSession: room)
    }
}
