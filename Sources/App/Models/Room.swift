//
//  Room.swift
//  App
//
//  Created by Zach Eriksen on 5/28/19.
//

import FluentSQLite
import Vapor
import Authentication

final class Room: SQLiteModel, Codable {
    var id: Int?
    var admin: User.ID?
    var users: [User.ID]
    var judge: User.ID?
    var currentPrompt: Card?
    var cardDeck : CardDeck
    
    init(id: Int? = nil) {
        self.id = id
        self.admin = nil
        self.users = []
        self.judge = nil
        self.cardDeck = CardDeck()
    }
}

extension Room: Content {}
extension Room: Migration {}
extension Room: Parameter {}
