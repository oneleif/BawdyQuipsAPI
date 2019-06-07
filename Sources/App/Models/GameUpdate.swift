//
//  GameUpdate.swift
//  App
//
//  Created by Sabien Ambrose on 6/4/19.
//

import Vapor

protocol GameUpdate : Codable {
    var user : User { get set }
}

struct SelectCard : GameUpdate {
    var user: User
    
    var card : Card
}

