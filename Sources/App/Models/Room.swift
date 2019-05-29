//
//  Room.swift
//  App
//
//  Created by Zach Eriksen on 5/28/19.
//

import FluentSQLite
import Vapor
import Authentication

final class Room: SQLiteModel {
    var id: Int?
    var users: [User.ID]
    var judge: User.ID?
    
    init(id: Int? = nil) {
        self.id = id
        self.users = []
        self.judge = nil
    }
}

extension Room: Content {}
extension Room: Migration {}
extension Room: Parameter {}
