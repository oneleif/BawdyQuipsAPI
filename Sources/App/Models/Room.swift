//
//  Room.swift
//  App
//
//  Created by Zach Eriksen on 5/28/19.
//

import FluentSQLite
import Vapor
import Authentication

final class Room: Codable, Hashable {
    static func == (lhs: Room, rhs: Room) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var id: String
    var admin: User.ID?
    var users: [User.ID]
    var judge: User.ID?
    var currentPrompt: Card?
    var cardDeck : CardDeck
    
    init(id: String) {
        self.id = id
        self.admin = nil
        self.users = []
        self.judge = nil
        self.cardDeck = CardDeck()
    }
}

extension Room: Content {}
