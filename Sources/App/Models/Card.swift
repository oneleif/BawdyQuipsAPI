//
//  Card.swift
//  App
//
//  Created by Zach Eriksen on 5/28/19.
//

import FluentSQLite
import Vapor
import Authentication

final class Card: SQLiteModel, Codable, Equatable {
    static func == (lhs: Card, rhs: Card) -> Bool {
        return lhs.id == rhs.id
    }
    
    var id: Int?
    var description: String
    var numberOfBlanks: Int
    var isPrompt: Bool
    
    init(id: Int? = nil,
         description: String,
         numberOfBlanks: Int = 1,
         isPrompt: Bool = true) {
        self.id = id
        self.description = description
        self.numberOfBlanks = numberOfBlanks
        self.isPrompt = isPrompt
    }
}

extension Card: Content {}
extension Card: Migration {}
extension Card: Parameter {}
