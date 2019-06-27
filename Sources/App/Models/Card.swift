//
//  Card.swift
//  App
//
//  Created by Zach Eriksen on 5/28/19.
//

import FluentSQLite
import Vapor
import Authentication

final class Card: SQLiteModel, Codable, Hashable {
    static func == (lhs: Card, rhs: Card) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(description)
        hasher.combine(numberOfBlanks)
        hasher.combine(isPrompt)
    }
    
    var id: Int?
    var description: String
    var numberOfBlanks: Int?
    var isPrompt: Bool?
    var authorId: User.ID
    
    init(id: Int? = nil,
         description: String,
         numberOfBlanks: Int? = 1,
         isPrompt: Bool? = true,
         authorId: Int) {
        self.id = id
        self.description = description
        self.numberOfBlanks = numberOfBlanks
        self.isPrompt = isPrompt
        self.authorId = authorId
    }
}

extension Card: Content {}
extension Card: Migration {}
extension Card: Parameter {}
