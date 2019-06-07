//
//  GameUpdate.swift
//  App
//
//  Created by Sabien Ambrose on 6/4/19.
//

import Vapor

struct GameUpdate: Content {
    enum Scenes: String, Codable{
        case Playing
        case Voting
        case Scoreboard
    }
    // The user sending the update
    var user: User.ID?
    var scene: Scenes?
    var room: Room.ID?
    
    //Playing Scene
    var playerSelectedCards: [Card]?
    var cardsToVoteOn: [User: [Card]]?
    
    //Voting Scene
    var goldAward: Bool
    var silverAward: Bool
    var bronzeAward: Bool
    //Scoreboard Scene
}

