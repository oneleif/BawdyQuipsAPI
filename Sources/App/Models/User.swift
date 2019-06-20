//
//  User.swift
//  App
//
//  Created by Zach Eriksen on 3/21/19.
//

import FluentSQLite
import Vapor
import Authentication

struct GameScore: Codable {
    var gold: Int
    var silver: Int
    var bronze: Int
    
    static var zero: GameScore {
        return GameScore(gold: 0, silver: 0, bronze: 0)
    }
}

final class User: SQLiteModel, Codable, Hashable {
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }
    
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var id: Int?
    
    // Auth
    var username: String
    var password: String
    
    // Game Data
    var currentScore: GameScore
    var totalScore: GameScore
    
    var handOfCards: [Card]?
    
    init(id: Int? = nil,
         username: String,
         password: String,
         currentScore: GameScore = GameScore.zero,
         totalScore: GameScore = GameScore.zero) {
        self.id = id
        self.username = username
        self.password = password
        self.currentScore = currentScore
        self.totalScore = totalScore
    }
}

extension User: Content {}
extension User: Migration {}
extension User: PasswordAuthenticatable {
    static var usernameKey: WritableKeyPath<User, String> {
        return \User.username
    }
    static var passwordKey: WritableKeyPath<User, String> {
        return \User.password
    }
}
extension User: SessionAuthenticatable {}
