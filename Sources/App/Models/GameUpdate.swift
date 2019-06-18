//
//  GameUpdate.swift
//  App
//
//  Created by Sabien Ambrose on 6/4/19.
//

import Vapor

struct GameUpdate: Content, CustomStringConvertible {
    var description: String {
        return "\(user ?? 0)"
    }
    
    enum Scenes: Int, Codable, Hashable {
        case Lobby
        case Playing
        case Voting
        case Scoreboard
    }
    
    enum UpdateType: Int, Codable {
        case CreateLobby
        case PlayerJoined
        case GoToGame
        case SelectCard
        case GoToVoting
        case VoteForAnswer
        case GoToScoring
    }
    
    var updateType: UpdateType?
    
    // The user sending the update
    var user: User.ID?
    var scene: Scenes?
    
    //Lobby scene
    var isReady: Bool?
    
    //Playing Scene
    var hands: [User.ID: [Card.ID]]?
    var playerSelectedCards: [Card.ID]?
    var cardsToVoteOn: [User.ID: [Card.ID]]?
    
    //Voting Scene
    var goldAward: User.ID?
    var silverAward: User.ID?
    var bronzeAward: User.ID?
    
    //Scoreboard Scene
}

extension GameUpdate: Equatable, Hashable {
    
}

